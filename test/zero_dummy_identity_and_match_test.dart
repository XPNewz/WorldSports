import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/services/user_storage_service.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/match/match_creation_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Strict Real-User Match Addition (Zero Dummy Players)', () {
    test('Only users with registered email or phone are eligible for matches', () {
      const realUserWithEmail = UserModel(
        id: 'u1',
        name: 'Real User 1',
        email: 'real1@sports.test',
        phone: '',
        username: 'real1',
        sports: [SportType.cricket],
        role: UserRole.player,
      );
      expect(realUserWithEmail.hasRegisteredContact, isTrue);

      const realUserWithPhone = UserModel(
        id: 'u2',
        name: 'Real User 2',
        email: '',
        phone: '+919876543210',
        username: 'real2',
        sports: [SportType.cricket],
        role: UserRole.player,
      );
      expect(realUserWithPhone.hasRegisteredContact, isTrue);

      const dummyUser = UserModel(
        id: 'dummy',
        name: 'Dummy Player',
        email: '',
        phone: '',
        username: 'dummy',
        sports: [SportType.cricket],
        role: UserRole.player,
      );
      expect(dummyUser.hasRegisteredContact, isFalse);
    });

    testWidgets('Add Athlete dialog searches by username or name and strictly requires registered email/phone', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final appState = AppState();
      const currentUser = UserModel(
        id: 'user_host',
        name: 'Host User',
        email: 'host@sports.test',
        phone: '+919999999991',
        username: 'hostuser',
        role: UserRole.player,
        sports: [SportType.cricket],
        hasCompletedProfile: true,
      );
      appState.login(currentUser);

      // Register a real teammate in local storage
      const teammate = UserModel(
        id: 'user_teammate',
        userId: 'WS-TEAMMATE-1',
        name: 'Rahul Sharma',
        email: 'rahul@sports.test',
        phone: '+919999999992',
        username: 'rahul_s',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'Batsman',
        hasCompletedProfile: true,
      );
      await UserStorageService.registerAccount(
        email: teammate.email,
        username: teammate.username,
        password: 'password123',
        user: teammate,
      );

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

      // Verify modal is open and has input field
      final inputField = find.byKey(const Key('athlete_id_input'));
      expect(inputField, findsOneWidget);

      // 1. Search for unregistered dummy user -> rejected with clear guidance
      await tester.enterText(inputField, 'dummy_nonexistent_user');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('verify_account_btn')));
      await tester.pumpAndSettle();

      // Confirm error text shows requirement for real registered profile
      expect(find.textContaining('Only real users with a profile registered via email or phone can be added'), findsWidgets);
      // Ensure NO dummy direct quick-add button exists
      expect(find.byKey(const Key('add_custom_player_btn')), findsNothing);

      // 2. Search for registered user by username '@rahul_s'
      await tester.enterText(inputField, '@rahul_s');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('verify_account_btn')));
      await tester.pumpAndSettle();

      // Verify athlete profile found with contact verification
      expect(find.text('VERIFIED REAL ATHLETE'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsWidgets);
      expect(find.textContaining('Registered: rahul@sports.test'), findsOneWidget);

      // Confirm and add to squad
      final confirmBtn = find.textContaining('Confirm & Add to');
      expect(confirmBtn, findsOneWidget);
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verify Rahul Sharma is now in the squad lineup!
      expect(find.text('Rahul Sharma'), findsWidgets);
    });
  });
}
