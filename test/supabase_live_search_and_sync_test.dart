import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/services/supabase_service.dart';
import 'package:worldsports/core/services/user_storage_service.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/match/match_creation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Remote athlete caching and retrieval in UserStorageService', () async {
    final remoteAthletes = [
      const MatchPlayer(
        id: 'remote_ath_101',
        name: 'KL Rahul',
        username: '@klrahul',
        userId: 'WS-KLRAHUL',
        jerseyNumber: 1,
        role: 'BATSMAN',
        specsSummary: 'Right-hand bat • Wicketkeeper',
      ),
      const MatchPlayer(
        id: 'remote_ath_102',
        name: 'Mohammed Siraj',
        username: '@siraj_fast',
        userId: 'WS-SIRAJ',
        jerseyNumber: 73,
        role: 'BOWLER',
        specsSummary: 'Right-arm fast',
      ),
    ];

    await UserStorageService.cacheRemoteAthletes(remoteAthletes);
    final cached = await UserStorageService.getCachedRemoteAthletes();

    expect(cached.length, 2);
    expect(cached.any((a) => a.username == '@klrahul'), isTrue);
    expect(cached.any((a) => a.name == 'Mohammed Siraj'), isTrue);
  });

  test('SupabaseService.profileMapToMatchPlayer properly converts database rows', () {
    final row = {
      'id': 'sp_test_uuid_123',
      'user_id': 'WS-RAHUL',
      'full_name': 'Rahul Dravid',
      'username': 'rahul_thewall',
      'primary_role': 'Batsman',
      'jersey_number': 19,
      'player_sport_stats': [
        {
          'stats_data': {
            'batting_hand': 'Right-hand bat',
            'specialty': 'Top Order Anchor',
          }
        }
      ]
    };

    final player = SupabaseService.profileMapToMatchPlayer(row);
    expect(player.id, 'sp_test_uuid_123');
    expect(player.name, 'Rahul Dravid');
    expect(player.username, '@rahul_thewall');
    expect(player.userId, 'WS-RAHUL');
    expect(player.role, 'BATSMAN');
    expect(player.specsSummary, contains('Right-hand bat'));
  });

  testWidgets('MatchCreationScreen finds cached and remote registered athletes by @username and full name',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    const loggedInUser = UserModel(
      id: 'creator_11',
      userId: 'WS-CREATOR',
      name: 'Match Organizer',
      username: 'match_host',
      email: 'host@worldsports.test',
      phone: '+919999900000',
      role: UserRole.organiser,
      sports: [SportType.cricket],
      primarySport: SportType.cricket,
      primaryRole: 'Organiser',
      hasCompletedProfile: true,
    );

    // Register an athlete account
    const athleteUser = UserModel(
      id: 'athlete_remote_22',
      userId: 'WS-SURYA',
      name: 'Surya Kumar',
      username: 'surya_sky',
      email: 'sky@worldsports.test',
      phone: '+919876543210',
      role: UserRole.player,
      sports: [SportType.cricket],
      primarySport: SportType.cricket,
      primaryRole: 'Batsman',
      hasCompletedProfile: true,
    );

    await UserStorageService.registerAccount(
      email: athleteUser.email,
      username: athleteUser.username,
      password: 'Password123!',
      user: athleteUser,
    );

    // Cache a remote Supabase athlete
    await UserStorageService.cacheRemoteAthletes([
      const MatchPlayer(
        id: 'remote_bumrah',
        name: 'Jasprit Yorker',
        username: '@jasprit_live',
        userId: 'WS-YORKER',
        jerseyNumber: 93,
        role: 'BOWLER',
        specsSummary: 'Right-arm fast • Yorker',
      ),
    ]);

    appState.login(loggedInUser);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(
          home: CreateMatchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate past step 0
    final continueBtn = find.text('Continue');
    expect(continueBtn, findsOneWidget);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Step 1: Squad Lineup -> Tap "Add Player"
    final addPlayerBtn = find.text('Add Player').first;
    expect(addPlayerBtn, findsOneWidget);
    await tester.tap(addPlayerBtn);
    await tester.pumpAndSettle();

    // Search for athlete by username using explicit dialog keys
    final searchInput = find.byKey(const Key('athlete_id_input'));
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, '@surya_sky');
    await tester.pumpAndSettle();

    final lookupBtn = find.byKey(const Key('verify_account_btn'));
    expect(lookupBtn, findsOneWidget);
    await tester.tap(lookupBtn);
    await tester.pumpAndSettle();

    // Verify athlete is found by @username
    expect(find.text('Surya Kumar'), findsWidgets);

    // Search for remote cached athlete by name
    await tester.enterText(searchInput, 'Jasprit Yorker');
    await tester.pumpAndSettle();
    await tester.tap(lookupBtn);
    await tester.pumpAndSettle();

    // Verify remote athlete is found by full name
    expect(find.text('Jasprit Yorker'), findsWidgets);
  });
}
