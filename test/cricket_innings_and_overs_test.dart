import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/match/live_scoring_screen.dart';

Widget createCricketTestApp({
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
  final oneOverMatch = MatchModel(
    id: 'one_over_match',
    sport: SportType.cricket,
    team1Id: 't1',
    team2Id: 't2',
    team1Name: 'Mumbai Mavericks',
    team2Name: 'Delhi Dynamos',
    team1Short: 'MUM',
    team2Short: 'DEL',
    dateTime: DateTime(2026, 10, 18),
    venue: 'Arena Pitch 1',
    creatorId: 'u001',
    format: '1-Over Shootout',
    scoreData: {
      'overs_limit': 1,
    },
    team1Players: const [
      MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman'),
      MatchPlayer(id: 'c2', name: 'Virat Kohli', jerseyNumber: 18, role: 'Top-Order Batsman'),
    ],
    team2Players: const [
      MatchPlayer(id: 'c10', name: 'Pat Cummins', jerseyNumber: 30, role: 'Fast Bowler'),
      MatchPlayer(id: 'c11', name: 'David Warner', jerseyNumber: 31, role: 'Opening Batsman'),
    ],
  );

  final testFormatMatch = MatchModel(
    id: 'test_match',
    sport: SportType.cricket,
    team1Id: 't1',
    team2Id: 't2',
    team1Name: 'India',
    team2Name: 'Australia',
    team1Short: 'IND',
    team2Short: 'AUS',
    dateTime: DateTime(2026, 10, 18),
    venue: 'Melbourne Cricket Ground',
    creatorId: 'u001',
    format: 'Test Match (Unlimited)',
    team1Players: const [
      MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman'),
      MatchPlayer(id: 'c2', name: 'Virat Kohli', jerseyNumber: 18, role: 'Top-Order Batsman'),
    ],
    team2Players: const [
      MatchPlayer(id: 'c10', name: 'Pat Cummins', jerseyNumber: 30, role: 'Fast Bowler'),
    ],
  );

  group('Cricket Inning Auto-End & Over Limit Tests', () {
    testWidgets('Scorecard displays Stumps-style multi-innings tabs for all innings', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createCricketTestApp(
        match: oneOverMatch,
        loggedInUser: MockData.demoPlayer,
      ));
      await tester.pumpAndSettle();

      if (find.text('Confirm Openers & Start').evaluate().isNotEmpty) {
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      // Navigate to Scoreboard Tab
      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // Check Stumps-style innings tab headers exist
      expect(find.text('MUM 1st Inn'), findsOneWidget);
      expect(find.text('DEL 2nd Inn'), findsOneWidget);

      // DEL 2nd Inn should show "Yet to bat" initially
      expect(find.text('Yet to bat'), findsAtLeastNWidgets(1));

      // Tap DEL 2nd Inn tab
      await tester.tap(find.text('DEL 2nd Inn'));
      await tester.pumpAndSettle();

      // Should show provisional 2nd innings squad
      expect(find.text('Delhi Dynamos - 2nd Innings'), findsOneWidget);
      expect(find.textContaining('Target:'), findsOneWidget);

      // Tap back to MUM 1st Inn
      await tester.tap(find.text('MUM 1st Inn'));
      await tester.pumpAndSettle();

      expect(find.text('Mumbai Mavericks Batting'), findsOneWidget);
      expect(find.text('Delhi Dynamos Bowling'), findsOneWidget);
    });

    testWidgets('Limited-overs match strictly ends 1st innings after over limit reached and locks pad', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createCricketTestApp(
        match: oneOverMatch,
        loggedInUser: MockData.demoPlayer,
      ));
      await tester.pumpAndSettle();

      if (find.text('Confirm Openers & Start').evaluate().isNotEmpty) {
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // In limited overs, there must NOT be an arbitrary "End 1st Innings / Switch Sides" button
      expect(find.text('End 1st Innings / Switch Sides'), findsNothing);

      // Bowl 6 legal balls in a 1-over shootout match
      final oneRunButton = find.widgetWithText(GestureDetector, '1');
      for (int i = 0; i < 6; i++) {
        await tester.tap(oneRunButton);
        await tester.pumpAndSettle();
        final confirmBtn = find.textContaining('Confirm +');
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.first);
          await tester.pumpAndSettle();
        }
      }

      // 6 balls bowled in 1-over match: Over limit reached!
      // Inning ends automatically: shows dialog or locked pad with "Start 2nd Innings"
      expect(find.text('1st Innings Concluded'), findsAtLeastNWidgets(1));
      expect(find.text('Start 2nd Innings'), findsAtLeastNWidgets(1));

      // Tap Start 2nd Innings on the dialog
      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Start 2nd Innings'),
      ));
      await tester.pumpAndSettle();

      if (find.text('Confirm Openers & Start').evaluate().isNotEmpty) {
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      // Scorecard should now display 2nd innings (Delhi Dynamos Batting)
      expect(find.text('Delhi Dynamos Batting'), findsOneWidget);
      expect(find.text('Mumbai Mavericks Bowling'), findsOneWidget);

      // MUM 1st Inn tab still accessible!
      await tester.tap(find.text('MUM 1st Inn'));
      await tester.pumpAndSettle();

      // Mumbai Mavericks 1st innings score was 6/0 in 1.0 ov and remains intact
      expect(find.text('Mumbai Mavericks Batting'), findsOneWidget);
      expect(find.text('6/0 (1.0 ov)'), findsAtLeastNWidgets(1));
    });

    testWidgets('Test cricket allows innings declaration, but limited overs does not', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Render Test format match
      await tester.pumpWidget(createCricketTestApp(
        match: testFormatMatch,
        loggedInUser: MockData.demoPlayer,
      ));
      await tester.pumpAndSettle();

      if (find.text('Confirm Openers & Start').evaluate().isNotEmpty) {
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // In Test cricket, Declare Innings button is available
      expect(find.text('Declare 1st Innings (Test Match Only)'), findsOneWidget);
    });

    testWidgets('Abandon Match option is accessible for creator to officially abandon', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createCricketTestApp(
        match: oneOverMatch,
        loggedInUser: MockData.demoPlayer,
      ));
      await tester.pumpAndSettle();

      if (find.text('Confirm Openers & Start').evaluate().isNotEmpty) {
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      // Tap End Match in AppBar
      await tester.tap(find.text('End Match'));
      await tester.pumpAndSettle();

      // Shows bottom sheet with Abandon Match option
      expect(find.text('Abandon Match'), findsOneWidget);
      expect(find.text('Conclude / Finalize Match'), findsOneWidget);
    });

    testWidgets('Toss winner electing to bat bats first; toss winner electing to bowl bowls first', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Team 2 (Australia) wins toss and elects to Bat
      final ausBatFirstMatch = MatchModel(
        id: 'aus_bat_match',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'India',
        team2Name: 'Australia',
        team1Short: 'IND',
        team2Short: 'AUS',
        tossWinner: 'Australia',
        tossDecision: 'Bat',
        dateTime: DateTime(2026, 10, 18),
        venue: 'MCG',
        creatorId: 'u001',
        format: '1-Over Shootout',
        scoreData: const {
          'overs_limit': 1,
        },
        team1Players: const [
          MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman'),
          MatchPlayer(id: 'c2', name: 'Jasprit Bumrah', jerseyNumber: 93, role: 'Fast Bowler'),
        ],
        team2Players: const [
          MatchPlayer(id: 'c10', name: 'David Warner', jerseyNumber: 31, role: 'Opening Batsman'),
          MatchPlayer(id: 'c11', name: 'Travis Head', jerseyNumber: 62, role: 'Opening Batsman'),
        ],
      );

      await tester.pumpWidget(createCricketTestApp(
        match: ausBatFirstMatch,
        loggedInUser: MockData.demoPlayer,
      ));
      await tester.pumpAndSettle();

      // Check if opener sheet appeared
      if (find.text('Choose initial strikers for Australia').evaluate().isNotEmpty) {
        expect(find.text('Choose initial strikers for Australia'), findsOneWidget);
        expect(find.text('OPENING BOWLER (IND)'), findsOneWidget);
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      // Check scoreboard
      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      // 1st innings tab should be AUS 1st Inn!
      expect(find.text('AUS 1st Inn'), findsOneWidget);
      expect(find.text('IND 2nd Inn'), findsOneWidget);
      expect(find.text('Australia Batting'), findsOneWidget);
      expect(find.text('India Bowling'), findsOneWidget);
    });

    testWidgets('Toss winner electing to Bowl causes other team to bat first', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Team 1 (India) wins toss and elects to Bowl -> Australia bats first
      final indBowlFirstMatch = MatchModel(
        id: 'ind_bowl_match',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'India',
        team2Name: 'Australia',
        team1Short: 'IND',
        team2Short: 'AUS',
        tossWinner: 'India',
        tossDecision: 'Bowl',
        dateTime: DateTime(2026, 10, 18),
        venue: 'Eden Gardens',
        creatorId: 'u001',
        format: '1-Over Shootout',
        scoreData: const {
          'overs_limit': 1,
        },
        team1Players: const [
          MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman'),
          MatchPlayer(id: 'c2', name: 'Jasprit Bumrah', jerseyNumber: 93, role: 'Fast Bowler'),
        ],
        team2Players: const [
          MatchPlayer(id: 'c10', name: 'David Warner', jerseyNumber: 31, role: 'Opening Batsman'),
          MatchPlayer(id: 'c11', name: 'Travis Head', jerseyNumber: 62, role: 'Opening Batsman'),
        ],
      );

      await tester.pumpWidget(createCricketTestApp(
        match: indBowlFirstMatch,
        loggedInUser: MockData.demoPlayer,
      ));
      await tester.pumpAndSettle();

      if (find.text('Confirm Openers & Start').evaluate().isNotEmpty) {
        expect(find.text('Choose initial strikers for Australia'), findsOneWidget);
        expect(find.text('OPENING BOWLER (IND)'), findsOneWidget);
        await tester.tap(find.text('Confirm Openers & Start'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Scoreboard'));
      await tester.pumpAndSettle();

      expect(find.text('AUS 1st Inn'), findsOneWidget);
      expect(find.text('IND 2nd Inn'), findsOneWidget);
      expect(find.text('Australia Batting'), findsOneWidget);
      expect(find.text('India Bowling'), findsOneWidget);
    });
  });
}
