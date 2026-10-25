import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/screens/mysports/mysports_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Problem 1: Real-time Multi-User Match Addition & MySports Visibility', () {
    testWidgets('Person 2 added by Person 1 gets updated and shows immediately in MySports', (tester) async {
      // Setup Person 2 (Franky)
      const person2 = UserModel(
        id: 'user_franky_002',
        userId: 'WS-FRANKY',
        name: 'Franky Athlete',
        username: 'franky',
        email: 'franky@worldsports.test',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'Batsman',
      );

      final person2State = AppState();
      person2State.login(person2);

      // Verify initially Person 2 has no matches in MySports
      expect(person2State.liveMatches.where((m) => person2State.isUserInMatch(m, person2)).isEmpty, isTrue);
      expect(person2State.getUserPreviousMatches(person2).isEmpty, isTrue);

      // Person 1 (Abhipray) creates a game and adds Person 2 to Team 2
      final newLiveMatch = MatchModel(
        id: 'match_realtime_001',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'Abhipray XI',
        team2Name: 'Franky Warriors',
        team1Short: 'ABH',
        team2Short: 'FRA',
        dateTime: DateTime.now(),
        venue: 'Eden Gardens',
        status: MatchStatus.live,
        format: 'T20',
        creatorId: 'user_abhipray_001',
        team1Players: const [
          MatchPlayer(
            id: 'user_abhipray_001',
            userId: 'WS-ABHIPRAY',
            name: 'Abhipray Captain',
            username: '@abhipray',
            jerseyNumber: 18,
            role: 'All-Rounder',
            isCaptain: true,
          ),
        ],
        team2Players: const [
          MatchPlayer(
            id: 'user_franky_002',
            userId: 'WS-FRANKY',
            name: 'Franky Athlete',
            username: '@franky',
            jerseyNumber: 7,
            role: 'Batsman',
            isCaptain: true,
          ),
        ],
      );

      // 1. Verify isUserInMatch correctly matches Person 2
      expect(person2State.isUserInMatch(newLiveMatch, person2), isTrue);

      // 2. Simulate Person 2's device receiving the live match via Realtime
      person2State.addMatch(newLiveMatch);

      // Verify the match now appears in Person 2's live matches
      final p2Live = person2State.liveMatches.where((m) => person2State.isUserInMatch(m, person2)).toList();
      expect(p2Live.length, equals(1));
      expect(p2Live.first.id, equals('match_realtime_001'));
      expect(p2Live.first.team2Name, equals('Franky Warriors'));

      // 3. Mount MySportsScreen for Person 2 and verify UI displays LIVE match
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: person2State,
          child: const MaterialApp(
            home: MySportsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to LIVE tab (tab index 2)
      final liveTab = find.textContaining('LIVE (1)');
      expect(liveTab, findsOneWidget);
      await tester.tap(liveTab);
      await tester.pumpAndSettle();

      // Verify Person 2 sees their live match!
      expect(find.text('Abhipray XI'), findsOneWidget);
      expect(find.text('Franky Warriors'), findsOneWidget);

      // 4. Person 1 scores and finishes the match: Franky scores 42 runs, Franky's team wins
      final completionScoreData = <String, dynamic>{
        'overs_limit': 20,
        'team1_score': '150/7',
        'team2_score': '154/3',
        'innings1': {
          'batting': {
            'user_abhipray_001': {
              'name': 'Abhipray Captain',
              'user_id': 'user_abhipray_001',
              'runs': 35,
              'balls': 25,
              'fours': 3,
              'sixes': 1,
              'is_out': true,
            },
          },
          'bowling': {
            'user_franky_002': {
              'name': 'Franky Athlete',
              'user_id': 'user_franky_002',
              'balls': 12,
              'runs': 15,
              'wickets': 1,
              'maidens': 0,
            },
          },
        },
        'innings2': {
          'batting': {
            'user_franky_002': {
              'name': 'Franky Athlete',
              'user_id': 'user_franky_002',
              'runs': 42,
              'balls': 28,
              'fours': 5,
              'sixes': 1,
              'is_out': false,
            },
          },
          'bowling': {},
        },
      };

      person2State.recordMatchCompletion(
        matchId: newLiveMatch.id,
        resultText: 'Franky Warriors won by 7 wickets',
        finalScoreData: completionScoreData,
      );
      await tester.pumpAndSettle();

      // 5. Verify Previous Matches for Person 2 has the match and calculated performance
      final prevMatches = person2State.getUserPreviousMatches(person2);
      expect(prevMatches.isNotEmpty, isTrue);
      expect(prevMatches.first.id, equals('match_realtime_001'));
      expect(prevMatches.first.isWin, isTrue);
      expect(prevMatches.first.myPerformance, contains('42*'));
      expect(prevMatches.first.myPerformance, contains('1/15'));

      // Check PREVIOUS tab on MySports
      final prevTab = find.textContaining('PREVIOUS (1)');
      expect(prevTab, findsOneWidget);
      await tester.tap(prevTab);
      await tester.pumpAndSettle();

      expect(find.textContaining('FRANKY WARRIORS', findRichText: true), findsWidgets);
    });
  });

  group('Problem 2: Cross-Device Persistence and Remote Sync Without Data Loss', () {
    test('User logs in on a new device with empty local storage and restores all live & completed matches', () async {
      const userA = UserModel(
        id: 'user_cross_dev_100',
        userId: 'WS-CROSSDEV',
        name: 'Virat Kohli',
        username: 'virat_18',
        email: 'virat@worldsports.test',
        role: UserRole.player,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'Batsman',
      );

      // Simulating Device 1:
      // Device 1 completed a match where Virat scored 82*
      final completedMatch = MatchModel(
        id: 'cross_device_match_001',
        sport: SportType.cricket,
        team1Id: 't1',
        team2Id: 't2',
        team1Name: 'India',
        team2Name: 'Pakistan',
        team1Short: 'IND',
        team2Short: 'PAK',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        venue: 'Melbourne Cricket Ground',
        status: MatchStatus.completed,
        format: 'T20',
        resultText: 'India won by 4 wickets',
        creatorId: userA.id,
        team1Players: const [
          MatchPlayer(id: 'user_cross_dev_100', userId: 'WS-CROSSDEV', name: 'Virat Kohli', username: 'virat_18', jerseyNumber: 18, role: 'Batsman'),
        ],
        team2Players: const [
          MatchPlayer(id: 'p_pak_1', name: 'Shaheen Afridi', jerseyNumber: 10, role: 'Bowler'),
        ],
        scoreData: const {
          'team1_score': '160/6',
          'team2_score': '159/8',
          'innings2': {
            'batting': {
              'user_cross_dev_100': {
                'name': 'Virat Kohli',
                'user_id': 'user_cross_dev_100',
                'runs': 82,
                'balls': 53,
                'fours': 6,
                'sixes': 4,
                'is_out': false,
              },
            },
          },
        },
      );

      // Simulating Device 2:
      // Device 2 is a brand new device with blank local storage
      final device2State = AppState();
      expect(device2State.currentUser, isNull);

      // User logs in on Device 2
      device2State.login(userA);
      expect(device2State.isLoggedIn, isTrue);

      // Device 2 receives the remote match (via sync or realtime)
      device2State.addMatch(completedMatch);

      // Verify that on Device 2:
      // 1. Completed match is recognized for userA
      expect(device2State.isUserInMatch(completedMatch, userA), isTrue);

      // 2. getUserPreviousMatches dynamically computes Virat's match performance
      final userPrevious = device2State.getUserPreviousMatches(userA);
      expect(userPrevious.length, equals(1));
      expect(userPrevious.first.id, equals('cross_device_match_001'));
      expect(userPrevious.first.myPerformance, contains('82*'));
      expect(userPrevious.first.isWin, isTrue);

      // 3. User's career stats are recomputed from the restored matches
      device2State.syncUserCareerStats();
      final stats = device2State.currentUser!.stats[SportType.cricket];
      expect(stats, isNotNull);
      expect(stats!.matchesPlayed, greaterThanOrEqualTo(1));
      expect(stats.wins, greaterThanOrEqualTo(1));
      expect(stats.specificStats['runs'], equals(82));
    });
  });
}
