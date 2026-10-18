import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/auth/auth_screen.dart';
import 'package:worldsports/screens/home/home_screen.dart';
import 'package:worldsports/widgets/app_logo.dart';
import 'package:worldsports/widgets/arena_drawer.dart';
import 'package:worldsports/widgets/sports_balls_loader.dart';

Widget createTestableWidget(Widget child) {
  return ChangeNotifierProvider<AppState>(
    create: (_) => AppState(),
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('App Logo & Multiple Sports Balls Loading Screen Tests', () {
    testWidgets('AppLogo widget renders with custom size and container',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppLogo(size: 60),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppLogo), findsOneWidget);
      final logoFinder = find.byType(AppLogo);
      final size = tester.getSize(logoFinder);
      expect(size.width, 60.0);
      expect(size.height, 60.0);
    });

    testWidgets('SportsBallWidget renders all 4 authentic sport ball types',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SportsBallWidget(type: SportBallType.cricket, size: 48),
                SportsBallWidget(type: SportBallType.football, size: 48),
                SportsBallWidget(type: SportBallType.tennis, size: 48),
                SportsBallWidget(type: SportBallType.basketball, size: 48),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SportsBallWidget), findsNWidgets(4));
    });

    testWidgets(
        'SportsBallsLoader displays multiple balls revolving around central logo',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SportsBallsLoader(
                size: 200,
                showCentralLogo: true,
                showStageTicker: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify loader contains central AppLogo
      expect(find.byType(AppLogo), findsOneWidget);

      // Verify all 4 sports balls (Cricket, Football, Tennis, Basketball) are present
      expect(find.byType(SportsBallWidget), findsNWidgets(4));
    });

    testWidgets(
        'SplashScreen displays pure animated motion graphics with only AppLogo and brand name (no balls, no box, no extra text)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(const SplashScreen()));
      await tester.pump();

      // Verify ONLY AppLogo and WORLDSPORTS are present
      expect(find.byType(AppLogo), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('WORLDSPORTS'),
        ),
        findsOneWidget,
      );

      // Verify NO sports balls in intro
      expect(find.byType(SportsBallsLoader), findsNothing);
      expect(find.byType(SportsBallWidget), findsNothing);

      // Verify NO extra text in intro
      expect(find.text('GLOBAL ATHLETIC ECOSYSTEM'), findsNothing);
      expect(find.text('SANCTIONED MULTI-SPORT GATEWAY'), findsNothing);
    });

    testWidgets(
        'SportsBallChangingLoader cycles sports balls with time for delay/loading states',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SportsBallChangingLoader(
                size: 50,
                showSpeedRing: true,
                showSportLabel: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Displays sports ball and label
      expect(find.byType(SportsBallChangingLoader), findsOneWidget);
      expect(find.byType(SportsBallWidget), findsOneWidget);
      expect(find.text('CRICKET'), findsOneWidget);

      // Advance time to switch ball
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('FOOTBALL'), findsOneWidget);
    });

    testWidgets('HomeScreen header displays the official AppLogo',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(const MainShell()));
      await tester.pump(const Duration(milliseconds: 100));

      // Top bar contains AppLogo and WORLDSPORTS branding
      expect(find.byType(AppLogo), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('WORLDSPORTS'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('ArenaDrawer header displays the official AppLogo',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestableWidget(
          const Scaffold(
            drawer: ArenaDrawer(),
            body: Center(child: Text('Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open drawer
      final scaffoldState =
          tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Verify drawer shows AppLogo
      expect(find.byType(ArenaDrawer), findsOneWidget);
      expect(find.descendant(
        of: find.byType(ArenaDrawer),
        matching: find.byType(AppLogo),
      ), findsOneWidget);
    });
  });
}
