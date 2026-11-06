import 'dart:math' as math;
import 'phonetic_algorithms.dart';

/// Field definitions for multi-field BM25 indexing.
enum SearchField {
  title,
  username,
  subtitle,
  tags,
  description,
  location,
}

/// Tokenizer for sports queries and documents.
/// Performs accent normalization, punctuation stripping, case folding,
/// and generates word tokens alongside character n-grams for prefix/substring queries.
class SearchTokenizer {
  static final RegExp _punctuationRegex = RegExp(r'[^\w\s@#]');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  /// Tokenizes a string into normalized word tokens.
  static List<String> tokenizeWords(String text) {
    if (text.isEmpty) return const [];
    final normalized = SearchPhonetics.normalizeAccents(text.toLowerCase())
        .replaceAll(_punctuationRegex, ' ');
    return normalized
        .split(_whitespaceRegex)
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Generates character n-grams (default 2-grams and 3-grams) for partial matching.
  static List<String> generateNGrams(String word, {int minN = 2, int maxN = 4}) {
    if (word.length < minN) return [word];
    final ngrams = <String>[];
    for (int n = minN; n <= maxN; n++) {
      if (word.length < n) break;
      for (int i = 0; i <= word.length - n; i++) {
        ngrams.add(word.substring(i, i + n));
      }
    }
    return ngrams;
  }
}

/// Document representation inside the BM25 inverted index.
class IndexedDocument {
  final String id;
  final Map<SearchField, List<String>> fieldTokens;
  final Map<SearchField, Map<String, int>> fieldTermFreqs;
  final Map<SearchField, int> fieldLengths;

  IndexedDocument({
    required this.id,
    required this.fieldTokens,
    required this.fieldTermFreqs,
    required this.fieldLengths,
  });

  factory IndexedDocument.fromFields({
    required String id,
    required String title,
    String username = '',
    String subtitle = '',
    List<String> tags = const [],
    String description = '',
    String location = '',
  }) {
    final fieldTokens = <SearchField, List<String>>{};
    final fieldTermFreqs = <SearchField, Map<String, int>>{};
    final fieldLengths = <SearchField, int>{};

    void processField(SearchField field, String rawText) {
      final tokens = SearchTokenizer.tokenizeWords(rawText);
      fieldTokens[field] = tokens;
      fieldLengths[field] = tokens.length;

      final freqs = <String, int>{};
      for (final t in tokens) {
        freqs[t] = (freqs[t] ?? 0) + 1;
      }
      fieldTermFreqs[field] = freqs;
    }

    processField(SearchField.title, title);
    processField(SearchField.username, username.replaceAll('@', ''));
    processField(SearchField.subtitle, subtitle);
    processField(SearchField.tags, tags.join(' '));
    processField(SearchField.description, description);
    processField(SearchField.location, location);

    return IndexedDocument(
      id: id,
      fieldTokens: fieldTokens,
      fieldTermFreqs: fieldTermFreqs,
      fieldLengths: fieldLengths,
    );
  }
}

/// Best Matching 25 (BM25) Probabilistic Ranking Engine.
/// Implements field-weighted BM25 scoring with Okapi BM25 formula.
class BM25SearchIndex {
  // BM25 Hyperparameters
  final double k1;
  final double b;

  // Field Weights
  final Map<SearchField, double> fieldWeights;

  // Documents
  final Map<String, IndexedDocument> _documents = {};

  // Inverted Index: Term -> Field -> Document IDs
  final Map<String, Map<SearchField, Set<String>>> _invertedIndex = {};

  // Field average lengths
  final Map<SearchField, double> _avgFieldLengths = {};

  BM25SearchIndex({
    this.k1 = 1.2,
    this.b = 0.75,
    Map<SearchField, double>? fieldWeights,
  }) : fieldWeights = fieldWeights ??
            {
              SearchField.username: 8.0,
              SearchField.title: 5.0,
              SearchField.tags: 3.5,
              SearchField.subtitle: 3.0,
              SearchField.location: 2.0,
              SearchField.description: 1.5,
            };

  int get documentCount => _documents.length;

  /// Clear index
  void clear() {
    _documents.clear();
    _invertedIndex.clear();
    _avgFieldLengths.clear();
  }

  /// Add or update document
  void indexDocument(IndexedDocument doc) {
    _documents[doc.id] = doc;

    for (final field in SearchField.values) {
      final freqs = doc.fieldTermFreqs[field] ?? {};
      for (final term in freqs.keys) {
        _invertedIndex.putIfAbsent(term, () => {});
        _invertedIndex[term]!.putIfAbsent(field, () => {});
        _invertedIndex[term]![field]!.add(doc.id);
      }
    }
  }

  /// Recalculates average field lengths after batch indexing
  void commit() {
    if (_documents.isEmpty) return;

    for (final field in SearchField.values) {
      int totalLen = 0;
      for (final doc in _documents.values) {
        totalLen += doc.fieldLengths[field] ?? 0;
      }
      _avgFieldLengths[field] = totalLen / _documents.length;
    }
  }

  /// Inverse Document Frequency (IDF) with Robertson-Spärck Jones formula
  double _calculateIdf(String term, SearchField field) {
    final docsWithTerm = _invertedIndex[term]?[field]?.length ?? 0;
    if (docsWithTerm == 0) return 0.0;

    final n = _documents.length;
    // Robertson-Spärck Jones formula with smoothing
    return math.log(1.0 + ((n - docsWithTerm + 0.5) / (docsWithTerm + 0.5)));
  }

  /// Scores all matching documents for the given tokenized query terms.
  /// Returns Map of Document ID -> BM25 Score.
  Map<String, double> scoreQuery(List<String> queryTerms) {
    final scores = <String, double>{};
    if (queryTerms.isEmpty || _documents.isEmpty) return scores;

    // Collect candidate documents that contain at least one term (or prefix of term)
    final candidateDocIds = <String>{};

    for (final term in queryTerms) {
      // Exact term matches
      final fieldMap = _invertedIndex[term];
      if (fieldMap != null) {
        for (final docs in fieldMap.values) {
          candidateDocIds.addAll(docs);
        }
      }

      // Prefix term matches in index
      for (final indexTerm in _invertedIndex.keys) {
        if (indexTerm.startsWith(term) || (term.length >= 3 && indexTerm.contains(term))) {
          final fMap = _invertedIndex[indexTerm];
          if (fMap != null) {
            for (final docs in fMap.values) {
              candidateDocIds.addAll(docs);
            }
          }
        }
      }
    }

    // Score each candidate document using Multi-Field BM25
    for (final docId in candidateDocIds) {
      final doc = _documents[docId]!;
      double docScore = 0.0;

      for (final queryTerm in queryTerms) {
        for (final field in SearchField.values) {
          final weight = fieldWeights[field] ?? 1.0;
          final avgdl = _avgFieldLengths[field] ?? 1.0;
          final docLen = doc.fieldLengths[field] ?? 0;
          final freqs = doc.fieldTermFreqs[field] ?? {};

          // Term frequency in this field
          int tf = freqs[queryTerm] ?? 0;

          // Check prefix frequency bonus if exact match not present
          if (tf == 0) {
            for (final entry in freqs.entries) {
              if (entry.key.startsWith(queryTerm)) {
                tf += entry.value;
              }
            }
          }

          if (tf == 0) continue;

          final idf = _calculateIdf(queryTerm, field);
          final effectiveIdf = idf > 0.1 ? idf : 0.5; // Avoid zero out for common words

          // BM25 term saturation formula:
          // TF * (k1 + 1) / (TF + k1 * (1 - b + b * (docLen / avgdl)))
          final numerator = tf * (k1 + 1.0);
          final denominator = tf + (k1 * (1.0 - b + (b * (docLen / (avgdl > 0 ? avgdl : 1.0)))));
          final fieldScore = effectiveIdf * (numerator / denominator);

          docScore += fieldScore * weight;
        }
      }

      if (docScore > 0) {
        scores[docId] = docScore;
      }
    }

    return scores;
  }
}

