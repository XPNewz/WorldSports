import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/match/match_creation_screen.dart';

void main() {
  group('Zero-Dummy Policy & Authentic User ID Verification Tests', () {
    test('RealAthletesCatalog players possess verified User IDs, usernames, and specs', () {
      final cricketStars = RealAthletesCatalog.getAthletesForSport(SportType.cricket);
      expect(cricketStars.isNotEmpty, true);

      final virat = cricketStars.firstWhere((p) => p.username == 'virat18');
      expect(virat.userId, 'WS-1002');
      expect(virat.name, 'Virat Kohli');
      expect(virat.specsSummary.contains('Right-hand bat'), true);

      final bumrah = cricketStars.firstWhere((p) => p.username == 'jasprit93');
      expect(bumrah.userId, 'WS-1004');
      expect(bumrah.role, 'Fast Bowler');
      expect(bumrah.specsSummary.contains('Yorker'), true);
    });

    test('RealOfficialsCatalog provides sanctioned Scorers and Umpires with verified IDs', () {
      final scorers = RealOfficialsCatalog.getScorers();
      expect(scorers.isNotEmpty, true);
      expect(scorers.first.userId, 'WS-OFF-001');
      expect(scorers.first.username, 'scorer_john');

      final umpires = RealOfficialsCatalog.getUmpires();
      expect(umpires.length, greaterThanOrEqualTo(2));
      expect(umpires.first.userId, 'WS-UMP-001');
      expect(umpires.first.role, 'Lead Field Umpire');
    });

    testWidgets('CreateMatchScreen enforces Zero-Dummy lookup and rejects unregistered IDs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
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

      // Go to Step 1: Squad Lineup
      final continueButton = find.text('Continue');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Open Add Athlete modal
      final addAthleteBtn = find.text('Add Player').first;
      await tester.tap(addAthleteBtn);
      await tester.pumpAndSettle();

      // Verify Zero-Dummy policy banner is visible
      expect(find.textContaining('Zero-Dummy Policy'), findsOneWidget);
      expect(find.text('User ID / Username'), findsOneWidget);

      // Try searching for an imaginary / dummy user ID
      final inputField = find.byKey(const Key('athlete_id_input'));
      await tester.enterText(inputField, 'WS-IMAGINARY-999');
      await tester.tap(find.byKey(const Key('verify_account_btn')));
      await tester.pumpAndSettle();

      // Verify that unregistered dummy player is rejected
      expect(find.text('User ID not registered on WorldSports'), findsOneWidget);
      expect(find.textContaining('sanctioned matches'), findsOneWidget);

      // Now enter a real registered user ID: WS-1002 (@virat18)
      await tester.enterText(inputField, 'WS-1002');
      await tester.tap(find.byKey(const Key('verify_account_btn')));
      await tester.pumpAndSettle();

      // Verify Verified Real Athlete preview badge is displayed
      expect(find.text('VERIFIED REAL ATHLETE'), findsOneWidget);
      expect(find.text('Virat Kohli'), findsOneWidget);
      expect(find.textContaining('@virat18 • Top-Order Batsman'), findsOneWidget);
      expect(find.text('ATHLETIC SPECIALIZATION'), findsOneWidget);
      expect(find.textContaining('Right-hand bat'), findsOneWidget);

      // Confirm and add to squad
      final confirmBtn = find.textContaining('Confirm & Add to');
      expect(confirmBtn, findsOneWidget);
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verify squad count updated to 1
      expect(find.text('1 ATHLETES IN LINEUP'), findsOneWidget);
      expect(find.text('Virat Kohli'), findsOneWidget);
    });

    testWidgets('CreateMatchScreen Step 3 displays verified Scorer and Umpires governance', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
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

      // Go to Step 1
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Add minimum 2 players for Team 1 via Verified Directory Pool
      final addBtn = find.text('Add Player').first;
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Switch to Verified Pool tab
      await tester.tap(find.text('Verified Pool'));
      await tester.pumpAndSettle();

      // Select first athlete
      await tester.tap(find.text('+ Select').first);
      await tester.pumpAndSettle();

      // Select second athlete
      await tester.tap(find.text('+ Select').first);
      await tester.pumpAndSettle();

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Switch to Team 2 tab
      await tester.tap(find.widgetWithText(AnimatedContainer, 'Delhi Dynamos'));
      await tester.pumpAndSettle();

      // Add 2 players to Team 2
      await tester.tap(find.text('Add Player').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verified Pool'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+ Select').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('+ Select').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Continue to Step 3: Start Arena
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify Step 3 displays Sanctioned Match Crew & Governance
      expect(find.text('OFFICIAL MATCH CREW & GOVERNANCE'), findsOneWidget);
      expect(find.text('ZERO-DUMMY VERIFIED'), findsOneWidget);
      expect(find.text('OFFICIAL SCORER (DIGITAL)'), findsOneWidget);
      expect(find.text('LEAD FIELD UMPIRE'), findsOneWidget);
      expect(find.text('2ND UMPIRE / LINE REFEREE'), findsOneWidget);
      expect(find.text('John Scorer'), findsOneWidget);
      expect(find.text('Nitin Kumar'), findsOneWidget);
    });
  });
}
