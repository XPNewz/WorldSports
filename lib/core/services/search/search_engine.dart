import '../search_service.dart';
import '../../models/models.dart';
import 'algorithms/bm25_ranking.dart';
import 'algorithms/prefix_trie.dart';
import 'algorithms/query_parser.dart';
import 'algorithms/spell_corrector.dart';
import 'algorithms/learning_to_rank.dart';

/// Available sorting strategies for athletic search results.
enum SearchSortStrategy {
  relevance,
  highestRated,
  mostPopular,
  alphabetical,
}

extension SearchSortStrategyExtension on SearchSortStrategy {
  String get label {
    switch (this) {
      case SearchSortStrategy.relevance:
        return 'Top Match (AI Relevance)';
      case SearchSortStrategy.highestRated:
        return 'Highest Rated ★';
      case SearchSortStrategy.mostPopular:
        return 'Most Popular';
      case SearchSortStrategy.alphabetical:
        return 'Alphabetical (A - Z)';
    }
  }
}

/// Comprehensive Search Engine combining BM25, Trie, Spell Corrector, and LTR.
class AdvancedSportsSearchEngine {
  static final AdvancedSportsSearchEngine instance = AdvancedSportsSearchEngine._internal();

  AdvancedSportsSearchEngine._internal();

  final BM25SearchIndex _bm25Index = BM25SearchIndex();
  final SearchPrefixTrie _prefixTrie = SearchPrefixTrie();
  final SportsSpellCorrector _spellCorrector = SportsSpellCorrector();

  bool _isIndexBuilt = false;
  int _lastCatalogLength = 0;

  /// Ensures index is populated with current catalog items.
  void ensureIndexBuilt(List<SearchResultItem> catalog) {
    if (_isIndexBuilt && catalog.length == _lastCatalogLength) return;

    _bm25Index.clear();
    _prefixTrie.clear();
    _spellCorrector.clear();

    for (final item in catalog) {
      // 1. Index in BM25
      final doc = IndexedDocument.fromFields(
        id: item.id,
        title: item.title,
        username: item.metadata['username']?.toString() ?? '',
        subtitle: item.subtitle,
        tags: item.tags,
        description: item.description,
        location: item.location,
      );
      _bm25Index.indexDocument(doc);

      // 2. Index in Prefix Trie for instant typeahead
      _prefixTrie.insert(
        text: item.title,
        category: item.category.label,
        entityId: item.id,
        frequency: _calculateItemPopularity(item),
        subtitle: item.subtitle,
      );

      // Also add username to trie
      final uname = item.metadata['username']?.toString();
      if (uname != null && uname.isNotEmpty) {
        _prefixTrie.insert(
          text: uname.startsWith('@') ? uname : '@$uname',
          category: 'Athletes',
          entityId: item.id,
          frequency: _calculateItemPopularity(item) + 5,
          subtitle: item.title,
        );
      }

      // 3. Index in Spell Corrector
      _spellCorrector.addPhrase(item.title);
      for (final tag in item.tags) {
        _spellCorrector.addPhrase(tag);
      }
    }

    _bm25Index.commit();
    _isIndexBuilt = true;
    _lastCatalogLength = catalog.length;
  }

  int _calculateItemPopularity(SearchResultItem item) {
    int freq = 1;
    final rating = item.metadata['rating'];
    if (rating is num) {
      freq += (rating * 3).round();
    }
    if (item.metadata['isVerified'] == true) {
      freq += 5;
    }
    return freq;
  }

  /// Evaluates query using the complete algorithmic pipeline.
  List<SearchResultMatch> executeSearch({
    required List<SearchResultItem> catalog,
    required String query,
    SearchCategory category = SearchCategory.all,
    String? location,
    SportType? sport,
    SearchSortStrategy sortStrategy = SearchSortStrategy.relevance,
    int limit = 50,
  }) {
    ensureIndexBuilt(catalog);

    final cleanQuery = query.trim();
    final parsedIntent = SportsQueryParser.parse(cleanQuery);

    // Clean location
    final cleanLocation = (location == null ||
            location.isEmpty ||
            location == 'All Locations' ||
            location == 'All')
        ? null
        : location.trim().toLowerCase();

    // Category filter: hard filter if explicitly selected
    final bool hardFilterCategory = category != SearchCategory.all;

    // Sport filter: hard filter if explicitly selected
    final bool hardFilterSport = sport != null;

    // Location filter: hard filter if explicitly selected
    final bool hardFilterLocation = cleanLocation != null;

    // Filter catalog candidates
    final candidates = catalog.where((item) {
      // Category filter
      if (hardFilterCategory && item.category != category) {
        return false;
      }

      // Sport filter
      if (hardFilterSport) {
        final matches = item.matchesSport(sport!) ||
            (item.sport == null && item.sports.isEmpty);
        if (!matches) return false;
      }

      // Location filter
      if (hardFilterLocation) {
        if (!item.location.toLowerCase().contains(cleanLocation)) {
          return false;
        }
      }

      // Max price filter (from query e.g. "under 2000")
      if (parsedIntent.maxPrice != null && item.metadata.containsKey('price')) {
        final rawPriceStr = item.metadata['price'].toString();
        final numMatch = RegExp(r'\d+').firstMatch(rawPriceStr.replaceAll(',', ''));
        if (numMatch != null) {
          final priceVal = int.tryParse(numMatch.group(0)!);
          if (priceVal != null && priceVal > parsedIntent.maxPrice!) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    // If query is blank, return candidates sorted by popularity/rating
    if (cleanQuery.isEmpty) {
      final matches = candidates.map((item) {
        return LearningToRankEngine.evaluate(
          item: item,
          rawQuery: '',
          queryTerms: const [],
          userLocation: location,
          preferredSport: sport,
        );
      }).toList();

      _applySorting(matches, sortStrategy);
      return matches.take(limit).toList();
    }

    // Tokenize query
    final queryTerms = SearchTokenizer.tokenizeWords(cleanQuery);

    // Compute BM25 scores
    final bm25Scores = _bm25Index.scoreQuery(queryTerms);

    // Evaluate each candidate through Learning-to-Rank Engine
    final scoredMatches = <SearchResultMatch>[];

    for (final item in candidates) {
      final rawBm25 = bm25Scores[item.id] ?? 0.0;

      // Check basic match eligibility: BM25 > 0, substring in title/desc/tags/subtitle, or fuzzy match
      final lowerTitle = item.title.toLowerCase();
      final lowerDesc = item.description.toLowerCase();
      final lowerSub = item.subtitle.toLowerCase();
      final lowerQ = cleanQuery.toLowerCase();
      final tagMatch = item.tags.any((t) => t.toLowerCase().contains(lowerQ));

      final hasDirectSubstr = lowerTitle.contains(lowerQ) ||
          lowerSub.contains(lowerQ) ||
          lowerDesc.contains(lowerQ) ||
          tagMatch;

      final match = LearningToRankEngine.evaluate(
        item: item,
        rawQuery: cleanQuery,
        queryTerms: queryTerms,
        rawBm25: rawBm25,
        userLocation: location ?? parsedIntent.detectedLocation,
        preferredSport: sport ?? parsedIntent.detectedSport,
        targetCategory: parsedIntent.detectedCategory,
      );

      // Keep if passes textual relevance: direct substring match, BM25 token match, or high fuzzy match
      final isRelevant = hasDirectSubstr || rawBm25 > 0 || match.fuzzyScore >= 0.75;
      if (isRelevant) {
        scoredMatches.add(match);
      }
    }

    _applySorting(scoredMatches, sortStrategy);
    return scoredMatches.take(limit).toList();
  }

  void _applySorting(List<SearchResultMatch> matches, SearchSortStrategy strategy) {
    switch (strategy) {
      case SearchSortStrategy.relevance:
        matches.sort((a, b) => b.compositeScore.compareTo(a.compositeScore));
        break;
      case SearchSortStrategy.highestRated:
        matches.sort((a, b) {
          final rA = (a.item.metadata['rating'] as num?)?.toDouble() ?? 0.0;
          final rB = (b.item.metadata['rating'] as num?)?.toDouble() ?? 0.0;
          final cmp = rB.compareTo(rA);
          if (cmp != 0) return cmp;
          return b.compositeScore.compareTo(a.compositeScore);
        });
        break;
      case SearchSortStrategy.mostPopular:
        matches.sort((a, b) {
          final popA = _getNumericMetric(a.item);
          final popB = _getNumericMetric(b.item);
          final cmp = popB.compareTo(popA);
          if (cmp != 0) return cmp;
          return b.compositeScore.compareTo(a.compositeScore);
        });
        break;
      case SearchSortStrategy.alphabetical:
        matches.sort((a, b) => a.item.title.toLowerCase().compareTo(b.item.title.toLowerCase()));
        break;
    }
  }

  double _getNumericMetric(SearchResultItem item) {
    final m = item.metadata['members'] ?? item.metadata['followers'] ?? item.metadata['matches'];
    if (m is num) return m.toDouble();
    if (m is String) {
      final clean = m.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  /// Autocomplete predictive typeahead in $O(k)$ time using the Prefix Trie.
  List<AutocompleteSuggestion> getAutocompleteSuggestions(String prefix, {int limit = 6}) {
    return _prefixTrie.predict(prefix, limit: limit);
  }

  /// Spell check query and suggest "Did you mean?" correction if available.
  String? getSpellCheckCorrection(String query) {
    return _spellCorrector.suggestCorrection(query);
  }

  /// Extracts structured intent from query.
  ParsedQueryIntent parseIntent(String query) {
    return SportsQueryParser.parse(query);
  }
}
