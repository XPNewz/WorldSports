import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/auth/auth_screen.dart';
import 'package:worldsports/widgets/app_logo.dart';
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
  group('Welcome Intro, Login & Decided Loading Area Tests', () {
    testWidgets('SplashScreen contains pure motion graphics branding without box or balls',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(const SplashScreen()));
      await tester.pump();

      // Verify AppLogo and WORLDSPORTS branding
      expect(find.byType(AppLogo), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('WORLDSPORTS'),
        ),
        findsOneWidget,
      );

      // Verify balls and chamber boxes are NOT in intro
      expect(find.byType(SportsBallsLoader), findsNothing);
      expect(find.text('GLOBAL ATHLETIC ECOSYSTEM'), findsNothing);
      expect(find.text('SANCTIONED MULTI-SPORT GATEWAY'), findsNothing);
    });

    testWidgets('OnboardingScreen renders multi-sport welcome intro slides and controls',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(const OnboardingScreen()));
      await tester.pumpAndSettle();

      // Top bar branding and Skip button
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('Skip Intro'), findsOneWidget);

      // Slide 1 title and content
      expect(find.text('MULTI-SPORT ATHLETE PASSPORT'), findsOneWidget);
      expect(find.text('Arjun Sharma'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE to move to Slide 2
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      expect(find.text('REAL-TIME MATCH ENGINE'), findsOneWidget);
      expect(find.text('LIVE MATCH DAY • FINAL OVER'), findsOneWidget);

      // Tap CONTINUE to move to Slide 3
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      expect(find.text('SANCTIONED LEAGUES & SCOUTING'), findsOneWidget);
      expect(find.text('Premier Championship 2026'), findsOneWidget);
      expect(find.text('ENTER THE ARENA'), findsOneWidget);
    });

    testWidgets('LoginScreen renders clean lock icon, athletic world branding, and segmented role selector (no 256-bit, no demo pass, no stats block)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Header Branding: Athletic World & Lock icon directly without outer box
      expect(find.text('ATHLETIC WORLD'), findsOneWidget);
      final lockFinder = find.byIcon(Icons.lock_rounded);
      expect(lockFinder, findsOneWidget);
      expect(find.text('256-BIT SECURE'), findsNothing);
      // Lock icon is rendered directly without an enclosing decorated Container box
      expect(
        find.ancestor(
          of: lockFinder,
          matching: find.byWidgetPredicate((w) => w is Container && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).border != null),
        ),
        findsNothing,
      );

      // Welcome Title
      expect(find.text('Welcome Back, Athlete'), findsOneWidget);

      // Verify removed demo pass & stats block
      expect(find.text('⚡ Demo Pass:'), findsNothing);
      expect(find.text('• Track live match scores, career stats & join team squads'), findsNothing);

      // Segmented Role Switcher
      expect(find.text('Athlete'), findsOneWidget);
      expect(find.text('Coach'), findsOneWidget);
      expect(find.text('Organiser'), findsOneWidget);

      // Default Email
      expect(find.text('arjun@worldsports.com'), findsOneWidget);

      // Tap Coach tab directly on role switcher
      await tester.tap(find.text('Coach'));
      await tester.pumpAndSettle();

      // Verify email switched to coach email
      expect(find.text('priya@worldsports.com'), findsOneWidget);

      // Submit Button is visible
      expect(find.text('ENTER THE ARENA'), findsOneWidget);
    });

    testWidgets('SpecificAreaLoader renders properly in decided blank areas',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SpecificAreaLoader(
                width: 300,
                height: 120,
                ballSize: 22,
                title: 'SYNCING ROSTER',
                subtitle: 'Connecting to sports server...',
                progress: 0.6,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SpecificAreaLoader), findsOneWidget);
      expect(find.byType(SportsBallChangingLoader), findsOneWidget);
      expect(find.text('SYNCING ROSTER'), findsOneWidget);
      expect(find.text('Connecting to sports server...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
