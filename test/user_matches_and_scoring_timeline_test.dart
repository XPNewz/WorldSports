import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/core/theme/app_theme.dart';
import 'package:worldsports/screens/match/live_scoring_screen.dart';
import 'package:worldsports/screens/mysports/mysports_screen.dart';
import 'package:worldsports/screens/profile/profile_screen.dart';
import 'package:worldsports/screens/profile/dedicated_stats_screen.dart';

void main() {
  group('Problem 1: Real User Matches & Stats in MySports', () {
    testWidgets('New real user with no matches sees 0 played, 0 wins, 0 upcoming and NO dummy matches', (tester) async {
      final appState = AppState();
      const realUser = UserModel(
        id: 'real_user_001',
        userId: 'WS-9999',
        name: 'Arjun Tendulkar',
        username: 'arjun_t',
        email: 'arjun@example.com',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'All-Rounder',
      );
      appState.login(realUser);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MySportsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header metric counters are 0, not dummy 3 played or 2 upcoming
      expect(find.text('0'), findsNWidgets(3)); // PLAYED: 0, WINS: 0, UPCOMING: 0
      expect(find.text('Tigers vs Warriors'), findsNothing);
      expect(find.text('Lions vs Panthers'), findsNothing);

      // Verify empty tabs
      expect(find.text('UPCOMING (0)'), findsOneWidget);
      expect(find.text('PREVIOUS (0)'), findsOneWidget);
      expect(find.text('LIVE (0)'), findsOneWidget);
    });

    testWidgets('Real user matches appear in MySports when user is a participating athlete', (tester) async {
      final appState = AppState();
      const realUser = UserModel(
        id: 'real_user_001',
        userId: 'WS-9999',
        name: 'Arjun Tendulkar',
        username: 'arjun_t',
        email: 'arjun@example.com',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'All-Rounder',
      );
      appState.login(realUser);

      final userMatch = MatchModel(
        id: 'user_live_match_1',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'Goa Titans',
        team2Name: 'Surat Strikers',
        team1Short: 'GOA',
        team2Short: 'SUR',
        dateTime: DateTime.now(),
        venue: 'Panaji Stadium',
        status: MatchStatus.live,
        team1Players: const [
          MatchPlayer(id: 'real_user_001', userId: 'real_user_001', name: 'Arjun Tendulkar', jerseyNumber: 24, role: 'All-Rounder'),
          MatchPlayer(id: 'p2', name: 'Rohan K.', jerseyNumber: 7, role: 'Batter'),
        ],
        team2Players: const [
          MatchPlayer(id: 'p3', name: 'Vikas S.', jerseyNumber: 10, role: 'Bowler'),
          MatchPlayer(id: 'p4', name: 'Sunil D.', jerseyNumber: 11, role: 'Batter'),
        ],
      );

      appState.addMatch(userMatch);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MySportsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // LIVE tab should now show 1
      expect(find.text('LIVE (1)'), findsOneWidget);
      expect(find.text('UPCOMING (0)'), findsOneWidget);
      expect(find.text('PREVIOUS (0)'), findsOneWidget);
    });
  });

  group('Problem 2: Wicket Dismissal Next Batsman Selection & Innings End', () {
    testWidgets('Next batsman dialog only shows yet-to-bat players, not dismissed players, and concludes innings when all out', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final appState = AppState();
      const currentUser = UserModel(
        id: 'u001',
        userId: 'WS-1001',
        name: 'Scorer User',
        username: 'scorer',
        email: 'scorer@example.com',
        role: UserRole.coach,
        sports: [SportType.cricket],
      );
      appState.login(currentUser);

      // Squad with 3 players: 2 on pitch, 1 on bench (total wickets possible: 2)
      final smallSquadMatch = MatchModel(
        id: 'wicket_test_match',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'Team A',
        team2Name: 'Team B',
        team1Short: 'TMA',
        team2Short: 'TMB',
        dateTime: DateTime.now(),
        venue: 'Ground 1',
        creatorId: 'u001',
        format: '5 Overs',
        team1Players: const [
          MatchPlayer(id: 'b1', name: 'Batsman One', jerseyNumber: 1, role: 'Opening Batter'),
          MatchPlayer(id: 'b2', name: 'Batsman Two', jerseyNumber: 2, role: 'Opening Batter'),
          MatchPlayer(id: 'b3', name: 'Batsman Three', jerseyNumber: 3, role: 'Middle Order'),
        ],
        team2Players: const [
          MatchPlayer(id: 'bw1', name: 'Bowler One', jerseyNumber: 99, role: 'Bowler'),
          MatchPlayer(id: 'bw2', name: 'Bowler Two', jerseyNumber: 98, role: 'Bowler'),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: LiveScoringScreen(match: smallSquadMatch),
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (find.text('Confirm Openers & Start').evaluate().isNotEmpty) {
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      // Switch to Scoreboard tab where the creator scoring pad is located
      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // Tap OUT / WICKET button for 1st wicket (Batsman One)
      final wicketBtn = find.text('OUT / WICKET');
      await tester.ensureVisible(wicketBtn);
      await tester.tap(wicketBtn);
      await tester.pumpAndSettle();

      // Dismissal modal should be open
      expect(find.textContaining('Wicket Dismissal'), findsOneWidget);

      // Tap 'Bowled' mode
      await tester.tap(find.text('Bowled'));
      await tester.pumpAndSettle();

      // Next Batter bottom sheet opens: only Batsman Three should be an option!
      expect(find.text('Select Next Batter'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Batsman Three'), findsOneWidget);
      // Batsman One and Batsman Two must NOT be selectable
      expect(find.widgetWithText(ListTile, 'Batsman One'), findsNothing);
      expect(find.widgetWithText(ListTile, 'Batsman Two'), findsNothing);

      // Select Batsman Three from the sheet
      await tester.tap(find.widgetWithText(ListTile, 'Batsman Three'));
      await tester.pumpAndSettle();

      // Score should now be 0/1
      expect(find.textContaining('0/1'), findsWidgets);

      // Now Batsman Three is striker, Batsman Two is non-striker.
      // There are NO MORE players in the squad who haven't batted.
      // Next wicket must end innings as All Out!
      await tester.ensureVisible(wicketBtn);
      await tester.tap(wicketBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('No more batters remaining in squad'), findsOneWidget);

      // Tap 'Caught'
      await tester.tap(find.text('Caught'));
      await tester.pumpAndSettle();

      // Innings Concluded dialog should appear immediately with All Out
      expect(find.text('1st Innings Concluded'), findsAtLeastNWidgets(1));
      expect(find.textContaining('completed their 1st innings at 0/2'), findsOneWidget);
    });
  });

  group('Problem 3: Real In-Game Timeline & Analytics Scoring Serialization', () {
    testWidgets('Scores, boundaries, over progression, and timeline events serialize and restore accurately', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final appState = AppState();
      const currentUser = UserModel(
        id: 'u001',
        userId: 'WS-1001',
        name: 'Scorer User',
        username: 'scorer',
        email: 'scorer@example.com',
        role: UserRole.coach,
        sports: [SportType.cricket],
      );
      appState.login(currentUser);

      final match = MatchModel(
        id: 'timeline_test_match',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'Bangalore Bulls',
        team2Name: 'Chennai Champs',
        team1Short: 'BLR',
        team2Short: 'CHN',
        dateTime: DateTime.now(),
        venue: 'Chinnaswamy Stadium',
        creatorId: 'u001',
        format: '5 Overs',
        team1Players: const [
          MatchPlayer(id: 'p1', name: 'KL Rahul', jerseyNumber: 1, role: 'Batter'),
          MatchPlayer(id: 'p2', name: 'Mayank A.', jerseyNumber: 2, role: 'Batter'),
          MatchPlayer(id: 'p3', name: 'Manish P.', jerseyNumber: 3, role: 'Batter'),
        ],
        team2Players: const [
          MatchPlayer(id: 'p10', name: 'Ashwin R.', jerseyNumber: 99, role: 'Bowler'),
        ],
      );
      appState.addMatch(match);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: LiveScoringScreen(match: match),
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (find.text('Confirm Openers & Start').evaluate().isNotEmpty) {
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      // Switch to Scoreboard tab
      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // Score 4 runs (boundary)
      final fourBtn = find.widgetWithText(GestureDetector, '4');
      await tester.ensureVisible(fourBtn);
      await tester.tap(fourBtn);
      await tester.pumpAndSettle();

      final confirmBtn4 = find.textContaining('Confirm +');
      if (confirmBtn4.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn4.first);
        await tester.pumpAndSettle();
      }

      // Score 6 runs (maximum)
      final sixBtn = find.widgetWithText(GestureDetector, '6');
      await tester.ensureVisible(sixBtn);
      await tester.tap(sixBtn);
      await tester.pumpAndSettle();

      final confirmBtn6 = find.textContaining('Confirm +');
      if (confirmBtn6.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn6.first);
        await tester.pumpAndSettle();
      }

      // Check Timeline tab
      await tester.tap(find.text('Timeline'));
      await tester.pumpAndSettle();

      expect(find.text('BOUNDARY FOUR'), findsOneWidget);
      expect(find.text('MAXIMUM SIX'), findsOneWidget);

      // Check Stats tab
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();

      // Boundary Breakdown Card should show 1 Four, 1 Six, and 10 total runs
      expect(find.textContaining('BOUNDARY BREAKDOWN'), findsOneWidget);
      expect(find.text('HEAD-TO-HEAD COMPARISON'), findsOneWidget);
      expect(find.text('1 / 1'), findsOneWidget); // Boundaries (4s / 6s)

      // Verify score synchronization in appState has serialized timeline and progression
      final updatedMatch = appState.allMatches.firstWhere((m) => m.id == match.id);
      final scoreData = updatedMatch.scoreData as Map<String, dynamic>;
      expect(scoreData['timeline'], isNotNull);
      final timelineList = scoreData['timeline'] as List;
      expect(timelineList.length, equals(3));
      expect(timelineList.any((e) => e['title'] == 'BOUNDARY FOUR'), isTrue);
      expect(timelineList.any((e) => e['title'] == 'MAXIMUM SIX'), isTrue);
      expect(scoreData['team1_fours'], equals(1));
      expect(scoreData['team1_sixes'], equals(1));
      expect(scoreData['t1_over_progress'], isNotNull);
      expect((scoreData['t1_over_progress'] as List).isNotEmpty, isTrue);
    });
  });

  group('Problem 1: Real Profile Stats after match completion (No dummy stats)', () {
    testWidgets('Real profile stats update dynamically after match completion and show real SR, Avg, 50s, 100s, wickets without mock values', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final appState = AppState();
      const realUser = UserModel(
        id: 'real_cricketer_01',
        userId: 'WS-5555',
        name: 'Rohit Verma',
        username: 'rohit_v',
        email: 'rohit@example.com',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'All-Rounder',
      );
      appState.login(realUser);

      // Create a completed match with real user batting and bowling performance:
      // Scored 60 runs off 40 balls (out, 6 fours, 2 sixes)
      // Bowled 2 overs (12 balls), conceded 14 runs, took 2 wickets
      final match = MatchModel(
        id: 'comp_cricket_match_1',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'Delhi Dynamos',
        team2Name: 'Punjab Panthers',
        team1Short: 'DEL',
        team2Short: 'PUN',
        dateTime: DateTime.now(),
        venue: 'Kotla Ground',
        status: MatchStatus.completed,
        format: 'T20 (20 Overs)',
        team1Players: const [
          MatchPlayer(id: 'real_cricketer_01', userId: 'real_cricketer_01', name: 'Rohit Verma', jerseyNumber: 45, role: 'All-Rounder'),
          MatchPlayer(id: 'p2', name: 'Shikhar D.', jerseyNumber: 25, role: 'Batter'),
        ],
        team2Players: const [
          MatchPlayer(id: 'p3', name: 'Sam C.', jerseyNumber: 17, role: 'All-Rounder'),
        ],
      );

      final scoreData = <String, dynamic>{
        'overs_limit': 20,
        'team1_score': '165/4',
        'team2_score': '140/8',
        'innings1': {
          'batting': {
            'real_cricketer_01': {
              'name': 'Rohit Verma',
              'user_id': 'real_cricketer_01',
              'runs': 60,
              'balls': 40,
              'fours': 6,
              'sixes': 2,
              'is_out': true,
              'dismissal': 'caught',
            },
            'p2': {
              'name': 'Shikhar D.',
              'runs': 40,
              'balls': 30,
              'fours': 4,
              'sixes': 1,
              'is_out': false,
            },
          },
          'bowling': {},
        },
        'innings2': {
          'batting': {},
          'bowling': {
            'real_cricketer_01': {
              'name': 'Rohit Verma',
              'user_id': 'real_cricketer_01',
              'balls': 12,
              'runs': 14,
              'wickets': 2,
              'maidens': 0,
            },
          },
        },
      };

      appState.addMatch(match);
      appState.recordMatchCompletion(
        matchId: match.id,
        resultText: 'Delhi Dynamos won by 25 runs',
        finalScoreData: scoreData,
      );

      // Verify state was accurately calculated
      final stats = appState.currentUser!.stats[SportType.cricket]!;
      expect(stats.specificStats['runs'], equals(60));
      expect(stats.specificStats['batting_avg'], equals('60.0'));
      expect(stats.specificStats['strike_rate'], equals('150.0')); // 60/40 * 100
      expect(stats.specificStats['fifties'], equals(1));
      expect(stats.specificStats['hundreds'], equals(0));
      expect(stats.specificStats['wickets'], equals(2));
      expect(stats.specificStats['balls_bowled'], equals(12));
      expect(stats.specificStats['runs_conceded'], equals(14));
      expect(stats.specificStats['economy'], equals('7.00')); // 14 / 2.0
      expect(stats.specificStats['best_bowling'], equals('2/14'));

      // Render ProfileScreen and verify user sees real values and NO dummy values
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check real calculated stats on ProfileScreen
      expect(find.text('60'), findsOneWidget); // CAREER RUNS
      expect(find.text('60.0'), findsOneWidget); // BATTING AVG
      expect(find.text('150.0'), findsOneWidget); // STRIKE RATE
      expect(find.text('0/1'), findsOneWidget); // 100s / 50s

      // Absolutely NO dummy values from old mock fallback
      expect(find.text('1,842'), findsNothing);
      expect(find.text('41.2'), findsNothing);
      expect(find.text('138.4'), findsNothing);
      expect(find.text('3/12'), findsNothing);
    });
  });

  group('Problem 2: Dedicated Stats Screen / Window across sports and cricket formats', () {
    testWidgets('DedicatedStatsScreen renders full proper page with Batting and Bowling breakdowns and format filtering', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final appState = AppState();
      const realUser = UserModel(
        id: 'real_cricketer_02',
        userId: 'WS-7777',
        name: 'Virat Patel',
        username: 'virat_p',
        email: 'virat@example.com',
        role: UserRole.player,
        sports: [SportType.cricket, SportType.football],
        primarySport: SportType.cricket,
        primaryRole: 'Top-Order Batter',
      );
      appState.login(realUser);

      // Add a T20 match
      final t20Match = PreviousMatchModel(
        id: 'pm_t20_1',
        sport: SportType.cricket,
        team1Name: 'RCB Titans',
        team2Name: 'CSK Kings',
        team1Short: 'RCB',
        team2Short: 'CSK',
        team1Score: '180/3',
        team2Score: '160/7',
        resultText: 'RCB Titans won by 20 runs',
        isWin: true,
        date: DateTime.now().subtract(const Duration(days: 2)),
        venue: 'Chinnaswamy',
        myPerformance: '75*(45)',
        userId: 'real_cricketer_02',
        format: 'T20 (20 Overs)',
        rawScoreData: {
          'overs_limit': 20,
          'innings1': {
            'batting': {
              'real_cricketer_02': {
                'name': 'Virat Patel',
                'user_id': 'real_cricketer_02',
                'runs': 75,
                'balls': 45,
                'fours': 8,
                'sixes': 3,
                'is_out': false,
                'dismissal': 'not out',
              },
            },
            'bowling': {},
          },
          'innings2': {
            'batting': {},
            'bowling': {
              'real_cricketer_02': {
                'name': 'Virat Patel',
                'user_id': 'real_cricketer_02',
                'balls': 6,
                'runs': 8,
                'wickets': 1,
                'maidens': 0,
              },
            },
          },
        },
      );

      // Add an ODI match
      final odiMatch = PreviousMatchModel(
        id: 'pm_odi_1',
        sport: SportType.cricket,
        team1Name: 'India Blues',
        team2Name: 'Aussie Golds',
        team1Short: 'IND',
        team2Short: 'AUS',
        team1Score: '310/6',
        team2Score: '290/10',
        resultText: 'India Blues won by 20 runs',
        isWin: true,
        date: DateTime.now().subtract(const Duration(days: 5)),
        venue: 'Wankhede',
        myPerformance: '104(98) & 2/25 (30)',
        userId: 'real_cricketer_02',
        format: 'ODI (50 Overs)',
        rawScoreData: {
          'overs_limit': 50,
          'innings1': {
            'batting': {
              'real_cricketer_02': {
                'name': 'Virat Patel',
                'user_id': 'real_cricketer_02',
                'runs': 104,
                'balls': 98,
                'fours': 11,
                'sixes': 2,
                'is_out': true,
                'dismissal': 'caught',
              },
            },
            'bowling': {},
          },
          'innings2': {
            'batting': {},
            'bowling': {
              'real_cricketer_02': {
                'name': 'Virat Patel',
                'user_id': 'real_cricketer_02',
                'balls': 30,
                'runs': 25,
                'wickets': 2,
                'maidens': 1,
              },
            },
          },
        },
      );

      appState.addPreviousMatch(t20Match);
      appState.addPreviousMatch(odiMatch);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: DedicatedStatsScreen(initialSport: SportType.cricket),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top title and athlete identification
      expect(find.text('ATHLETE STATS ARENA'), findsOneWidget);
      expect(find.textContaining('Virat Patel'), findsOneWidget);

      // Verify format filters
      expect(find.text('OVERALL'), findsWidgets);
      expect(find.text('T20 / T20I'), findsWidgets);
      expect(find.text('ODI'), findsWidgets);
      expect(find.text('TEST'), findsWidgets);
      expect(find.text('OTHER FORMATS'), findsWidgets);

      // Verify Batting section and requested metrics
      expect(find.text('BATTING CAREER RECORD'), findsOneWidget);
      expect(find.text('RUNS'), findsWidgets);
      expect(find.text('BALL FACED'), findsWidgets);
      expect(find.text('AVG'), findsWidgets);
      expect(find.text('STRIKE RATE'), findsWidgets);
      expect(find.text('50s'), findsWidgets);
      expect(find.text('100s'), findsWidgets);
      expect(find.text('HIGHEST SCORE'), findsWidgets);

      // Verify Bowling section and requested metrics
      expect(find.text('BOWLING CAREER RECORD'), findsOneWidget);
      expect(find.text('BALL BOWLED'), findsWidgets);
      expect(find.text('WICKETS'), findsWidgets);
      expect(find.text('RUN GIVEN'), findsWidgets);
      expect(find.text('AVG.'), findsWidgets);
      expect(find.text('BEST FIGURE'), findsWidgets);
      expect(find.text('ECONOMY'), findsWidgets);

      // Overall: 75 + 104 = 179 runs, 1 50, 1 100, 3 total wickets
      expect(find.text('179'), findsWidgets);

      // Tap on 'T20 / T20I' filter
      await tester.tap(find.text('T20 / T20I').first);
      await tester.pumpAndSettle();

      // T20 specific: 75 runs, 75* highest score, 1 wicket
      expect(find.text('75'), findsWidgets);
      expect(find.text('75*'), findsWidgets);

      // Tap on 'ODI' filter
      await tester.tap(find.text('ODI').first);
      await tester.pumpAndSettle();

      // ODI specific: 104 runs, 100s: 1, 50s: 0, 2 wickets
      expect(find.text('104'), findsWidgets);

      // Switch Sport to Football
      await tester.tap(find.text('FOOTBALL'));
      await tester.pumpAndSettle();

      expect(find.text('FOOTBALL CAREER ARENA'), findsOneWidget);
      expect(find.text('GOALS'), findsOneWidget);
      expect(find.text('ASSISTS'), findsOneWidget);
      expect(find.text('PASS ACCURACY'), findsOneWidget);
    });
  });
}
