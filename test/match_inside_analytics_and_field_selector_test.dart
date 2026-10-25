import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/theme/app_theme.dart';
import 'package:worldsports/screens/match/widgets/cricket_field_selector.dart';
import 'package:worldsports/screens/match/widgets/match_analytics_graphs.dart';
import 'package:worldsports/screens/match/live_scoring_screen.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/state/app_state.dart';

void main() {
  group('CricHeroes & Stumps UI - Match Analytics & Cricket Field Selector Tests', () {
    testWidgets('CricketFieldSelectorSheet renders field, sectors, RHB/LHB toggle and confirms shot', (tester) async {
      CricketShotResult? capturedResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    capturedResult = await CricketFieldSelectorSheet.show(
                      context: context,
                      runs: 4,
                      isBoundary: true,
                      batsmanName: 'Rohit Sharma',
                      batsmanJersey: 45,
                      initialIsRightHand: true,
                    );
                  },
                  child: const Text('Open Field Selector'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to open field selector
      await tester.tap(find.text('Open Field Selector'));
      await tester.pumpAndSettle();

      // Check header info
      expect(find.text('Rohit Sharma'), findsOneWidget);
      expect(find.text('+4 RUNS'), findsOneWidget);
      expect(find.text('RHB (Right-Hand)'), findsOneWidget);
      expect(find.text('Skip Direction'), findsOneWidget);

      // Check quick sector chips
      expect(find.text('Extra Cover'), findsWidgets);
      expect(find.text('Point'), findsWidgets);
      expect(find.text('Third Man'), findsWidgets);
      expect(find.text('Fine Leg'), findsWidgets);

      // Tap stance switch to LHB
      await tester.tap(find.text('RHB (Right-Hand)'));
      await tester.pumpAndSettle();
      expect(find.text('LHB (Left-Hand)'), findsOneWidget);

      // Tap Point sector chip
      await tester.tap(find.text('Point').first);
      await tester.pumpAndSettle();

      // Confirm button should be visible
      expect(find.textContaining('Confirm +4 Runs'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.textContaining('Confirm +4 Runs'));
      await tester.pumpAndSettle();

      expect(capturedResult, isNotNull);
      expect(capturedResult!.runs, 4);
      expect(capturedResult!.isBoundary, true);
    });

    testWidgets('CricketWormChart renders run vs over progression with wicket markers', (tester) async {
      final t1Overs = [
        const CricketOverProgress(overNumber: 1, runsInOver: 8, cumulativeRuns: 8),
        const CricketOverProgress(overNumber: 2, runsInOver: 12, cumulativeRuns: 20),
        const CricketOverProgress(overNumber: 3, runsInOver: 6, cumulativeRuns: 26, wicketsInOver: 1, cumulativeWickets: 1),
      ];
      final t2Overs = [
        const CricketOverProgress(overNumber: 1, runsInOver: 6, cumulativeRuns: 6),
        const CricketOverProgress(overNumber: 2, runsInOver: 9, cumulativeRuns: 15),
        const CricketOverProgress(overNumber: 3, runsInOver: 10, cumulativeRuns: 25),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: CricketWormChart(
                team1Name: 'Mumbai Mavericks',
                team2Name: 'Delhi Dynamos',
                team1Short: 'MUM',
                team2Short: 'DEL',
                team1Overs: t1Overs,
                team2Overs: t2Overs,
                maxOvers: 20,
                targetRuns: 166,
              ),
            ),
          ),
        ),
      );

      expect(find.text('WORM GRAPH (RUNS VS OVERS)'), findsOneWidget);
      expect(find.textContaining('MUM:'), findsOneWidget);
      expect(find.textContaining('DEL:'), findsOneWidget);
      expect(find.text('Wicket'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('CricketManhattanChart renders runs per over bar graph and filter selector', (tester) async {
      final t1Overs = [
        const CricketOverProgress(overNumber: 1, runsInOver: 8, cumulativeRuns: 8),
        const CricketOverProgress(overNumber: 2, runsInOver: 14, cumulativeRuns: 22, wicketsInOver: 1),
      ];
      final t2Overs = [
        const CricketOverProgress(overNumber: 1, runsInOver: 6, cumulativeRuns: 6),
        const CricketOverProgress(overNumber: 2, runsInOver: 11, cumulativeRuns: 17),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CricketManhattanChart(
              team1Short: 'MUM',
              team2Short: 'DEL',
              team1Overs: t1Overs,
              team2Overs: t2Overs,
              maxOvers: 20,
            ),
          ),
        ),
      );

      expect(find.text('MANHATTAN GRAPH (RUNS PER OVER)'), findsOneWidget);
      expect(find.text('Both'), findsOneWidget);
      expect(find.text('MUM'), findsWidgets);
      expect(find.text('DEL'), findsWidgets);
      expect(find.text('Wicket Lost'), findsOneWidget);

      // Tap team filter tab
      await tester.tap(find.text('MUM').first);
      await tester.pumpAndSettle();
    });

    testWidgets('CricketBoundaryBreakdownCard and CricketWagonWheelCard render correctly', (tester) async {
      final shots = [
        const CricketShotResult(runs: 4, sector: 'Extra Cover', shotType: 'Cover Drive', angle: -0.7, distance: 0.94),
        const CricketShotResult(runs: 6, sector: 'Mid Wicket', shotType: 'Pull Shot', angle: 1.4, distance: 0.98),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const CricketBoundaryBreakdownCard(
                    team1Short: 'MUM',
                    team2Short: 'DEL',
                    team1TotalRuns: 187,
                    team2TotalRuns: 165,
                    team1Fours: 18,
                    team1Sixes: 6,
                    team2Fours: 15,
                    team2Sixes: 4,
                    team1DotBalls: 36,
                    team1TotalBalls: 110,
                    team2DotBalls: 44,
                    team2TotalBalls: 120,
                  ),
                  CricketWagonWheelCard(shots: shots),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('BOUNDARY BREAKDOWN & SCORING PROFILE'), findsOneWidget);
      expect(find.text('BOUNDARIES (4s)'), findsOneWidget);
      expect(find.text('MAXIMUMS (6s)'), findsOneWidget);
      expect(find.text('WAGON WHEEL SHOT MAP'), findsOneWidget);
      expect(find.text('4s & 6s'), findsOneWidget);
    });

    testWidgets('Football and Basketball analytics cards render timelines and stats', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const FootballMomentumTimelineCard(
                    team1Name: 'Bengaluru FC',
                    team2Name: 'Mohun Bagan',
                    team1Short: 'BFC',
                    team2Short: 'MB',
                    currentMinute: 67,
                    events: [
                      {'type': 'goal', 'team': 1, 'player': 'Suresh R.', 'minute': 23},
                      {'type': 'goal', 'team': 2, 'player': 'Kiran M.', 'minute': 41},
                    ],
                  ),
                  const BasketballLeadTrackerCard(
                    team1Short: 'GSW',
                    team2Short: 'LAL',
                    team1Score: 104,
                    team2Score: 98,
                    currentQuarter: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('TIMESTAMP VS GOAL & ATTACK MOMENTUM'), findsOneWidget);
      expect(find.text('GOAL & DISCIPLINARY LOG'), findsOneWidget);
      expect(find.textContaining('GOAL! Suresh R.'), findsOneWidget);
      expect(find.text('SCORING PROGRESSION & LEAD TRACKER'), findsOneWidget);
      expect(find.text('Quarter 4'), findsOneWidget);
    });

    testWidgets('TableTennisStatsCard renders 11-point game sets and rally stats', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: TableTennisStatsCard(
              player1Name: 'Ma Long',
              player2Name: 'Fan Zhendong',
              p1Sets: 2,
              p2Sets: 1,
              p1CurrentPoints: 9,
              p2CurrentPoints: 7,
              completedGames: [
                {'p1': 11, 'p2': 9},
                {'p1': 8, 'p2': 11},
                {'p1': 11, 'p2': 7},
              ],
            ),
          ),
        ),
      );

      expect(find.text('TABLE TENNIS OFFICIAL METRICS'), findsOneWidget);
      expect(find.text('COMPLETED GAMES'), findsOneWidget);
      expect(find.text('G1: 11-9'), findsOneWidget);
      expect(find.text('Service Points Won %'), findsOneWidget);
      expect(find.text('Smash / Attack Winners'), findsOneWidget);
      expect(find.text('Longest Rally Length'), findsOneWidget);
    });

    testWidgets('LiveScoringScreen displays Stats tab with Worm and Manhattan graphs for cricket', (tester) async {
      final appState = AppState();
      final cricketMatch = appState.liveMatches.firstWhere((m) => m.sport == SportType.cricket);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: LiveScoringScreen(match: cricketMatch),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and tabs
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);

      // Tap Stats Tab
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();

      // Verify all cricket CricHeroes/Stumps graphs are present
      expect(find.text('WORM GRAPH (RUNS VS OVERS)'), findsOneWidget);
      expect(find.text('MANHATTAN GRAPH (RUNS PER OVER)'), findsOneWidget);
      expect(find.text('BOUNDARY BREAKDOWN & SCORING PROFILE'), findsOneWidget);
      expect(find.text('WAGON WHEEL SHOT MAP'), findsOneWidget);
      expect(find.text('HEAD-TO-HEAD COMPARISON'), findsOneWidget);
    });
  });
}
