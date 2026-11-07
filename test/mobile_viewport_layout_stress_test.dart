import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/core/theme/app_theme.dart';
import 'package:worldsports/screens/home/home_screen.dart';
import 'package:worldsports/screens/match/live_scoring_screen.dart';
import 'package:worldsports/screens/match/match_creation_screen.dart';
import 'package:worldsports/screens/profile/dedicated_stats_screen.dart';
import 'package:worldsports/screens/profile/profile_screen.dart';
import 'package:worldsports/screens/search/search_screen.dart';
import 'package:worldsports/widgets/arena_drawer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final testCricketMatch = MatchModel(
    id: 'm_cricket_stress',
    sport: SportType.cricket,
    team1Id: 't1',
    team2Id: 't2',
    team1Name: 'Shivaji Park Gymkhana Warriors',
    team2Name: 'Dadar Union Sporting Club',
    team1Short: 'SPG',
    team2Short: 'DUSC',
    dateTime: DateTime(2026, 11, 7, 14, 30),
    venue: 'Shivaji Park Ground 2, Dadar West, Mumbai',
    creatorId: 'u001',
    status: MatchStatus.live,
    format: 'T20 Championship Group Stage',
    scoreData: const {
      'team1_score': '187/4',
      'team1_overs': '19.4',
      'team2_score': '165/8',
      'team2_overs': '20.0',
      'status_text': 'SPG need 7 runs in 20 balls • Run Rate 9.35',
      'overs_limit': 20,
      'innings1': {
        'runs': 187,
        'wickets': 4,
        'balls': 118,
        'overs': '19.4',
      },
    },
    team1Players: const [
      MatchPlayer(id: 'p1', name: 'Venkatanarasimha Raju', jerseyNumber: 45, role: 'Opening Batsman'),
      MatchPlayer(id: 'p2', name: 'Shubman Gill', jerseyNumber: 77, role: 'Top-Order Batsman'),
    ],
    team2Players: const [
      MatchPlayer(id: 'p3', name: 'Jasprit Bumrah', jerseyNumber: 93, role: 'Fast Bowler'),
      MatchPlayer(id: 'p4', name: 'Mohammed Siraj', jerseyNumber: 13, role: 'Seam Bowler'),
    ],
  );

  Widget buildTestHost({
    required Widget child,
    required AppState appState,
    double textScale = 1.0,
  }) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: widget!,
          );
        },
        home: child,
      ),
    );
  }

  group('Mobile Viewport & Screen Dimensions Layout Stress Tests', () {
    // Reference Mobile Viewports Matrix
    final viewports = [
      {'name': 'Compact Budget Android (360x800)', 'size': const Size(360, 800)},
      {'name': 'Compact Small Android (360x640)', 'size': const Size(360, 640)},
      {'name': 'Standard Flagship iPhone (390x844)', 'size': const Size(390, 844)},
    ];

    for (final vp in viewports) {
      final vpName = vp['name'] as String;
      final vpSize = vp['size'] as Size;

      testWidgets('HomeScreen renders with zero RenderFlex overflow on $vpName', (tester) async {
        await tester.binding.setSurfaceSize(vpSize);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final appState = AppState();
        appState.addMatch(testCricketMatch);

        await tester.pumpWidget(
          buildTestHost(
            appState: appState,
            child: const Scaffold(body: HomeScreen()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Drag to exercise all lazy-loaded slivers
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify zero overflow exceptions
        expect(tester.takeException(), isNull);
      });

      testWidgets('LiveScoringScreen renders with zero RenderFlex overflow on $vpName', (tester) async {
        await tester.binding.setSurfaceSize(vpSize);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final appState = AppState();
        appState.addMatch(testCricketMatch);

        await tester.pumpWidget(
          buildTestHost(
            appState: appState,
            child: LiveScoringScreen(match: testCricketMatch),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify zero overflow exceptions
        expect(tester.takeException(), isNull);
      });

      testWidgets('CreateMatchScreen renders with zero RenderFlex overflow on $vpName', (tester) async {
        await tester.binding.setSurfaceSize(vpSize);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final appState = AppState();

        await tester.pumpWidget(
          buildTestHost(
            appState: appState,
            child: const CreateMatchScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify zero overflow exceptions
        expect(tester.takeException(), isNull);
      });

      testWidgets('ProfileScreen renders with zero RenderFlex overflow on $vpName', (tester) async {
        await tester.binding.setSurfaceSize(vpSize);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final appState = AppState();

        await tester.pumpWidget(
          buildTestHost(
            appState: appState,
            child: const ProfileScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify zero overflow exceptions
        expect(tester.takeException(), isNull);
      });

      testWidgets('DedicatedStatsScreen renders with zero RenderFlex overflow on $vpName', (tester) async {
        await tester.binding.setSurfaceSize(vpSize);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final appState = AppState();

        await tester.pumpWidget(
          buildTestHost(
            appState: appState,
            child: const DedicatedStatsScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify zero overflow exceptions
        expect(tester.takeException(), isNull);
      });

      testWidgets('SearchScreen renders with zero RenderFlex overflow on $vpName', (tester) async {
        await tester.binding.setSurfaceSize(vpSize);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final appState = AppState();

        await tester.pumpWidget(
          buildTestHost(
            appState: appState,
            child: const SearchScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify zero overflow exceptions
        expect(tester.takeException(), isNull);
      });

      testWidgets('ArenaDrawer renders with zero RenderFlex overflow on $vpName', (tester) async {
        await tester.binding.setSurfaceSize(vpSize);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final appState = AppState();

        await tester.pumpWidget(
          buildTestHost(
            appState: appState,
            child: const Scaffold(drawer: ArenaDrawer()),
          ),
        );
        await tester.pump();
        // Open drawer
        final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
        scaffoldState.openDrawer();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify zero overflow exceptions
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Accessibility text scaling (1.25x) renders cleanly without RenderFlex overflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final appState = AppState();
      appState.addMatch(testCricketMatch);

      await tester.pumpWidget(
        buildTestHost(
          appState: appState,
          textScale: 1.25,
          child: const Scaffold(body: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });
  });
}

