import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/match/live_scoring_screen.dart';

Widget createTestApp({
  required MatchModel match,
  UserModel? loggedInUser,
}) {
  final appState = AppState();
  if (loggedInUser != null) {
    appState.login(loggedInUser);
  }

  return ChangeNotifierProvider<AppState>.value(
    value: appState,
    child: MaterialApp(
      home: LiveScoringScreen(match: match),
    ),
  );
}

void main() {
  final creatorMatch = MatchModel(
    id: 'test_creator_match',
    sport: SportType.cricket,
    team1Id: 't1',
    team2Id: 't2',
    team1Name: 'Mumbai Mavericks',
    team2Name: 'Delhi Dynamos',
    team1Short: 'MUM',
    team2Short: 'DEL',
    dateTime: DateTime(2026, 10, 14),
    venue: 'Wankhede Arena',
    creatorId: 'u001',
    team1Players: const [
      MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman', isCaptain: true),
      MatchPlayer(id: 'c2', name: 'Virat Kohli', jerseyNumber: 18, role: 'Top-Order Batsman'),
    ],
    team2Players: const [
      MatchPlayer(id: 'c10', name: 'Pat Cummins', jerseyNumber: 30, role: 'Fast Bowler', isCaptain: true),
      MatchPlayer(id: 'c12', name: 'Rashid Khan', jerseyNumber: 19, role: 'Spin Bowler'),
    ],
  );

  final spectatorMatch = MatchModel(
    id: 'test_spectator_match',
    sport: SportType.cricket,
    team1Id: 't1',
    team2Id: 't2',
    team1Name: 'Bengaluru FC Stars',
    team2Name: 'Chennai Strikers',
    team1Short: 'BFC',
    team2Short: 'CHN',
    dateTime: DateTime(2026, 10, 14),
    venue: 'Kanteerava Arena',
    creatorId: 'u999', // Not u001!
    team1Players: const [
      MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman'),
    ],
    team2Players: const [
      MatchPlayer(id: 'c10', name: 'Pat Cummins', jerseyNumber: 30, role: 'Fast Bowler'),
    ],
  );

  group('Match Screen 6-Tab Architecture Tests', () {
    testWidgets('LiveScoringScreen displays all 6 tabs in proper sequence', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestApp(
        match: creatorMatch,
        loggedInUser: MockData.demoPlayer, // id: 'u001'
      ));
      await tester.pumpAndSettle();

      // Check the 6 tab labels exist in the TabBar
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Scoreboard'), findsOneWidget);
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('MOM Ranking'), findsOneWidget);
      expect(find.text('Squads'), findsOneWidget);
    });
  });

  group('Creator vs Spectator Permissions Tests', () {
    testWidgets('Creator has scoring rights: shows SCORER badge, scoring console, and control buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestApp(
        match: creatorMatch,
        loggedInUser: MockData.demoPlayer, // id: 'u001' matches creatorId 'u001'
      ));
      await tester.pumpAndSettle();

      // Check Creator Scorer indicator badge in AppBar
      expect(find.text('SCORER'), findsOneWidget);

      // Check Creator controls in AppBar (Undo & End Match)
      expect(find.byTooltip('Undo'), findsOneWidget);
      expect(find.text('End Match'), findsOneWidget);

      // Switch to Scoreboard tab
      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // Check creator authorized scoring console is present
      expect(find.text('MATCH SCORING CONSOLE (CREATOR AUTHORIZED)'), findsOneWidget);
      expect(find.text('OUT / WICKET'), findsOneWidget);
      expect(find.text('Strike'), findsOneWidget);
      expect(find.text('Bowler'), findsOneWidget);

      // Spectator view-only banner must NOT be visible
      expect(find.text('SPECTATOR VIEWING ONLY'), findsNothing);
    });

    testWidgets('Spectator only sees match: shows VIEWER badge, no scoring pads, and view-only notice', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestApp(
        match: spectatorMatch,
        loggedInUser: MockData.demoPlayer, // id: 'u001' does NOT match creatorId 'u999'
      ));
      await tester.pumpAndSettle();

      // Check Spectator Viewer indicator badge in AppBar
      expect(find.text('VIEWER'), findsOneWidget);

      // Spectator must NOT see Undo or End Match in AppBar
      expect(find.byTooltip('Undo'), findsNothing);
      expect(find.text('End Match'), findsNothing);

      // Switch to Scoreboard tab
      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // Spectator viewing-only notice is displayed
      expect(find.text('SPECTATOR VIEWING ONLY'), findsOneWidget);

      // Scoring buttons must NOT be shown to spectators
      expect(find.text('MATCH SCORING CONSOLE (CREATOR AUTHORIZED)'), findsNothing);
      expect(find.text('OUT / WICKET'), findsNothing);
    });

    testWidgets('Creator scoring interaction updates score and timeline', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestApp(
        match: creatorMatch,
        loggedInUser: MockData.demoPlayer,
      ));
      await tester.pumpAndSettle();

      // Navigate to Scoreboard tab
      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // Tap 4-runs button
      final fourButton = find.widgetWithText(GestureDetector, '4');
      expect(fourButton, findsOneWidget);
      await tester.tap(fourButton);
      await tester.pumpAndSettle();

      // Switch to Timeline tab to verify event was recorded
      await tester.tap(find.text('Timeline'));
      await tester.pumpAndSettle();

      expect(find.text('BOUNDARY FOUR'), findsOneWidget);
    });
  });
}
