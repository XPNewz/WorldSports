import '../../search_service.dart';
import '../../../models/models.dart';

/// Semantic intent recognized from user's search query.
enum SearchIntentType {
  general,
  athleteProfile,
  venueBooking,
  teamSquad,
  communityHub,
  associationBylaws,
  clubAcademy,
  tagSearch,
}

/// Structured semantic query interpretation.
class ParsedQueryIntent {
  final String rawQuery;
  final String cleanQuery;
  final SearchIntentType intentType;
  final SearchCategory? detectedCategory;
  final SportType? detectedSport;
  final String? detectedLocation;
  final int? maxPrice;
  final List<String> extractedTags;
  final bool hasExplicitAtUsername;

  const ParsedQueryIntent({
    required this.rawQuery,
    required this.cleanQuery,
    this.intentType = SearchIntentType.general,
    this.detectedCategory,
    this.detectedSport,
    this.detectedLocation,
    this.maxPrice,
    this.extractedTags = const [],
    this.hasExplicitAtUsername = false,
  });

  bool get hasExtractedFacets =>
      detectedCategory != null ||
      detectedSport != null ||
      detectedLocation != null ||
      maxPrice != null;
}

/// Semantic Query Intent Parser and Athletic Entity Classifier.
/// Parses multi-word conversational queries into structured filters and residual tokens.
class SportsQueryParser {
  static final Map<String, SportType> _sportKeywords = {
    'cricket': SportType.cricket,
    'batsman': SportType.cricket,
    'batter': SportType.cricket,
    'bowler': SportType.cricket,
    'pitch': SportType.cricket,
    'wicket': SportType.cricket,
    'football': SportType.football,
    'soccer': SportType.football,
    'striker': SportType.football,
    'midfielder': SportType.football,
    'goalkeeper': SportType.football,
    'astroturf': SportType.football,
    'basketball': SportType.basketball,
    'hoops': SportType.basketball,
    'streetball': SportType.basketball,
    '3x3': SportType.basketball,
    'hardwood': SportType.basketball,
    'tennis': SportType.tennis,
    'racquet': SportType.tennis,
    'racket': SportType.tennis,
    'forehand': SportType.tennis,
    'clay court': SportType.tennis,
    'hard court': SportType.tennis,
  };

  static final Map<String, SearchCategory> _categoryKeywords = {
    'ground': SearchCategory.grounds,
    'grounds': SearchCategory.grounds,
    'turf': SearchCategory.grounds,
    'stadium': SearchCategory.grounds,
    'court': SearchCategory.grounds,
    'courts': SearchCategory.grounds,
    'arena': SearchCategory.grounds,
    'venue': SearchCategory.grounds,
    'booking': SearchCategory.grounds,
    'team': SearchCategory.teams,
    'teams': SearchCategory.teams,
    'squad': SearchCategory.teams,
    'squads': SearchCategory.teams,
    'lineup': SearchCategory.teams,
    'xi': SearchCategory.teams,
    'player': SearchCategory.players,
    'players': SearchCategory.players,
    'athlete': SearchCategory.players,
    'athletes': SearchCategory.players,
    'coach': SearchCategory.players,
    'coaches': SearchCategory.players,
    'club': SearchCategory.clubs,
    'clubs': SearchCategory.clubs,
    'academy': SearchCategory.clubs,
    'academies': SearchCategory.clubs,
    'community': SearchCategory.communities,
    'communities': SearchCategory.communities,
    'hub': SearchCategory.communities,
    'forum': SearchCategory.communities,
    'pickup': SearchCategory.communities,
    'association': SearchCategory.associations,
    'associations': SearchCategory.associations,
    'federation': SearchCategory.associations,
    'council': SearchCategory.associations,
    'bylaws': SearchCategory.associations,
    'board': SearchCategory.associations,
    'mca': SearchCategory.associations,
    'ksfa': SearchCategory.associations,
    'aita': SearchCategory.associations,
    'imsf': SearchCategory.associations,
  };

  static final List<String> _knownCities = [
    'Mumbai',
    'Bangalore',
    'Delhi',
    'Hyderabad',
    'Kolkata',
    'Chennai',
    'Jaipur',
  ];

  /// Parses user query and extracts intent, categories, sports, and geo signals.
  static ParsedQueryIntent parse(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return ParsedQueryIntent(rawQuery: raw, cleanQuery: '');
    }

    // 1. Explicit @username search
    if (raw.startsWith('@')) {
      final username = raw.substring(1).trim();
      return ParsedQueryIntent(
        rawQuery: raw,
        cleanQuery: username,
        intentType: SearchIntentType.athleteProfile,
        detectedCategory: SearchCategory.players,
        hasExplicitAtUsername: true,
      );
    }

    // 2. Explicit #tag search
    if (raw.startsWith('#')) {
      final tag = raw.substring(1).trim();
      return ParsedQueryIntent(
        rawQuery: raw,
        cleanQuery: tag,
        intentType: SearchIntentType.tagSearch,
        extractedTags: [tag.toLowerCase()],
      );
    }

    final lower = raw.toLowerCase();
    SearchCategory? detectedCat;
    SportType? detectedSport;
    String? detectedLocation;
    int? maxPrice;
    final tags = <String>[];

    // Detect Category
    for (final entry in _categoryKeywords.entries) {
      final pattern = RegExp(r'\b' + RegExp.escape(entry.key) + r'\b');
      if (pattern.hasMatch(lower)) {
        detectedCat = entry.value;
        break;
      }
    }

    // Detect Sport
    for (final entry in _sportKeywords.entries) {
      final pattern = RegExp(r'\b' + RegExp.escape(entry.key) + r'\b');
      if (pattern.hasMatch(lower)) {
        detectedSport = entry.value;
        break;
      }
    }

    // Detect Location
    for (final city in _knownCities) {
      final pattern = RegExp(r'\b' + RegExp.escape(city.toLowerCase()) + r'\b');
      if (pattern.hasMatch(lower)) {
        detectedLocation = city;
        break;
      }
    }

    // Detect Price Budget: e.g. "under 2000" or "< 1500" or "below 2500"
    final priceMatch = RegExp(r'(?:under|below|<|<=|max)\s*₹?\s*(\d{3,5})').firstMatch(lower);
    if (priceMatch != null) {
      maxPrice = int.tryParse(priceMatch.group(1)!);
    }

    // Determine Intent Type
    SearchIntentType intent = SearchIntentType.general;
    if (detectedCat == SearchCategory.grounds || maxPrice != null) {
      intent = SearchIntentType.venueBooking;
    } else if (detectedCat == SearchCategory.players) {
      intent = SearchIntentType.athleteProfile;
    } else if (detectedCat == SearchCategory.teams) {
      intent = SearchIntentType.teamSquad;
    } else if (detectedCat == SearchCategory.communities) {
      intent = SearchIntentType.communityHub;
    } else if (detectedCat == SearchCategory.clubs) {
      intent = SearchIntentType.clubAcademy;
    } else if (detectedCat == SearchCategory.associations) {
      intent = SearchIntentType.associationBylaws;
    }

    return ParsedQueryIntent(
      rawQuery: raw,
      cleanQuery: raw,
      intentType: intent,
      detectedCategory: detectedCat,
      detectedSport: detectedSport,
      detectedLocation: detectedLocation,
      maxPrice: maxPrice,
      extractedTags: tags,
    );
  }
}
