import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/services/user_storage_service.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/auth/auth_screen.dart';

Widget createTestableAuthWidget(AppState appState) {
  return ChangeNotifierProvider<AppState>.value(
    value: appState,
    child: const MaterialApp(
      home: LoginScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserStorageService & Local Persistence Tests', () {
    test('Saves and loads current user session with full JSON serialization', () async {
      const user = UserModel(
        id: 'u_test_999',
        userId: 'WS-9999',
        name: 'Rahul Sharma',
        username: 'rahul99',
        email: 'rahul@test.com',
        phone: '+91 9988776655',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'Top Order Batter',
        hasCompletedProfile: true,
        location: 'Mumbai, India',
        bio: 'Dedicated athlete',
      );

      // Save user
      await UserStorageService.saveCurrentUser(user);

      // Load user
      final loadedUser = await UserStorageService.loadCurrentUser();
      expect(loadedUser, isNotNull);
      expect(loadedUser!.id, equals('u_test_999'));
      expect(loadedUser.userId, equals('WS-9999'));
      expect(loadedUser.name, equals('Rahul Sharma'));
      expect(loadedUser.username, equals('rahul99'));
      expect(loadedUser.email, equals('rahul@test.com'));
      expect(loadedUser.role, equals(UserRole.player));
      expect(loadedUser.primarySport, equals(SportType.cricket));

      // Clear session
      await UserStorageService.clearCurrentUser();
      final clearedUser = await UserStorageService.loadCurrentUser();
      expect(clearedUser, isNull);
    });

    test('Registers new account and authenticates locally with correct credentials', () async {
      const athlete = UserModel(
        id: 'u_101',
        userId: 'WS-1010',
        name: 'Karan Mehra',
        username: 'karan_pro',
        email: 'karan@worldsports.com',
        role: UserRole.player,
        sports: [SportType.football],
        primarySport: SportType.football,
        primaryRole: 'Striker',
      );

      // Register account with password
      await UserStorageService.registerAccount(
        email: 'karan@worldsports.com',
        username: 'karan_pro',
        password: 'securePassword123',
        user: athlete,
      );

      // 1. Account existence check
      expect(await UserStorageService.accountExists(email: 'karan@worldsports.com', username: 'other'), isTrue);
      expect(await UserStorageService.accountExists(email: 'other@test.com', username: 'karan_pro'), isTrue);
      expect(await UserStorageService.accountExists(email: 'none@test.com', username: 'none'), isFalse);

      // 2. Authenticate with Email + correct password
      final authByEmail = await UserStorageService.authenticateLocal(
        emailOrUsername: 'karan@worldsports.com',
        password: 'securePassword123',
      );
      expect(authByEmail, isNotNull);
      expect(authByEmail!.name, equals('Karan Mehra'));

      // 3. Authenticate with Username + correct password
      final authByUsername = await UserStorageService.authenticateLocal(
        emailOrUsername: 'karan_pro',
        password: 'securePassword123',
      );
      expect(authByUsername, isNotNull);
      expect(authByUsername!.username, equals('karan_pro'));

      // 4. Reject incorrect password
      final failPassword = await UserStorageService.authenticateLocal(
        emailOrUsername: 'karan_pro',
        password: 'wrongPassword',
      );
      expect(failPassword, isNull);
    });

    test('Authenticates demo accounts as local fallback', () async {
      final demo = await UserStorageService.authenticateLocal(
        emailOrUsername: 'arjun@worldsports.com',
        password: 'password',
      );
      expect(demo, isNotNull);
      expect(demo!.name, equals(MockData.demoPlayer.name));
    });
  });

  group('LoginScreen UI: Mode Distinction and Forms', () {
    testWidgets('LoginScreen displays Log In mode by default with credential fields', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final appState = AppState();
      await tester.pumpWidget(createTestableAuthWidget(appState));
      await tester.pumpAndSettle();

      // Top mode switchers
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Create Account / Sign In'), findsNWidgets(2));

      // Log In Header
      expect(find.text('Welcome Back, Athlete'), findsOneWidget);
      expect(find.text('TEST DRIVE WITH DEMO ATHLETES'), findsOneWidget);

      // Credential fields
      expect(find.text('ATHLETE CREDENTIALS'), findsOneWidget);
      expect(find.text('Email Address or Username'), findsOneWidget);
      expect(find.text('Security Password'), findsOneWidget);

      // Action Button
      expect(find.text('ENTER THE ARENA'), findsOneWidget);

      // Switch prompt at bottom
      expect(find.text("Don't have an account? "), findsOneWidget);
    });

    testWidgets('Switching to Create Account / Sign In reveals registration passport fields', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final appState = AppState();
      await tester.pumpWidget(createTestableAuthWidget(appState));
      await tester.pumpAndSettle();

      // Tap on Create Account / Sign In tab
      await tester.tap(find.text('Create Account / Sign In').first);
      await tester.pumpAndSettle();

      // Verified Header changes
      expect(find.text('Create Account & Sign In'), findsOneWidget);
      expect(find.text('SELECT ATHLETE PROFILE TYPE'), findsOneWidget);
      expect(find.text('SELECT PRIMARY SPORT'), findsOneWidget);

      // Registration passport fields
      expect(find.text('ATHLETE PASSPORT REGISTRATION'), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Unique Username *'), findsOneWidget);
      expect(find.text('Email Address *'), findsOneWidget);
      expect(find.text('Security Password (min 6 chars) *'), findsOneWidget);

      // Submit Button is CREATE ACCOUNT & SIGN IN
      expect(find.text('CREATE ACCOUNT & SIGN IN'), findsOneWidget);

      // Switch prompt at bottom
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Log In to Arena'), findsOneWidget);
    });
  });
}
