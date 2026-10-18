import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/core/theme/app_theme.dart';
import 'package:worldsports/screens/home/home_screen.dart';
import 'package:worldsports/screens/mysports/mysports_screen.dart';

void main() {
  Widget createTestWidget(Widget child) {
    final appState = AppState();
    appState.login(MockData.demoPlayer);
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('MySportsScreen Updates Tests', () {
    testWidgets('Header does not show athletic fixture tags or start match button', (tester) async {
      await tester.pumpWidget(createTestWidget(const MySportsScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify clean 'My Sports' title
      expect(find.text('My Sports'), findsOneWidget);

      // 2. Verify athletic fixture tags are removed
      expect(find.text('ATHLETE FIXTURES & RESULTS'), findsNothing);
      expect(find.textContaining('MATCHES RECORDED'), findsNothing);

      // 3. Verify 'START MATCH' button is removed from top of My Sports
      expect(find.text('START MATCH'), findsNothing);
    });

    testWidgets('Performance metric banner does not contain LIVE NOW', (tester) async {
      await tester.pumpWidget(createTestWidget(const MySportsScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify PLAYED, WINS, UPCOMING exist
      expect(find.text('PLAYED'), findsOneWidget);
      expect(find.text('WINS'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);

      // 2. Verify LIVE NOW is removed
      expect(find.text('LIVE NOW'), findsNothing);
    });

    testWidgets('Match segment toggle is compact in height with 3 tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(const MySportsScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify the 3 tabs exist in the compact toggle
      expect(find.textContaining('UPCOMING ('), findsOneWidget);
      expect(find.textContaining('PREVIOUS ('), findsOneWidget);
      expect(find.textContaining('LIVE ('), findsOneWidget);

      // Verify TabBar container height is 32 (half or less of the original 72px)
      final tabBarFinder = find.byType(TabBar);
      expect(tabBarFinder, findsOneWidget);
      final size = tester.getSize(tabBarFinder);
      expect(size.height, lessThanOrEqualTo(40.0));
    });
  });

  group('Homepage LIVE ARENA Tag Removal Tests', () {
    testWidgets('Homepage does not display LIVE ARENA tag in athlete bar', (tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify LIVE ARENA tag is removed
      expect(find.text('LIVE ARENA'), findsNothing);
      expect(find.textContaining('Welcome back'), findsOneWidget);
    });
  });
}
