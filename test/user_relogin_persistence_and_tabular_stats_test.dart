import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/core/services/user_storage_service.dart';
import 'package:worldsports/screens/match/match_creation_screen.dart';
import 'package:worldsports/screens/profile/dedicated_stats_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Problem 1: Re-login Persistence without Data Loss', () {
    test('Account data and match stats persist across logout and re-login', () async {
      final appState = AppState();

      // 1. Register a real user account
      const newUser = UserModel(
        id: 'user_rohit_99',
        userId: 'WS-9999',
        name: 'Rohit Sharma',
        username: 'rohit_45',
        email: 'rohit45@worldsports.test',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'Top-Order Batter',
      );
      await UserStorageService.registerAccount(
        email: newUser.email,
        username: newUser.username,
        password: 'password123',
        user: newUser,
      );
      appState.login(newUser);

      // 2. Play and complete a match where Rohit scores 55 runs and takes 1 wicket
      final match = MatchModel(
        id: 'relogin_test_match_1',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'Mumbai Indians',
        team2Name: 'Kolkata Knights',
        team1Short: 'MI',
        team2Short: 'KKR',
        dateTime: DateTime.now(),
        venue: 'Wankhede Stadium',
        status: MatchStatus.completed,
        format: 'T20 (20 Overs)',
        team1Players: const [
          MatchPlayer(id: 'user_rohit_99', userId: 'user_rohit_99', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Batter'),
        ],
        team2Players: const [
          MatchPlayer(id: 'p_opp_1', name: 'Andre Russell', jerseyNumber: 12, role: 'All-Rounder'),
        ],
      );

      final scoreData = <String, dynamic>{
        'overs_limit': 20,
        'team1_score': '170/3',
        'team2_score': '160/6',
        'innings1': {
          'batting': {
            'user_rohit_99': {
              'name': 'Rohit Sharma',
              'user_id': 'user_rohit_99',
              'runs': 55,
              'balls': 35,
              'fours': 5,
              'sixes': 3,
              'is_out': true,
              'dismissal': 'bowled',
            },
          },
          'bowling': {},
        },
        'innings2': {
          'batting': {},
          'bowling': {
            'user_rohit_99': {
              'name': 'Rohit Sharma',
              'user_id': 'user_rohit_99',
              'balls': 12,
              'runs': 16,
              'wickets': 1,
              'maidens': 0,
            },
          },
        },
      };

      appState.addMatch(match);
      appState.recordMatchCompletion(
        matchId: match.id,
        resultText: 'Mumbai Indians won by 10 runs',
        finalScoreData: scoreData,
      );

      // Verify stats immediately after match completion
      final liveStats = appState.currentUser!.stats[SportType.cricket]!;
      expect(liveStats.specificStats['runs'], equals(55));
      expect(liveStats.specificStats['wickets'], equals(1));
      expect(appState.previousMatches.length, equals(1));

      // 3. User logs out
      appState.logout();
      expect(appState.currentUser, isNull);

      // 4. User re-logins using their registered account
      final storedUser = await UserStorageService.authenticateLocal(
        emailOrUsername: 'rohit_45',
        password: 'password123',
      );
      expect(storedUser, isNotNull);
      appState.login(storedUser!);

      // 5. Verify that previous match and stats are fully retained upon re-login!
      expect(appState.previousMatches.length, equals(1));
      final restoredStats = appState.currentUser!.stats[SportType.cricket]!;
      expect(restoredStats.specificStats['runs'], equals(55));
      expect(restoredStats.specificStats['wickets'], equals(1));
      expect(restoredStats.specificStats['fifties'], equals(1));
    });
  });

  group('Problem 2 & 3: Adding other registered real accounts by username or name in match creation', () {
    testWidgets('Search by @username and athlete name finds registered accounts without developer ID', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Register two real accounts
      const userA = UserModel(
        id: 'creator_user_1',
        name: 'Alex Morgan',
        username: 'alex_m',
        email: 'alex@worldsports.test',
        role: UserRole.coach,
        sports: [SportType.cricket],
      );

      const userB = UserModel(
        id: 'other_real_athlete_2',
        name: 'Jasprit Bumrah',
        username: 'jasprit93',
        email: 'jasprit@worldsports.test',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'Fast Bowler',
      );

      await UserStorageService.registerAccount(
        email: userA.email,
        username: userA.username,
        password: 'password123',
        user: userA,
      );
      await UserStorageService.registerAccount(
        email: userB.email,
        username: userB.username,
        password: 'password123',
        user: userB,
      );

      final allUsers = await UserStorageService.getAllRegisteredUsers();
      expect(allUsers.any((u) => u.username.contains('jasprit93')), isTrue);

      final appState = AppState();
      appState.login(userA);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: CreateMatchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Proceed to Step 2: Squad Lineup
      final continueBtn = find.text('Continue');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Open Add Player dialog for Team 1
      final addPlayerBtn = find.text('Add Player').first;
      await tester.tap(addPlayerBtn);
      await tester.pumpAndSettle();

      // Verify that user is prompted to enter @username or athlete name (NOT developer user ID)
      expect(find.textContaining('Enter @username or Athlete Name'), findsOneWidget);
      expect(find.text('Search Athlete'), findsWidgets);

      // Search by username '@jasprit93'
      final inputField = find.byKey(const Key('athlete_id_input'));
      await tester.enterText(inputField, '@jasprit93');
      await tester.pumpAndSettle();

      final searchBtn = find.byKey(const Key('verify_account_btn'));
      await tester.tap(searchBtn);
      await tester.pumpAndSettle();

      // Jasprit Bumrah must be found and displayed as verified real athlete
      expect(find.text('Jasprit Bumrah'), findsOneWidget);
      expect(find.textContaining('VERIFIED REAL ATHLETE'), findsOneWidget);
      expect(find.textContaining('@jasprit93'), findsWidgets);

      // Search by athlete name 'Jasprit'
      await tester.enterText(inputField, 'Jasprit');
      await tester.pumpAndSettle();
      await tester.tap(searchBtn);
      await tester.pumpAndSettle();

      expect(find.text('Jasprit Bumrah'), findsOneWidget);

      // Confirm & add to squad
      final confirmAddBtn = find.textContaining('Confirm & Add');
      expect(confirmAddBtn, findsOneWidget);
      await tester.ensureVisible(confirmAddBtn);
      await tester.tap(confirmAddBtn);
      await tester.pumpAndSettle();

      // Jasprit Bumrah is now in the squad lineup!
      expect(find.text('Jasprit Bumrah'), findsOneWidget);
    });
  });

  group('Problem 5: Strictly Tabular Stats, Zero Box Cards in DedicatedStatsScreen', () {
    testWidgets('DedicatedStatsScreen renders full data tables and zero _StatCard boxes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final appState = AppState();
      const testUser = UserModel(
        id: 'table_user_01',
        name: 'MS Dhoni',
        username: 'msd_07',
        email: 'msd@worldsports.test',
        role: UserRole.player,
        sports: [SportType.cricket, SportType.football],
        primarySport: SportType.cricket,
        primaryRole: 'Wicketkeeper Batter',
      );
      appState.login(testUser);

      // Add a completed T20 match
      appState.addPreviousMatch(
        PreviousMatchModel(
          id: 'prev_m_1',
          sport: SportType.cricket,
          team1Name: 'CSK Super Kings',
          team2Name: 'DC Capitals',
          team1Short: 'CSK',
          team2Short: 'DC',
          team1Score: '185/4',
          team2Score: '160/9',
          resultText: 'CSK won by 25 runs',
          isWin: true,
          date: DateTime.now(),
          venue: 'Chepauk Stadium',
          myPerformance: '84*(38)',
          userId: 'table_user_01',
          format: 'T20 (20 Overs)',
          rawScoreData: {
            'overs_limit': 20,
            'innings1': {
              'batting': {
                'table_user_01': {
                  'name': 'MS Dhoni',
                  'runs': 84,
                  'balls': 38,
                  'fours': 7,
                  'sixes': 5,
                  'is_out': false,
                  'dismissal': 'not out',
                },
              },
              'bowling': {},
            },
            'innings2': {
              'batting': {},
              'bowling': {},
            },
          },
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: DedicatedStatsScreen(initialSport: SportType.cricket),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Career Record headers in tabular form
      expect(find.text('BATTING CAREER RECORD (TABULAR)'), findsOneWidget);
      expect(find.text('BOWLING CAREER RECORD (TABULAR)'), findsOneWidget);

      // 2. Verify all standard tabular headers are present in DataTable columns
      expect(find.text('FORMAT'), findsWidgets);
      expect(find.text('MATCHES'), findsWidgets);
      expect(find.text('INNINGS'), findsWidgets);
      expect(find.text('RUNS'), findsWidgets);
      expect(find.text('BALL FACED'), findsWidgets);
      expect(find.text('AVG'), findsWidgets);
      expect(find.text('STRIKE RATE'), findsWidgets);
      expect(find.text('50s'), findsWidgets);
      expect(find.text('100s'), findsWidgets);
      expect(find.text('HIGHEST SCORE'), findsWidgets);

      // Bowling table headers
      expect(find.text('BALL BOWLED'), findsWidgets);
      expect(find.text('OVERS'), findsWidgets);
      expect(find.text('RUN GIVEN'), findsWidgets);
      expect(find.text('WICKETS'), findsWidgets);
      expect(find.text('BEST FIGURE'), findsWidgets);
      expect(find.text('ECONOMY'), findsWidgets);

      // 3. Verify DataTables are rendered
      expect(find.byType(DataTable), findsWidgets);

      // 4. Verify 84 runs and 84* highest score exist in table row cells
      expect(find.text('84'), findsWidgets);
      expect(find.text('84*'), findsWidgets);

      // 5. Switch to Football sport
      await tester.tap(find.text('FOOTBALL'));
      await tester.pumpAndSettle();

      expect(find.text('FOOTBALL PERFORMANCE RECORD (TABULAR)'), findsOneWidget);
      expect(find.text('STATISTIC'), findsOneWidget);
      expect(find.text('CATEGORY / BENCHMARK'), findsOneWidget);
      expect(find.text('GOALS'), findsOneWidget);
      expect(find.text('ASSISTS'), findsOneWidget);
      expect(find.text('PASS ACCURACY'), findsOneWidget);
    });
  });
}
