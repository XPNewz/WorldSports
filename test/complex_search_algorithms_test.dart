import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/services/search_service.dart';
import 'package:worldsports/screens/search/search_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SearchHistoryService.clearAll();
  });

  group('Algorithm 1: Damerau-Levenshtein & Jaro-Winkler Distance', () {
    test('Damerau-Levenshtein correctly handles transpositions', () {
      // Classic transposition error: "rohti" -> "rohit"
      final distance = SearchStringDistance.damerauLevenshtein('rohti', 'rohit');
      expect(distance, equals(1), reason: 'Adjacent transposition should cost 1 edit');

      // "wankede" vs "wankhede" (1 deletion)
      expect(SearchStringDistance.damerauLevenshtein('wankede', 'wankhede'), equals(1));

      // Identical strings have 0 distance
      expect(SearchStringDistance.damerauLevenshtein('dhoni', 'dhoni'), equals(0));
    });

    test('Normalized Levenshtein similarity is in range [0.0, 1.0]', () {
      final simExact = SearchStringDistance.normalizedLevenshtein('virat', 'virat');
      expect(simExact, equals(1.0));

      final simClose = SearchStringDistance.normalizedLevenshtein('virat', 'virak');
      expect(simClose, greaterThanOrEqualTo(0.8));

      final simFar = SearchStringDistance.normalizedLevenshtein('tennis', 'xyz123');
      expect(simFar, lessThan(0.3));
    });

    test('Jaro-Winkler favors common prefixes in athlete names', () {
      final jwPrefixMatch = SearchStringDistance.jaroWinkler('virat', 'viratkohli');
      final jwNonPrefixMatch = SearchStringDistance.jaroWinkler('virat', 'xyzvirat');
      expect(jwPrefixMatch, greaterThan(jwNonPrefixMatch));
    });

    test('Token fuzzy match identifies target tokens inside multi-word titles', () {
      final score = SearchStringDistance.tokenFuzzyMatch('Wankhede Arena & Ground', 'wankede');
      expect(score, greaterThanOrEqualTo(0.75));
    });
  });

  group('Algorithm 2: Phonetic Algorithms (Metaphone & Soundex)', () {
    test('Strips diacritics and accents correctly', () {
      expect(SearchPhonetics.normalizeAccents('Luka Dončić'), equals('Luka Doncic'));
      expect(SearchPhonetics.normalizeAccents('Nikola Jokić'), equals('Nikola Jokic'));
    });

    test('Soundex generates matching phonetic codes for name variations', () {
      // "Chhetri" vs "Chetri"
      final code1 = SearchPhonetics.soundex('Chhetri');
      final code2 = SearchPhonetics.soundex('Chetri');
      expect(code1, equals(code2));

      // "Bumra" vs "Bumrah"
      expect(SearchPhonetics.soundex('Bumra'), equals(SearchPhonetics.soundex('Bumrah')));
    });

    test('Sports Metaphone accurately normalizes phonetic consonants', () {
      final meta1 = SearchPhonetics.sportsMetaphone('Chhetri');
      final meta2 = SearchPhonetics.sportsMetaphone('Chetri');
      expect(meta1, equals(meta2));

      final metaBumra = SearchPhonetics.sportsMetaphone('Bumra');
      final metaBumrah = SearchPhonetics.sportsMetaphone('Bumrah');
      expect(metaBumra, equals(metaBumrah));
    });

    test('Phonetic similarity yields high confidence for phonetic variants', () {
      final sim = SearchPhonetics.phoneticSimilarity('Chhetri', 'Chetri');
      expect(sim, greaterThanOrEqualTo(0.85));
    });
  });

  group('Algorithm 3: BM25 Probabilistic Ranking', () {
    test('Calculates BM25 scores with term frequency saturation and multi-field weights', () {
      final index = BM25SearchIndex();

      index.indexDocument(
        IndexedDocument.fromFields(
          id: 'doc1',
          title: 'Wankhede Arena Cricket Ground',
          tags: ['cricket', 'pitch', 'stadium'],
          description: 'Premier floodlit cricket venue in Mumbai with red soil pitch',
        ),
      );

      index.indexDocument(
        IndexedDocument.fromFields(
          id: 'doc2',
          title: 'DLTA Tennis Arena Complex',
          tags: ['tennis', 'court'],
          description: 'Synthetic hard court tennis facility',
        ),
      );

      index.commit();

      final scores = index.scoreQuery(['cricket']);
      expect(scores.containsKey('doc1'), isTrue);
      expect(scores['doc1']!, greaterThan(0.0));
      expect(scores.containsKey('doc2'), isFalse);
    });
  });

  group('Algorithm 4: Frequency-Ranked Prefix Trie', () {
    test('Predicts autocompletions in O(k) time ordered by frequency', () {
      final trie = SearchPrefixTrie();

      trie.insert(text: 'Rohit Sharma', category: 'Players', frequency: 100);
      trie.insert(text: 'Royal Challengers', category: 'Teams', frequency: 80);
      trie.insert(text: 'Rajasthan Royals', category: 'Teams', frequency: 70);

      final suggestions = trie.predict('ro');
      expect(suggestions, isNotEmpty);
      expect(suggestions.first.text, equals('Rohit Sharma'));
      expect(suggestions.any((s) => s.text == 'Royal Challengers'), isTrue);
    });

    test('Supports multi-word prefix lookups (e.g. "sharma")', () {
      final trie = SearchPrefixTrie();
      trie.insert(text: 'Rohit Sharma', category: 'Players', frequency: 95);

      final suggestions = trie.predict('shar');
      expect(suggestions, isNotEmpty);
      expect(suggestions.first.text, equals('Rohit Sharma'));
    });
  });

  group('Algorithm 5: Semantic Intent & Query Parser', () {
    test('Extracts explicit @username intent', () {
      final intent = SportsQueryParser.parse('@virat');
      expect(intent.hasExplicitAtUsername, isTrue);
      expect(intent.cleanQuery, equals('virat'));
      expect(intent.intentType, equals(SearchIntentType.athleteProfile));
      expect(intent.detectedCategory, equals(SearchCategory.players));
    });

    test('Extracts explicit #tag intent', () {
      final intent = SportsQueryParser.parse('#cricket');
      expect(intent.intentType, equals(SearchIntentType.tagSearch));
      expect(intent.extractedTags, contains('cricket'));
    });

    test('Detects sport, category, and location from natural phrasing', () {
      final intent = SportsQueryParser.parse('football turf in Bangalore');
      expect(intent.detectedSport, equals(SportType.football));
      expect(intent.detectedCategory, equals(SearchCategory.grounds));
      expect(intent.detectedLocation, equals('Bangalore'));
      expect(intent.intentType, equals(SearchIntentType.venueBooking));
    });

    test('Extracts price budget from query string', () {
      final intent = SportsQueryParser.parse('cricket pitch under 2000');
      expect(intent.maxPrice, equals(2000));
    });
  });

  group('Algorithm 6: Intelligent "Did You Mean?" Spell Corrector', () {
    test('Suggests correct athlete name for misspelled query', () {
      final corrector = SportsSpellCorrector();
      corrector.addPhrase('Rohit Sharma');
      corrector.addPhrase('Virat Kohli');
      corrector.addPhrase('Wankhede Arena');

      // "rohot" -> "Rohit Sharma"
      final suggestion = corrector.suggestCorrection('rohot');
      expect(suggestion, equals('Rohit Sharma'));

      // "wankede" -> "Wankhede Arena"
      final venueSuggestion = corrector.suggestCorrection('wankede');
      expect(venueSuggestion, equals('Wankhede Arena'));
    });
  });

  group('Algorithm 7: Learning-to-Rank (LTR) Composite Scoring & Snippets', () {
    test('Computes multi-signal score with authority and verified bonus', () {
      const verifiedItem = SearchResultItem(
        id: 'test_1',
        title: 'Virat Kohli',
        subtitle: 'Batter • #18',
        description: 'Elite international cricket batsman and former captain.',
        category: SearchCategory.players,
        sport: SportType.cricket,
        location: 'Delhi, India',
        icon: Icons.person,
        metadata: {'isVerified': true, 'rating': 4.9},
      );

      final match = LearningToRankEngine.evaluate(
        item: verifiedItem,
        rawQuery: 'virat',
        queryTerms: ['virat'],
        rawBm25: 8.5,
      );

      expect(match.matchPercentage, greaterThanOrEqualTo(65));
      expect(match.isVerifiedPro, isTrue);
      expect(match.isExactMatch, isFalse);

      final matchFull = LearningToRankEngine.evaluate(
        item: verifiedItem,
        rawQuery: 'Virat Kohli',
        queryTerms: ['virat', 'kohli'],
        rawBm25: 12.0,
      );
      expect(matchFull.matchPercentage, equals(100));
      expect(matchFull.isExactMatch, isTrue);
    });

    test('Extracts contextual snippet surrounding matched term with highlight bounds', () {
      const item = SearchResultItem(
        id: 'test_desc',
        title: 'Central Arena',
        subtitle: 'Multi-sport venue',
        description: 'This is a long description detailing facilities including astroturf pitch and floodlights for evening games.',
        category: SearchCategory.grounds,
        location: 'Mumbai, India',
        icon: Icons.stadium,
      );

      final match = LearningToRankEngine.evaluate(
        item: item,
        rawQuery: 'astroturf',
        queryTerms: ['astroturf'],
      );

      expect(match.contextualSnippet.toLowerCase(), contains('astroturf'));
      expect(match.snippetHighlightSpans, isNotEmpty);
    });
  });

  group('SearchHistoryService Unit Tests', () {
    test('Adds, deduplicates, and limits recent searches', () async {
      await SearchHistoryService.addQuery('Rohit');
      await SearchHistoryService.addQuery('Wankhede');
      await SearchHistoryService.addQuery('Rohit'); // duplicate moves to front

      final history = await SearchHistoryService.getRecentSearches();
      expect(history.first, equals('Rohit'));
      expect(history.length, equals(2));

      await SearchHistoryService.removeQuery('Rohit');
      final updated = await SearchHistoryService.getRecentSearches();
      expect(updated, equals(['Wankhede']));

      await SearchHistoryService.clearAll();
      final empty = await SearchHistoryService.getRecentSearches();
      expect(empty, isEmpty);
    });
  });

  group('Sorting Strategies Tests', () {
    test('Ranks items by highest rating when sortStrategy is highestRated', () {
      final results = SearchCatalogService.search(
        query: '',
        category: SearchCategory.grounds,
        sortStrategy: SearchSortStrategy.highestRated,
      );

      expect(results, isNotEmpty);
      for (int i = 0; i < results.length - 1; i++) {
        final r1 = (results[i].metadata['rating'] as num?)?.toDouble() ?? 0.0;
        final r2 = (results[i + 1].metadata['rating'] as num?)?.toDouble() ?? 0.0;
        expect(r1, greaterThanOrEqualTo(r2));
      }
    });

    test('Ranks items alphabetically when sortStrategy is alphabetical', () {
      final results = SearchCatalogService.search(
        query: '',
        category: SearchCategory.teams,
        sortStrategy: SearchSortStrategy.alphabetical,
      );

      expect(results, isNotEmpty);
      for (int i = 0; i < results.length - 1; i++) {
        final cmp = results[i].title.toLowerCase().compareTo(results[i + 1].title.toLowerCase());
        expect(cmp, lessThanOrEqualTo(0));
      }
    });
  });

  group('SearchScreen Algorithmic UI Widget Tests', () {
    testWidgets('Displays predictive suggestions strip when user types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter partial term "Wan"
      await tester.enterText(find.byType(TextField), 'Wan');
      await tester.pumpAndSettle();

      // Autocomplete predictive strip appears
      expect(find.text('PREDICTIVE SUGGESTIONS'), findsOneWidget);
      expect(find.textContaining('Wankhede'), findsWidgets);

      // Tap predictive suggestion to auto-apply
      await tester.tap(find.textContaining('Wankhede').first);
      await tester.pumpAndSettle();

      // Results update with Wankhede
      expect(find.textContaining('Wankhede'), findsWidgets);
    });

    testWidgets('Displays "Did you mean?" banner when user types a typo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter typo "wankede"
      await tester.enterText(find.byType(TextField), 'wankede');
      await tester.pumpAndSettle();

      // "Did you mean" banner appears
      expect(find.textContaining('Did you mean:'), findsOneWidget);
      expect(find.text('APPLY'), findsOneWidget);

      // Tap APPLY
      await tester.tap(find.text('APPLY'));
      await tester.pumpAndSettle();

      // Search field now contains corrected term
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text.toLowerCase(), contains('wankhede'));
    });

    testWidgets('Displays sort strategy menu and changes sort order', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Sort button
      final sortBtn = find.byKey(const Key('sort_strategy_btn'));
      expect(sortBtn, findsOneWidget);
      await tester.tap(sortBtn);
      await tester.pumpAndSettle();

      // Verify menu items
      expect(find.text('Highest Rated ★'), findsOneWidget);
      expect(find.text('Alphabetical (A - Z)'), findsOneWidget);

      // Select Highest Rated
      await tester.tap(find.text('Highest Rated ★'));
      await tester.pumpAndSettle();

      expect(find.text('Highest Rated ★'), findsOneWidget);
    });
  });
}
