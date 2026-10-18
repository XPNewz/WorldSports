import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/services/search_service.dart';
import 'package:worldsports/screens/search/search_screen.dart';

void main() {
  group('SearchCatalogService Unit Tests', () {
    test('Indexes players, teams, grounds, communities, clubs, and associations', () {
      final allItems = SearchCatalogService.getAllItems();
      expect(allItems, isNotEmpty);

      final hasPlayers = allItems.any((i) => i.category == SearchCategory.players);
      final hasTeams = allItems.any((i) => i.category == SearchCategory.teams);
      final hasGrounds = allItems.any((i) => i.category == SearchCategory.grounds);
      final hasCommunities = allItems.any((i) => i.category == SearchCategory.communities);
      final hasClubs = allItems.any((i) => i.category == SearchCategory.clubs);
      final hasAssociations = allItems.any((i) => i.category == SearchCategory.associations);

      expect(hasPlayers, isTrue, reason: 'Catalog must contain players');
      expect(hasTeams, isTrue, reason: 'Catalog must contain teams');
      expect(hasGrounds, isTrue, reason: 'Catalog must contain grounds');
      expect(hasCommunities, isTrue, reason: 'Catalog must contain communities');
      expect(hasClubs, isTrue, reason: 'Catalog must contain clubs');
      expect(hasAssociations, isTrue, reason: 'Catalog must contain associations');
    });

    test('Searches and matches by name (title)', () {
      // Player name
      final playerResults = SearchCatalogService.search(query: 'Rohit Sharma');
      expect(playerResults, isNotEmpty);
      expect(playerResults.first.title, contains('Rohit Sharma'));

      // Team name
      final teamResults = SearchCatalogService.search(query: 'Mumbai Mavericks');
      expect(teamResults, isNotEmpty);
      expect(teamResults.first.title, contains('Mumbai Mavericks'));

      // Ground name
      final groundResults = SearchCatalogService.search(query: 'Wankhede');
      expect(groundResults, isNotEmpty);
      expect(groundResults.first.title, contains('Wankhede'));

      // Club name
      final clubResults = SearchCatalogService.search(query: 'All Rounders Sports Club');
      expect(clubResults, isNotEmpty);
      expect(clubResults.first.title, contains('All Rounders'));

      // Association name
      final assocResults = SearchCatalogService.search(query: 'India Multi-Sports Federation');
      expect(assocResults, isNotEmpty);
      expect(assocResults.first.title, contains('India Multi-Sports Federation'));

      // Community title
      final commResults = SearchCatalogService.search(query: 'Bangalore Footballers Collective');
      expect(commResults, isNotEmpty);
      expect(commResults.first.title, contains('Bangalore Footballers Collective'));
    });

    test('Searches and matches by description, role or facility details', () {
      // Search by description: "opening batsman"
      final batterResults = SearchCatalogService.search(query: 'opening batsman');
      expect(batterResults, isNotEmpty);
      expect(
        batterResults.any((i) => i.description.toLowerCase().contains('opening batsman') || i.subtitle.toLowerCase().contains('opening batsman')),
        isTrue,
      );

      // Search by description: "astroturf"
      final turfResults = SearchCatalogService.search(query: 'astroturf');
      expect(turfResults, isNotEmpty);
      expect(
        turfResults.any((i) => i.description.toLowerCase().contains('astroturf') || i.subtitle.toLowerCase().contains('astroturf')),
        isTrue,
      );

      // Search by description: "bylaws"
      final bylawsResults = SearchCatalogService.search(query: 'bylaws');
      expect(bylawsResults, isNotEmpty);
      expect(
        bylawsResults.any((i) => i.description.toLowerCase().contains('bylaws') || i.tags.contains('bylaws')),
        isTrue,
      );

      // Search by description: "3x3 street"
      final streetResults = SearchCatalogService.search(query: '3x3');
      expect(streetResults, isNotEmpty);
    });

    test('Filters by Category ("What to search")', () {
      final onlyGrounds = SearchCatalogService.search(
        query: '',
        category: SearchCategory.grounds,
      );
      expect(onlyGrounds, isNotEmpty);
      expect(onlyGrounds.every((i) => i.category == SearchCategory.grounds), isTrue);

      final onlyClubs = SearchCatalogService.search(
        query: '',
        category: SearchCategory.clubs,
      );
      expect(onlyClubs, isNotEmpty);
      expect(onlyClubs.every((i) => i.category == SearchCategory.clubs), isTrue);

      final onlyAssociations = SearchCatalogService.search(
        query: '',
        category: SearchCategory.associations,
      );
      expect(onlyAssociations, isNotEmpty);
      expect(onlyAssociations.every((i) => i.category == SearchCategory.associations), isTrue);

      final onlyTeams = SearchCatalogService.search(
        query: '',
        category: SearchCategory.teams,
      );
      expect(onlyTeams, isNotEmpty);
      expect(onlyTeams.every((i) => i.category == SearchCategory.teams), isTrue);

      final onlyCommunities = SearchCatalogService.search(
        query: '',
        category: SearchCategory.communities,
      );
      expect(onlyCommunities, isNotEmpty);
      expect(onlyCommunities.every((i) => i.category == SearchCategory.communities), isTrue);
    });

    test('Filters by Sports ("By sports")', () {
      final cricketResults = SearchCatalogService.search(
        query: '',
        sport: SportType.cricket,
      );
      expect(cricketResults, isNotEmpty);
      expect(
        cricketResults.every((i) => i.matchesSport(SportType.cricket) || i.sports.isEmpty),
        isTrue,
      );

      final tennisResults = SearchCatalogService.search(
        query: '',
        sport: SportType.tennis,
      );
      expect(tennisResults, isNotEmpty);
      expect(
        tennisResults.every((i) => i.matchesSport(SportType.tennis) || i.sports.isEmpty),
        isTrue,
      );

      final basketballResults = SearchCatalogService.search(
        query: '',
        sport: SportType.basketball,
      );
      expect(basketballResults, isNotEmpty);
      expect(
        basketballResults.every((i) => i.matchesSport(SportType.basketball) || i.sports.isEmpty),
        isTrue,
      );
    });

    test('Filters by Location ("Location")', () {
      final mumbaiResults = SearchCatalogService.search(
        query: '',
        location: 'Mumbai',
      );
      expect(mumbaiResults, isNotEmpty);
      expect(
        mumbaiResults.every((i) => i.location.toLowerCase().contains('mumbai')),
        isTrue,
      );

      final bangaloreResults = SearchCatalogService.search(
        query: '',
        location: 'Bangalore',
      );
      expect(bangaloreResults, isNotEmpty);
      expect(
        bangaloreResults.every((i) => i.location.toLowerCase().contains('bangalore')),
        isTrue,
      );
    });

    test('Combines Category, Sport, Location, and Query filters', () {
      // Find Cricket Grounds in Mumbai
      final results = SearchCatalogService.search(
        query: 'Wankhede',
        category: SearchCategory.grounds,
        sport: SportType.cricket,
        location: 'Mumbai',
      );

      expect(results, isNotEmpty);
      expect(results.first.title, contains('Wankhede'));
      expect(results.first.category, equals(SearchCategory.grounds));
      expect(results.first.location, contains('Mumbai'));
      expect(results.first.matchesSport(SportType.cricket), isTrue);
    });
  });

  group('SearchScreen Widget Tests', () {
    testWidgets('Renders modern search input, category chips and filter button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check search input box
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('WHAT TO SEARCH'), findsOneWidget);
      expect(find.byKey(const Key('search_filter_button')), findsOneWidget);

      // Check category chips
      expect(find.text('All'), findsWidgets);
      expect(find.text('Players'), findsOneWidget);
      expect(find.text('Teams'), findsOneWidget);
      expect(find.text('Grounds'), findsOneWidget);

      // Scroll horizontal category chip list to view remaining chips
      await tester.drag(find.text('Grounds'), const Offset(-350, 0));
      await tester.pumpAndSettle();
      expect(find.text('Clubs'), findsOneWidget);
      expect(find.text('Associations'), findsOneWidget);
    });

    testWidgets('Tapping filter icon opens modal to select sports and location and apply', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap filter icon button
      await tester.tap(find.byKey(const Key('search_filter_button')));
      await tester.pumpAndSettle();

      // Verify filter bottom sheet opened
      expect(find.text('FILTERS'), findsOneWidget);
      expect(find.text('BY SPORTS'), findsOneWidget);
      expect(find.text('LOCATION'), findsOneWidget);
      expect(find.text('APPLY FILTERS'), findsOneWidget);

      // Select Cricket inside BottomSheet
      await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Cricket')));
      await tester.pumpAndSettle();

      // Select Mumbai inside BottomSheet
      await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Mumbai')));
      await tester.pumpAndSettle();

      // Tap APPLY FILTERS
      await tester.tap(find.text('APPLY FILTERS (2)'));
      await tester.pumpAndSettle();

      // Verify modal is closed and active chips are displayed
      expect(find.text('FILTERS'), findsNothing);
      expect(find.text('CRICKET'), findsWidgets);
      expect(find.text('Mumbai'), findsWidgets);

      // Dismiss Cricket filter using 'X'
      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pumpAndSettle();

      // Only Mumbai remains
      expect(find.text('Mumbai'), findsWidgets);
    });

    testWidgets('Typing query updates results interactively', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Type "Wankhede"
      await tester.enterText(find.byType(TextField), 'Wankhede');
      await tester.pumpAndSettle();

      expect(find.textContaining('Wankhede'), findsWidgets);
      expect(find.textContaining('found'), findsOneWidget);
    });

    testWidgets('Tapping category chip filters results', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Grounds" chip
      await tester.tap(find.text('Grounds'));
      await tester.pumpAndSettle();

      // All visible results should have the GROUNDS badge
      expect(find.text('GROUNDS'), findsWidgets);
    });

    testWidgets('Tapping result card opens detail bottom sheet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(initialQuery: 'Mumbai Mavericks'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('VIEW SQUAD'), findsOneWidget);

      // Tap card CTA
      await tester.tap(find.text('VIEW SQUAD'));
      await tester.pumpAndSettle();

      // Verify bottom sheet opened
      expect(find.text('OVERVIEW & SPECIFICATIONS'), findsOneWidget);
      expect(find.text('KEY INFORMATION'), findsOneWidget);
    });

    testWidgets('Empty search shows reset button and trending terms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(initialQuery: 'NonExistentZzzzString999'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Matches Found'), findsOneWidget);
      expect(find.text('RESET ALL FILTERS'), findsOneWidget);

      // Tap RESET ALL FILTERS
      await tester.tap(find.text('RESET ALL FILTERS'));
      await tester.pumpAndSettle();

      expect(find.text('No Matches Found'), findsNothing);
    });
  });
}
