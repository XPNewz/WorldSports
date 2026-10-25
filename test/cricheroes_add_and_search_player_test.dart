import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/services/user_storage_service.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/match/match_creation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Registered athletes with email or phone have hasRegisteredContact true', () {
    const registeredUser = UserModel(
      id: 'user_franky',
      userId: 'WS-FRANKY',
      name: 'Franky',
      email: 'franky@worldsports.test',
      phone: '+919988776655',
      username: 'franky',
      sports: [SportType.cricket],
      role: UserRole.player,
    );
    expect(registeredUser.hasRegisteredContact, isTrue);

    const matchPlayerWithContact = MatchPlayer(
      id: 'ws_ath_franky_1',
      name: 'Franky',
      username: 'franky',
      userId: 'WS-FRANKY',
      jerseyNumber: 7,
      role: 'BATSMAN',
      email: 'franky@worldsports.test',
      phone: '+919988776655',
    );
    expect(matchPlayerWithContact.hasRegisteredContact, isTrue);

    const dummyPlayer = MatchPlayer(
      id: 'dummy_1',
      name: 'Dummy Player',
      username: 'dummy',
      userId: 'WS-DUMMY',
      jerseyNumber: 99,
      role: 'BATSMAN',
      email: '',
      phone: '',
    );
    expect(dummyPlayer.hasRegisteredContact, isFalse);
  });

  testWidgets('Only real registered users with email/phone can be added to match squads', (tester) async {
    final appState = AppState();
    const abhiprayUser = UserModel(
      id: 'user_abhipray',
      userId: 'WS-ABHIPRAY',
      name: 'Abhipray',
      email: 'abhipray@worldsports.test',
      phone: '+919876543210',
      username: 'abhipray',
      role: UserRole.player,
      sports: [SportType.cricket],
      primarySport: SportType.cricket,
      primaryRole: 'All-Rounder',
      hasCompletedProfile: true,
    );
    appState.login(abhiprayUser);

    // Register a real teammate in local storage with email and phone
    const frankyUser = UserModel(
      id: 'user_franky',
      userId: 'WS-FRANKY',
      name: 'Franky Verma',
      email: 'franky@worldsports.test',
      phone: '+919988776655',
      username: 'franky',
      role: UserRole.player,
      sports: [SportType.cricket],
      primarySport: SportType.cricket,
      primaryRole: 'Batsman',
      hasCompletedProfile: true,
    );
    await UserStorageService.registerAccount(
      email: frankyUser.email,
      username: frankyUser.username,
      password: 'password123',
      user: frankyUser,
    );

    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(
          home: CreateMatchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Step 0: Match details -> Tap Continue to move to Squad Lineup
    final continueBtn = find.text('Continue');
    expect(continueBtn, findsOneWidget);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Step 1: Squad Lineup -> Tap Add Player
    final addPlayerBtn = find.text('Add Player').first;
    expect(addPlayerBtn, findsOneWidget);
    await tester.tap(addPlayerBtn);
    await tester.pumpAndSettle();

    // Modal is open and has input field
    final searchInput = find.byKey(const Key('athlete_id_input'));
    expect(searchInput, findsOneWidget);

    // 1. Search an UNREGISTERED dummy name -> must be rejected, NO quick-add button allowed
    await tester.enterText(searchInput, 'unregistered_dummy_name');
    await tester.pumpAndSettle();

    // No quick add button exists!
    expect(find.byKey(const Key('add_custom_player_btn')), findsNothing);
    // Informative rejection is shown
    expect(find.textContaining('No registered athlete matching'), findsOneWidget);
    expect(find.textContaining('Only real users with a profile registered via email or phone can be added'), findsOneWidget);

    // 2. Now search real registered user by username '@franky'
    await tester.enterText(searchInput, '@franky');
    await tester.pumpAndSettle();

    // Tap search button to lookup profile
    final searchBtn = find.byKey(const Key('verify_account_btn'));
    await tester.tap(searchBtn);
    await tester.pumpAndSettle();

    // Franky's verified card appears with registered contact info!
    expect(find.text('VERIFIED REAL ATHLETE'), findsOneWidget);
    expect(find.text('Franky Verma'), findsWidgets);
    expect(find.textContaining('Registered: franky@worldsports.test'), findsOneWidget);

    // Select Franky to add to squad
    final selectBtn = find.textContaining('Confirm & Add to');
    expect(selectBtn, findsOneWidget);
    await tester.tap(selectBtn);
    await tester.pumpAndSettle();

    // Verify Franky is now in the squad lineup!
    expect(find.text('Franky Verma'), findsWidgets);
  });
}
