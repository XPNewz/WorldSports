import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/core/theme/app_theme.dart';
import 'package:worldsports/screens/home/home_screen.dart';
import 'package:worldsports/widgets/arena_drawer.dart';

void main() {
  Widget createTestWidget() {
    final appState = AppState();
    appState.login(MockData.demoPlayer);
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MainShell(),
      ),
    );
  }

  testWidgets('Homepage does not contain START MATCH button in athlete sub-bar', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 300));

    // Verify START MATCH button is not on homepage sub-bar
    expect(find.text('START MATCH'), findsNothing);
    // Verify LIVE ARENA tag is removed from homepage
    expect(find.text('LIVE ARENA'), findsNothing);
    expect(find.textContaining('Welcome back'), findsOneWidget);
  });

  testWidgets('Sidebar drawer opens and includes all 9 requested options', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 300));

    // Find and tap the menu icon button
    final menuButton = find.byIcon(Icons.menu_rounded);
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pump(const Duration(milliseconds: 600));

    // Verify ArenaDrawer is now open
    expect(find.byType(ArenaDrawer), findsOneWidget);

    // Verify all 9 requested options are present:
    // 1. Start Match
    expect(find.text('Start Match'), findsOneWidget);
    // 2. Add a Tournament / Series
    expect(find.text('Add a Tournament / Series'), findsOneWidget);
    // 3. Store
    expect(find.text('Store'), findsOneWidget);
    // 4. Leaderboard
    expect(find.text('Leaderboard'), findsOneWidget);
    // 5. Clubs
    expect(find.text('Clubs'), findsOneWidget);
    // 6. Associations
    expect(find.text('Associations'), findsOneWidget);
    // 7. Grounds
    expect(find.text('Grounds'), findsOneWidget);
    // 8. Help & Support
    expect(find.text('Help & Support'), findsOneWidget);
    // 9. Share Options
    expect(find.text('Share Options'), findsOneWidget);
  });
}
