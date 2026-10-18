import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/home/home_screen.dart';

void main() {
  group('Match Card Column Layout & Nearby Matches Tests', () {
    test('NearbyMatchModel resolves team names and scores accurately', () {
      const matchExplicit = NearbyMatchModel(
        id: 'nb001',
        sport: SportType.cricket,
        matchTitle: 'South Zone T20 League',
        team1Name: 'Shivaji Park Gymkhana',
        team2Name: 'Dadar Union',
        team1Score: '142/3',
        team1Overs: '16.4',
        team2Score: '138/9',
        team2Overs: '20.0',
        venue: 'Shivaji Park Arena, Ground 2',
        distance: '1.2 km away',
        statusText: 'SPG need 7 runs in 20 balls',
        isLive: true,
      );

      expect(matchExplicit.resolvedTeam1Name, equals('Shivaji Park Gymkhana'));
      expect(matchExplicit.resolvedTeam2Name, equals('Dadar Union'));
      expect(matchExplicit.team1Score, equals('142/3'));
      expect(matchExplicit.team1Overs, equals('16.4'));
      expect(matchExplicit.team2Score, equals('138/9'));
      expect(matchExplicit.team2Overs, equals('20.0'));

      const matchFallback = NearbyMatchModel(
        id: 'nb999',
        sport: SportType.football,
        matchTitle: 'Local Cup',
        teams: 'Bandra FC vs Khar United',
        venue: 'St. Andrews',
        distance: '1.0 km away',
        statusText: 'LIVE',
      );

      expect(matchFallback.resolvedTeam1Name, equals('Bandra FC'));
      expect(matchFallback.resolvedTeam2Name, equals('Khar United'));
    });

    testWidgets('HomeScreen renders match cards showing full team names in column way', (tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 1. Check Featured Match of the Day & Live Cards show full team names
      // Team 1: 'Mumbai Mavericks', Team 2: 'Delhi Dynamos'
      expect(find.text('Mumbai Mavericks'), findsWidgets);
      expect(find.text('Delhi Dynamos'), findsWidgets);

      // Verify the scores are displayed in RichText widgets
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('187/4'),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('165/8'),
        ),
        findsWidgets,
      );

      // 2. Check Nearby Matches Section displays teams individually with full names
      // Drag CustomScrollView down to reveal Nearby Matches
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Nearby Live Matches'), findsOneWidget);

      // Verify individual nearby teams are rendered as distinct widgets
      expect(find.text('Shivaji Park Gymkhana'), findsOneWidget);
      expect(find.text('Dadar Union'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('142/3'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('138/9'),
        ),
        findsOneWidget,
      );
      expect(find.text('SPG need 7 runs in 20 balls'), findsOneWidget);
      expect(find.text('1.2 km away'), findsOneWidget);
    });
  });
}
