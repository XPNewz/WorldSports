import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing persistent recent search history across app restarts.
class SearchHistoryService {
  static const String _keyHistory = 'worldsports_recent_search_history';
  static const int _maxHistoryItems = 12;

  static List<String>? _memoryCache;

  /// Loads recent searches from cache or SharedPreferences.
  static Future<List<String>> getRecentSearches() async {
    if (_memoryCache != null) return List.unmodifiable(_memoryCache!);

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyHistory);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _memoryCache = decoded.map((e) => e.toString()).toList();
          return List.unmodifiable(_memoryCache!);
        }
      }
    } catch (_) {}

    _memoryCache = [];
    return const [];
  }

  /// Adds a query to recent history (deduplicating and placing at front).
  static Future<void> addQuery(String query) async {
    final clean = query.trim();
    if (clean.length < 2) return;

    final history = (await getRecentSearches()).toList();
    history.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
    history.insert(0, clean);

    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    _memoryCache = history;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyHistory, jsonEncode(history));
    } catch (_) {}
  }

  /// Removes an individual query from history.
  static Future<void> removeQuery(String query) async {
    final history = (await getRecentSearches()).toList();
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    _memoryCache = history;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyHistory, jsonEncode(history));
    } catch (_) {}
  }

  /// Clears all recent searches.
  static Future<void> clearAll() async {
    _memoryCache = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHistory);
    } catch (_) {}
  }
}

