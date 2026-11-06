/// Phonetic search algorithms tailored for athletic and global player names.
/// Implements Soundex and Metaphone algorithms to catch pronunciation-based spellings
/// (e.g., "Chhetri" vs "Chetri", "Bumra" vs "Bumrah", "Suryakumar" vs "Sooryakumar").
class SearchPhonetics {
  /// Strips diacritics and accents (e.g., Dončić -> Doncic, Jokić -> Jokic).
  static String normalizeAccents(String input) {
    var s = input;
    const diacritics = {
      'ć': 'c', 'č': 'c', 'ç': 'c',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ñ': 'n',
      'š': 's', 'ş': 's',
      'ž': 'z', 'ź': 'z',
    };
    for (final entry in diacritics.entries) {
      s = s.replaceAll(entry.key, entry.value);
      s = s.replaceAll(entry.key.toUpperCase(), entry.value.toUpperCase());
    }
    return s;
  }

  /// Computes the classic American Soundex code for athletic names.
  /// Generates a letter followed by 3 numeric digits (e.g., 'C360').
  static String soundex(String input) {
    final clean = normalizeAccents(input.trim().toUpperCase())
        .replaceAll(RegExp(r'[^A-Z]'), '');
    if (clean.isEmpty) return '0000';

    final firstLetter = clean[0];
    final buffer = StringBuffer(firstLetter);

    String lastCode = _soundexChar(firstLetter);

    for (int i = 1; i < clean.length; i++) {
      final code = _soundexChar(clean[i]);
      if (code != '0' && code != lastCode) {
        buffer.write(code);
        lastCode = code;
        if (buffer.length == 4) break;
      } else if (code == '0') {
        lastCode = '0';
      }
    }

    while (buffer.length < 4) {
      buffer.write('0');
    }

    return buffer.toString().substring(0, 4);
  }

  static String _soundexChar(String c) {
    switch (c) {
      case 'B':
      case 'F':
      case 'P':
      case 'V':
        return '1';
      case 'C':
      case 'G':
      case 'J':
      case 'K':
      case 'Q':
      case 'S':
      case 'X':
      case 'Z':
        return '2';
      case 'D':
      case 'T':
        return '3';
      case 'L':
        return '4';
      case 'M':
      case 'N':
        return '5';
      case 'R':
        return '6';
      default:
        return '0'; // Vowels, H, W, Y
    }
  }

  /// Computes a simplified Metaphone representation for sports names.
  /// Reduces character ambiguities (e.g. PH -> F, CH -> X, CK -> K, Double letters -> Single).
  static String sportsMetaphone(String input) {
    var s = normalizeAccents(input.trim().toUpperCase())
        .replaceAll(RegExp(r'[^A-Z]'), '');
    if (s.isEmpty) return '';

    // Handle common double-letters
    s = s.replaceAll('CHH', 'X');
    s = s.replaceAll('CH', 'X');
    s = s.replaceAll('SH', 'X');
    s = s.replaceAll('PH', 'F');
    s = s.replaceAll('CK', 'K');
    s = s.replaceAll('QU', 'K');
    s = s.replaceAll('WR', 'R');
    s = s.replaceAll('KN', 'N');
    s = s.replaceAll('GN', 'N');
    s = s.replaceAll('TH', '0');
    s = s.replaceAll('OO', 'U');
    s = s.replaceAll('EE', 'I');

    final sb = StringBuffer();
    String? prev;

    for (int i = 0; i < s.length; i++) {
      final char = s[i];
      // Skip adjacent duplicates
      if (char == prev) continue;

      // Keep first letter even if vowel; skip subsequent vowels
      if (i > 0 && 'AEIOUY'.contains(char)) {
        continue;
      }

      if (char == 'C') {
        if (i + 1 < s.length && 'EIY'.contains(s[i + 1])) {
          sb.write('S');
        } else {
          sb.write('K');
        }
      } else if (char == 'G') {
        if (i + 1 < s.length && 'EIY'.contains(s[i + 1])) {
          sb.write('J');
        } else {
          sb.write('K');
        }
      } else if (char == 'H') {
        if (i == 0 || (i + 1 < s.length && 'AEIOU'.contains(s[i + 1]))) {
          sb.write('H');
        }
      } else if (char == 'Q') {
        sb.write('K');
      } else if (char == 'Z') {
        sb.write('S');
      } else {
        sb.write(char);
      }

      prev = char;
    }

    return sb.toString();
  }

  /// Evaluates phonetic compatibility between two sports terms.
  /// Returns a confidence score in range [0.0, 1.0].
  static double phoneticSimilarity(String term1, String term2) {
    if (term1.isEmpty || term2.isEmpty) return 0.0;
    if (term1.toLowerCase() == term2.toLowerCase()) return 1.0;

    // Metaphone match
    final meta1 = sportsMetaphone(term1);
    final meta2 = sportsMetaphone(term2);
    if (meta1.isNotEmpty && meta1 == meta2) {
      return 0.95;
    }

    // Soundex match
    final sound1 = soundex(term1);
    final sound2 = soundex(term2);
    if (sound1 == sound2 && sound1 != '0000') {
      return 0.85;
    }

    // Partial metaphone prefix match
    if (meta1.isNotEmpty && meta2.isNotEmpty) {
      if (meta1.startsWith(meta2) || meta2.startsWith(meta1)) {
        return 0.70;
      }
    }

    return 0.0;
  }
}
