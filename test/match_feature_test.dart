import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/match/match_creation_screen.dart';

void main() {
  group('Match Creation & Real Athletes Catalog Tests', () {
    test('RealAthletesCatalog provides authentic players for all supported sports', () {
      final cricketStars = RealAthletesCatalog.getAthletesForSport(SportType.cricket);
      expect(cricketStars.isNotEmpty, true);
      expect(cricketStars.any((p) => p.name.contains('Virat Kohli')), true);

      final footballStars = RealAthletesCatalog.getAthletesForSport(SportType.football);
      expect(footballStars.isNotEmpty, true);
      expect(footballStars.any((p) => p.name.contains('Sunil Chhetri')), true);

      final basketballStars = RealAthletesCatalog.getAthletesForSport(SportType.basketball);
      expect(basketballStars.isNotEmpty, true);
      expect(basketballStars.any((p) => p.name.contains('Stephen Curry')), true);

      final tennisStars = RealAthletesCatalog.getAthletesForSport(SportType.tennis);
      expect(tennisStars.isNotEmpty, true);
      expect(tennisStars.any((p) => p.name.contains('Novak Djokovic')), true);
    });

    test('MatchPlayer model instantiates and compares accurately', () {
      const p1 = MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Top-order Batter');
      const p2 = MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Top-order Batter');
      expect(p1, equals(p2));
      expect(p1.name, 'Rohit Sharma');
      expect(p1.jerseyNumber, 45);
    });
  });

  group('AppState Match Management & Lifecycle Tests', () {
    test('addMatch adds match to liveMatches and completeMatch archives it', () {
      final appState = AppState();
      final testMatch = MatchModel(
        id: 'test_match_001',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'Kolkata Strikers',
        team2Name: 'Mumbai Titans',
        team1Short: 'KS',
        team2Short: 'MT',
        dateTime: DateTime.now(),
        venue: 'Eden Arena',
        status: MatchStatus.live,
        format: 'T20 (20 Overs)',
      );

      appState.addMatch(testMatch);
      expect(appState.liveMatches.any((m) => m.id == 'test_match_001'), true);

      // Score Update
      appState.updateMatchScore('test_match_001', {
        'team1_score': '182/4',
        'team1_overs': '20.0',
        'status_text': 'Innings Break',
      });

      final updatedMatch = appState.liveMatches.firstWhere((m) => m.id == 'test_match_001');
      expect(updatedMatch.scoreData['team1_score'], '182/4');
      expect(updatedMatch.scoreData['team1_overs'], '20.0');

      // Complete Match
      appState.completeMatch('test_match_001', resultText: 'Kolkata Strikers won by 24 runs');
      expect(appState.liveMatches.any((m) => m.id == 'test_match_001'), false);
    });
  });

  group('SportPlayerRules Minimum Requirement Tests', () {
    test('Cricket requires minimum 2 players per team (Cricheroes standard)', () {
      expect(SportPlayerRules.getMinPlayers(SportType.cricket), 2);
      expect(SportPlayerRules.getMinPlayers(SportType.cricket, 'T20 (20 Overs)'), 2);
      expect(SportPlayerRules.getMinPlayers(SportType.cricket, '10-Over Blitz'), 2);
      expect(SportPlayerRules.getMinPlayers(SportType.cricket, 'ODI (50 Overs)'), 2);
      expect(SportPlayerRules.getRuleDescription(SportType.cricket).contains('2 players per team'), true);
      expect(SportPlayerRules.getRuleDescription(SportType.cricket).contains('Cricheroes'), true);
    });

    test('Football requires format-appropriate minimum players (7 for 11v11, 5 for 7v7, 3 for 5v5)', () {
      expect(SportPlayerRules.getMinPlayers(SportType.football, '11v11 Match (90m)'), 7);
      expect(SportPlayerRules.getMinPlayers(SportType.football, '7v7 Turf (40m)'), 5);
      expect(SportPlayerRules.getMinPlayers(SportType.football, '5v5 Futsal (30m)'), 3);
    });

    test('Basketball requires format-appropriate minimum players (5 for full court, 3 for 3v3)', () {
      expect(SportPlayerRules.getMinPlayers(SportType.basketball, '4x10 Mins (FIBA)'), 5);
      expect(SportPlayerRules.getMinPlayers(SportType.basketball, '4x12 Mins (Pro)'), 5);
      expect(SportPlayerRules.getMinPlayers(SportType.basketball, '3v3 Half-Court (21 pts)'), 3);
    });

    test('Tennis requires minimum players (1 for Singles, 2 for Doubles)', () {
      expect(SportPlayerRules.getMinPlayers(SportType.tennis, 'Best of 3 Sets'), 1);
      expect(SportPlayerRules.getMinPlayers(SportType.tennis, 'Doubles Match'), 2);
    });
  });

  group('CreateMatchScreen Minimum Requirement & Empty Squad Tests', () {
    testWidgets('CreateMatchScreen starts with empty squads and enforces minimum requirement', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final appState = AppState();
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: CreateMatchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 0: Sport & Format
      expect(find.text('SELECT SPORT'), findsOneWidget);
      expect(find.text('Cricket'), findsOneWidget);

      // Tap Continue to go to Step 1: Squad Lineup
      final continueButton = find.text('Continue');
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verify that squad lists are empty at start - no dummy players!
      expect(find.text('0 ATHLETES IN LINEUP'), findsOneWidget);
      expect(find.text('Squad Lineup is Empty'), findsOneWidget);
      expect(find.textContaining('Minimum Player Requirement: 2 per team'), findsOneWidget);
      expect(find.textContaining('0 / 2 Min'), findsWidgets);

      // Attempt to tap Continue with 0 players in squads
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verify validation error is shown and user stays on Step 2
      expect(find.text('Minimum Player Requirement Not Met'), findsOneWidget);
      expect(find.text('Squad Lineup is Empty'), findsOneWidget);
    });
  });
}
