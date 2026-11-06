import 'dart:math' as math;
import '../../search_service.dart';
import '../../../models/models.dart';
import 'levenshtein_distance.dart';
import 'phonetic_algorithms.dart';
import 'bm25_ranking.dart';

/// Text span boundary for UI highlighting.
class MatchHighlightSpan {
  final int start;
  final int end;

  const MatchHighlightSpan(this.start, this.end);
}

/// Rich search result containing complex algorithmic scores and explainability signals.
class SearchResultMatch {
  final SearchResultItem item;
  final double compositeScore;
  final int matchPercentage;
  final double bm25Score;
  final double fuzzyScore;
  final double authorityScore;
  final double affinityScore;
  final String matchedField;
  final String contextualSnippet;
  final List<MatchHighlightSpan> snippetHighlightSpans;
  final bool isVerifiedPro;
  final bool isExactMatch;

  const SearchResultMatch({
    required this.item,
    required this.compositeScore,
    required this.matchPercentage,
    this.bm25Score = 0.0,
    this.fuzzyScore = 0.0,
    this.authorityScore = 0.0,
    this.affinityScore = 0.0,
    this.matchedField = 'title',
    required this.contextualSnippet,
    this.snippetHighlightSpans = const [],
    this.isVerifiedPro = false,
    this.isExactMatch = false,
  });
}

/// Multi-Signal Learning-to-Rank (LTR) Composite Scoring Engine.
/// Fuses lexical BM25, phonetic match, typo tolerance, entity authority, and user affinity.
class LearningToRankEngine {
  /// Weights for composite ranking function
  static const double weightBM25 = 0.35;
  static const double weightExact = 0.25;
  static const double weightFuzzy = 0.15;
  static const double weightAuthority = 0.15;
  static const double weightAffinity = 0.10;

  /// Scores and ranks a catalog item against query terms.
  static SearchResultMatch evaluate({
    required SearchResultItem item,
    required String rawQuery,
    required List<String> queryTerms,
    double rawBm25 = 0.0,
    String? userLocation,
    SportType? preferredSport,
    SearchCategory? targetCategory,
  }) {
    final cleanQuery = rawQuery.trim().toLowerCase();
    final lowerTitle = item.title.toLowerCase();
    final lowerSub = item.subtitle.toLowerCase();
    final lowerDesc = item.description.toLowerCase();
    final lowerLoc = item.location.toLowerCase();
    final username = item.metadata['username']?.toString().toLowerCase().replaceAll('@', '') ?? '';

    // 1. Exact & Prefix Matches
    double exactScore = 0.0;
    bool isExact = false;

    if (lowerTitle == cleanQuery || username == cleanQuery) {
      exactScore = 1.0;
      isExact = true;
    } else if (lowerTitle.startsWith(cleanQuery) || username.startsWith(cleanQuery)) {
      exactScore = 0.85;
    } else if (lowerTitle.contains(cleanQuery) || username.contains(cleanQuery)) {
      exactScore = 0.70;
    } else if (lowerSub.contains(cleanQuery) || lowerDesc.contains(cleanQuery)) {
      exactScore = 0.50;
    }

    // 2. Fuzzy & Phonetic Matching
    double fuzzyScore = 0.0;
    for (final term in queryTerms) {
      final titleFuzzy = SearchStringDistance.tokenFuzzyMatch(item.title, term);
      final subFuzzy = SearchStringDistance.tokenFuzzyMatch(item.subtitle, term);
      final phoneticScore = SearchPhonetics.phoneticSimilarity(item.title, term);

      final termBest = math.max(titleFuzzy, math.max(subFuzzy * 0.8, phoneticScore * 0.9));
      if (termBest > fuzzyScore) {
        fuzzyScore = termBest;
      }
    }

    // 3. Entity Authority & Popularity
    double authorityScore = 0.2; // Base
    final isVerified = item.metadata['isVerified'] == true ||
        item.metadata['status']?.toString().contains('OFFICIAL') == true;
    if (isVerified) {
      authorityScore += 0.40;
    }

    final ratingVal = item.metadata['rating'];
    if (ratingVal is num) {
      authorityScore += (ratingVal / 5.0) * 0.25;
    }

    final membersVal = item.metadata['members'] ?? item.metadata['followers'];
    if (membersVal != null) {
      authorityScore += 0.15;
    }

    authorityScore = authorityScore.clamp(0.0, 1.0);

    // 4. Contextual Affinity (Sport & Geo proximity & Category)
    double affinityScore = 0.0;
    if (preferredSport != null && item.matchesSport(preferredSport)) {
      affinityScore += 0.40;
    }
    if (targetCategory != null && item.category == targetCategory) {
      affinityScore += 0.35;
    }
    if (userLocation != null && userLocation.isNotEmpty && userLocation != 'All Locations') {
      if (lowerLoc.contains(userLocation.toLowerCase())) {
        affinityScore += 0.35;
      }
    }
    affinityScore = affinityScore.clamp(0.0, 1.0);

    // 5. Normalized BM25 Score
    final normalizedBm25 = (rawBm25 / 15.0).clamp(0.0, 1.0);

    // Composite Final Score
    final compositeScore = (normalizedBm25 * weightBM25) +
        (exactScore * weightExact) +
        (fuzzyScore * weightFuzzy) +
        (authorityScore * weightAuthority) +
        (affinityScore * weightAffinity);

    // Confidence Percentage
    final matchPercentage = (compositeScore * 100).round().clamp(10, 99);

    // Generate contextual snippet with highlight bounds
    final snippetInfo = _generateContextualSnippet(
      title: item.title,
      subtitle: item.subtitle,
      description: item.description,
      query: cleanQuery,
    );

    return SearchResultMatch(
      item: item,
      compositeScore: compositeScore,
      matchPercentage: isExact ? 100 : matchPercentage,
      bm25Score: rawBm25,
      fuzzyScore: fuzzyScore,
      authorityScore: authorityScore,
      affinityScore: affinityScore,
      matchedField: snippetInfo.matchedField,
      contextualSnippet: snippetInfo.snippet,
      snippetHighlightSpans: snippetInfo.spans,
      isVerifiedPro: isVerified,
      isExactMatch: isExact,
    );
  }

  /// Extracts an intelligent snippet around the matched terms with highlight spans.
  static _SnippetResult _generateContextualSnippet({
    required String title,
    required String subtitle,
    required String description,
    required String query,
  }) {
    if (query.isEmpty) {
      return _SnippetResult(
        snippet: description,
        spans: const [],
        matchedField: 'title',
      );
    }

    final lowerDesc = description.toLowerCase();
    final lowerTitle = title.toLowerCase();
    final lowerSub = subtitle.toLowerCase();

    if (lowerTitle.contains(query)) {
      return _SnippetResult(
        snippet: description,
        spans: const [],
        matchedField: 'title',
      );
    }

    if (lowerSub.contains(query)) {
      return _SnippetResult(
        snippet: subtitle,
        spans: _findHighlightSpans(subtitle, query),
        matchedField: 'subtitle',
      );
    }

    final matchIdx = lowerDesc.indexOf(query);
    if (matchIdx >= 0) {
      const windowSize = 110;
      final start = math.max(0, matchIdx - 35);
      final end = math.min(description.length, matchIdx + query.length + windowSize);

      var snippet = description.substring(start, end);
      if (start > 0) snippet = '...$snippet';
      if (end < description.length) snippet = '$snippet...';

      return _SnippetResult(
        snippet: snippet,
        spans: _findHighlightSpans(snippet, query),
        matchedField: 'description',
      );
    }

    return _SnippetResult(
      snippet: description,
      spans: const [],
      matchedField: 'description',
    );
  }

  static List<MatchHighlightSpan> _findHighlightSpans(String text, String query) {
    final spans = <MatchHighlightSpan>[];
    final lower = text.toLowerCase();
    final q = query.toLowerCase();

    int start = 0;
    while ((start = lower.indexOf(q, start)) != -1) {
      spans.add(MatchHighlightSpan(start, start + q.length));
      start += q.length;
    }
    return spans;
  }
}

class _SnippetResult {
  final String snippet;
  final List<MatchHighlightSpan> spans;
  final String matchedField;

  const _SnippetResult({
    required this.snippet,
    required this.spans,
    required this.matchedField,
  });
}
