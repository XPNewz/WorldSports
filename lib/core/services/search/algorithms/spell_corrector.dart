import 'dart:math' as math;
import 'levenshtein_distance.dart';
import 'phonetic_algorithms.dart';

/// Intelligent "Did You Mean?" Spell Corrector.
/// Uses Damerau-Levenshtein distance, Jaro-Winkler prefix weighting, and Phonetic codes
/// to find best athlete, venue, and club corrections for misspelled queries.
class SportsSpellCorrector {
  final Map<String, int> _vocabularyFreq = {};
  final List<String> _canonicalTitles = [];

  void clear() {
    _vocabularyFreq.clear();
    _canonicalTitles.clear();
  }

  /// Ingests words and phrases into the spell-checking vocabulary.
  void addPhrase(String phrase) {
    final clean = phrase.trim();
    if (clean.isEmpty) return;

    if (!_canonicalTitles.contains(clean)) {
      _canonicalTitles.add(clean);
    }

    final words = clean
        .toLowerCase()
        .split(RegExp(r'[^\w@#]+'))
        .where((w) => w.length >= 2)
        .toList();

    for (final word in words) {
      _vocabularyFreq[word] = (_vocabularyFreq[word] ?? 0) + 1;
    }
  }

  /// Evaluates query and suggests closest correction if confident suggestion exists.
  /// Returns null if query is already correct or no strong match exists.
  String? suggestCorrection(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.length < 3) return null;

    // Check if query exactly matches a known word
    if (_vocabularyFreq.containsKey(cleanQuery)) return null;

    // Check full canonical title similarities
    String? bestTitleMatch;
    double bestTitleScore = 0.0;

    for (final title in _canonicalTitles) {
      final lowerTitle = title.toLowerCase();
      if (lowerTitle == cleanQuery) return null; // exact match already

      final jw = SearchStringDistance.jaroWinkler(cleanQuery, lowerTitle);
      final phonetic = SearchPhonetics.phoneticSimilarity(cleanQuery, lowerTitle);

      // Check sub-token matches inside title
      final titleTokens = lowerTitle.split(RegExp(r'\s+'));
      double tokenBest = 0.0;
      for (final t in titleTokens) {
        final tJw = SearchStringDistance.jaroWinkler(cleanQuery, t);
        final tPhon = SearchPhonetics.phoneticSimilarity(cleanQuery, t);
        final tDist = SearchStringDistance.damerauLevenshtein(cleanQuery, t);
        if (tDist <= 2 && tJw > tokenBest) {
          tokenBest = math.max(tJw, tPhon);
        }
      }

      final combined = math.max(jw * 0.7 + phonetic * 0.3, tokenBest);
      if (combined > 0.82 && combined > bestTitleScore) {
        bestTitleScore = combined;
        bestTitleMatch = title;
      }
    }

    if (bestTitleMatch != null) {
      return bestTitleMatch;
    }

    // Single-word vocabulary suggestions
    String? bestWordMatch;
    int lowestDistance = 999;
    int highestFreq = 0;

    for (final entry in _vocabularyFreq.entries) {
      final word = entry.key;
      final freq = entry.value;

      final dist = SearchStringDistance.damerauLevenshtein(cleanQuery, word);
      final maxAllowed = cleanQuery.length <= 4 ? 1 : 2;

      if (dist <= maxAllowed) {
        if (dist < lowestDistance || (dist == lowestDistance && freq > highestFreq)) {
          lowestDistance = dist;
          highestFreq = freq;
          bestWordMatch = word;
        }
      }
    }

    return bestWordMatch;
  }
}

