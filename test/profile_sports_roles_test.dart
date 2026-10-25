import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/profile/profile_screen.dart';

Widget createTestableProfileScreen() {
  final appState = AppState();
  appState.login(MockData.demoPlayer);
  return ChangeNotifierProvider<AppState>.value(
    value: appState,
    child: const MaterialApp(
      home: ProfileScreen(),
    ),
  );
}

void main() {
  group('Profile Screen Sports & Roles Architecture Tests', () {
    testWidgets('Header removes overall win rate and displays sports count',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableProfileScreen());
      await tester.pumpAndSettle();

      // Ensure overall "WIN RATE" text is NOT present in the passport header
      expect(find.text('FOLLOWERS'), findsOneWidget);
      expect(find.text('FOLLOWING'), findsOneWidget);
      expect(find.text('MATCHES'), findsWidgets);
      expect(find.text('SPORTS'), findsOneWidget);

      // Verify overall pie chart is removed
      expect(find.text('Sport Distribution & Win Rate'), findsNothing);
      expect(find.text('MATCH DISTRIBUTION'), findsNothing);
    });

    testWidgets('Shows basic stats for all played sports with primary role highlighted',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableProfileScreen());
      await tester.pumpAndSettle();

      // Section header exists
      expect(find.text('Played Sports & Performance'), findsOneWidget);

      // Check all 4 played sports are displayed
      expect(find.text('CRICKET'), findsWidgets);
      expect(find.text('FOOTBALL'), findsWidgets);
      expect(find.text('BASKETBALL'), findsWidgets);
      expect(find.text('TENNIS'), findsWidgets);

      // Verify primary roles are displayed on profile cards
      expect(find.text('ALL-ROUNDER (BATTING MAIN)'), findsOneWidget);
      expect(find.text('PLAYMAKER MIDFIELDER'), findsOneWidget);
      expect(find.text('POINT GUARD'), findsOneWidget);
      expect(find.text('SINGLES BASELINE AGGRESSOR'), findsOneWidget);

      // Verify primary role metrics on profile cards
      expect(find.text('CAREER RUNS'), findsOneWidget);
      expect(find.text('BATTING AVG'), findsOneWidget);
      expect(find.text('ASSISTS'), findsWidgets);
      expect(find.text('PASS ACC'), findsOneWidget);
      expect(find.text('POINTS'), findsOneWidget);

      // Verify "More Details" button is rendered on all sports cards
      expect(find.text('More Details'), findsNWidgets(4));
    });

    testWidgets(
        'Team sports exclude match wins, individual sport (Tennis) displays match wins and win rate',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableProfileScreen());
      await tester.pumpAndSettle();

      // Team sports show classification
      expect(
          find.text('Team Sport • Individual Athlete Stats'), findsNWidgets(3));

      // Individual sport classification
      expect(find.text('Individual Sport • Personal Record'), findsOneWidget);

      // Tennis card displays individual match wins / record
      expect(find.text('18W - 6L (75%)'), findsOneWidget);

      // Team sports do NOT show team wins (like "31W - 17L" or "31 WINS" on the card)
      expect(find.text('31W - 17L'), findsNothing);
      expect(find.text('22W - 14L'), findsNothing);
      expect(find.text('14W - 7L'), findsNothing);
    });

    testWidgets(
        'Tapping More Details opens Dedicated Sport Window with role switcher',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableProfileScreen());
      await tester.pumpAndSettle();

      // Tap the first "More Details" button (Cricket card)
      final moreButtons = find.text('More Details');
      await tester.tap(moreButtons.first);
      await tester.pumpAndSettle();

      // Verify Dedicated Sport Window modal opened
      expect(find.text('CRICKET ARENA WINDOW'), findsOneWidget);
      expect(find.text('DEDICATED'), findsOneWidget);
      expect(find.text('48 Matches Participated'), findsOneWidget);

      // Verify role switcher pills for Cricket are visible
      expect(find.text('BATTING (MAIN)'), findsOneWidget);
      expect(find.text('BOWLING'), findsOneWidget);
      expect(find.text('FIELDING'), findsOneWidget);

      // Default role is Batting
      expect(find.text('Batting In-Depth Performance Stats'), findsOneWidget);
      expect(find.text('CAREER RUNS'), findsWidgets);
      expect(find.text('1,842'), findsWidgets);

      // Switch to Bowling role
      await tester.tap(find.text('BOWLING'));
      await tester.pumpAndSettle();

      // Verify Bowling stats now display dynamically!
      expect(find.text('Bowling In-Depth Performance Stats'), findsOneWidget);
      expect(find.text('WICKETS'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      expect(find.text('BOWLING AVG'), findsOneWidget);
      expect(find.text('28.5'), findsOneWidget);
      expect(find.text('ECONOMY RATE'), findsOneWidget);
      expect(find.text('6.84'), findsOneWidget);
      expect(find.text('BEST BOWLING'), findsOneWidget);
      expect(find.text('4/22'), findsOneWidget);

      // Switch to Fielding role
      await tester.tap(find.text('FIELDING'));
      await tester.pumpAndSettle();

      // Verify Fielding stats display
      expect(find.text('Fielding In-Depth Performance Stats'), findsOneWidget);
      expect(find.text('CATCHES'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
      expect(find.text('DIRECT RUN OUTS'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('CLOSE DEDICATED WINDOW'));
      await tester.pumpAndSettle();
      expect(find.text('CRICKET ARENA WINDOW'), findsNothing);
    });

    testWidgets(
        'Dedicated Sport Window for Tennis shows individual tournament win records',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableProfileScreen());
      await tester.pumpAndSettle();

      // Tap Tennis card's "More Details"
      final tennisMore = find.text('More Details').last;
      await tester.tap(tennisMore);
      await tester.pumpAndSettle();

      // Verify Tennis Dedicated Window
      expect(find.text('TENNIS ARENA WINDOW'), findsOneWidget);
      expect(find.text('INDIVIDUAL SPORT'), findsOneWidget);
      expect(find.text('18 WINS  •  6 LOSSES'), findsOneWidget);
      expect(find.text('SINGLES (MAIN)'), findsOneWidget);
      expect(find.text('DOUBLES'), findsOneWidget);

      // Singles stats
      expect(find.text('MATCH RECORD'), findsOneWidget);
      expect(find.text('18W - 6L'), findsOneWidget);
      expect(find.text('ACES'), findsWidgets);
      expect(find.text('142'), findsWidgets);

      // Close modal
      await tester.tap(find.text('CLOSE DEDICATED WINDOW'));
      await tester.pumpAndSettle();
      expect(find.text('TENNIS ARENA WINDOW'), findsNothing);
    });
  });
}
