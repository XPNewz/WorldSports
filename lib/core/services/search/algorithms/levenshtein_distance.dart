import 'dart:math' as math;

/// Advanced string distance and similarity algorithms.
/// Implements Damerau-Levenshtein (transposition-aware) and Jaro-Winkler metrics,
/// widely utilized in top search platforms (Algolia, Elasticsearch, Spotify).
class SearchStringDistance {
  /// Computes the Damerau-Levenshtein distance between strings [a] and [b].
  /// Supports:
  /// - Insertion
  /// - Deletion
  /// - Substitution
  /// - Transposition of two adjacent characters (essential for sports typos like "rohti" -> "rohit")
  static int damerauLevenshtein(String a, String b) {
    final s1 = a.toLowerCase();
    final s2 = b.toLowerCase();

    final len1 = s1.length;
    final len2 = s2.length;

    if (len1 == 0) return len2;
    if (len2 == 0) return len1;
    if (s1 == s2) return 0;

    // Fast-path for single char differences
    final maxLen = math.max(len1, len2);

    // Initialize (len1 + 2) x (len2 + 2) matrix
    final d = List.generate(
      len1 + 2,
      (_) => List<int>.filled(len2 + 2, 0),
      growable: false,
    );

    final maxDistance = len1 + len2;
    d[0][0] = maxDistance;

    for (int i = 0; i <= len1; i++) {
      d[i + 1][0] = maxDistance;
      d[i + 1][1] = i;
    }
    for (int j = 0; j <= len2; j++) {
      d[0][j + 1] = maxDistance;
      d[1][j + 1] = j;
    }

    final da = <int, int>{};

    for (int i = 1; i <= len1; i++) {
      int db = 0;
      for (int j = 1; j <= len2; j++) {
        final charCode1 = s1.codeUnitAt(i - 1);
        final charCode2 = s2.codeUnitAt(j - 1);
        final k = da[charCode2] ?? 0;
        final l = db;

        int cost = 0;
        if (charCode1 == charCode2) {
          db = j;
        } else {
          cost = 1;
        }

        d[i + 1][j + 1] = [
          d[i][j + 1] + 1, // deletion
          d[i + 1][j] + 1, // insertion
          d[i][j] + cost, // substitution
          d[k][l] + (i - k - 1) + 1 + (j - l - 1), // transposition
        ].reduce(math.min);
      }
      da[s1.codeUnitAt(i - 1)] = i;
    }

    return d[len1 + 1][len2 + 1];
  }

  /// Normalized Damerau-Levenshtein similarity score in range [0.0, 1.0].
  /// 1.0 indicates identical strings, 0.0 indicates completely dissimilar strings.
  static double normalizedLevenshtein(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final maxLen = math.max(a.length, b.length);
    final distance = damerauLevenshtein(a, b);
    return (1.0 - (distance / maxLen)).clamp(0.0, 1.0);
  }

  /// Computes Jaro similarity between [s1] and [s2].
  static double jaro(String s1, String s2) {
    final a = s1.toLowerCase();
    final b = s2.toLowerCase();

    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final matchWindow = (math.max(a.length, b.length) / 2).floor() - 1;
    final aMatches = List<bool>.filled(a.length, false);
    final bMatches = List<bool>.filled(b.length, false);

    int matches = 0;
    int transpositions = 0;

    for (int i = 0; i < a.length; i++) {
      final start = math.max(0, i - matchWindow);
      final end = math.min(i + matchWindow + 1, b.length);

      for (int j = start; j < end; j++) {
        if (bMatches[j]) continue;
        if (a[i] != b[j]) continue;
        aMatches[i] = true;
        bMatches[j] = true;
        matches++;
        break;
      }
    }

    if (matches == 0) return 0.0;

    int k = 0;
    for (int i = 0; i < a.length; i++) {
      if (!aMatches[i]) continue;
      while (!bMatches[k]) {
        k++;
      }
      if (a[i] != b[k]) {
        transpositions++;
      }
      k++;
    }

    final double m = matches.toDouble();
    return ((m / a.length) + (m / b.length) + ((m - (transpositions / 2.0)) / m)) / 3.0;
  }

  /// Computes Jaro-Winkler similarity, placing higher weight on common prefixes.
  /// Ideal for athlete names, usernames and team abbreviations (e.g. "Rohit", "Wankhede").
  static double jaroWinkler(String s1, String s2, {double prefixScale = 0.1, int maxPrefix = 4}) {
    final jaroScore = jaro(s1, s2);
    if (jaroScore < 0.7) return jaroScore;

    final a = s1.toLowerCase();
    final b = s2.toLowerCase();
    final prefixLimit = math.min(math.min(a.length, b.length), maxPrefix);

    int commonPrefix = 0;
    for (int i = 0; i < prefixLimit; i++) {
      if (a[i] == b[i]) {
        commonPrefix++;
      } else {
        break;
      }
    }

    return (jaroScore + (commonPrefix * prefixScale * (1.0 - jaroScore))).clamp(0.0, 1.0);
  }

  /// Checks if token [query] is fuzzy-matched within target [text].
  /// Returns best similarity score found across word tokens or substring sliding windows.
  static double tokenFuzzyMatch(String text, String query) {
    final cleanText = text.toLowerCase().trim();
    final cleanQuery = query.toLowerCase().trim();

    if (cleanText.isEmpty || cleanQuery.isEmpty) return 0.0;
    if (cleanText == cleanQuery) return 1.0;
    if (cleanText.startsWith(cleanQuery)) return 0.95;
    if (cleanText.contains(cleanQuery)) return 0.90;

    // Check individual words
    final words = cleanText.split(RegExp(r'[\s\-_•,]+')).where((w) => w.isNotEmpty).toList();
    double bestScore = 0.0;

    for (final word in words) {
      if (word == cleanQuery) return 1.0;
      if (word.startsWith(cleanQuery)) {
        final score = 0.85 + (0.10 * (cleanQuery.length / word.length));
        if (score > bestScore) bestScore = score;
      }

      final jw = jaroWinkler(word, cleanQuery);
      if (jw > bestScore) bestScore = jw;

      // Allow 1 edit for short words, 2 for longer words
      final dist = damerauLevenshtein(word, cleanQuery);
      final maxAllowedDist = cleanQuery.length <= 4 ? 1 : 2;
      if (dist <= maxAllowedDist) {
        final levScore = 1.0 - (dist / math.max(word.length, cleanQuery.length));
        if (levScore > bestScore) bestScore = levScore;
      }
    }

    return bestScore;
  }
}

