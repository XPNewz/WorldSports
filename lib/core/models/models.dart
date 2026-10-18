import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SportType { cricket, football, basketball, tennis }

enum UserRole { player, coach, organiser }

enum MatchStatus { upcoming, live, completed }

// ─── Models ──────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String avatar;
  final UserRole role;
  final List<SportType> sports;
  final List<String> teamIds;
  final List<String> clubIds;
  final int followers;
  final int following;
  final Map<SportType, PlayerStats> stats;
  final String location;
  final String bio;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.avatar = '',
    required this.role,
    required this.sports,
    this.teamIds = const [],
    this.clubIds = const [],
    this.followers = 0,
    this.following = 0,
    this.stats = const {},
    this.location = '',
    this.bio = '',
  });
}

class PlayerStats {
  final SportType sport;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final double rating;
  final Map<String, dynamic> specificStats;

  const PlayerStats({
    required this.sport,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.rating,
    this.specificStats = const {},
  });

  double get winRate => matchesPlayed > 0 ? wins / matchesPlayed : 0;

  /// Whether this is an individual sport where match win/loss is an individual accomplishment
  bool get isIndividualSport =>
      sport == SportType.tennis || (specificStats['is_individual'] == true);

  /// Primary role title (e.g. All-Rounder (Batting Main), Playmaker Midfielder)
  String get primaryRole {
    final explicit = specificStats['primary_role'] as String?;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    switch (sport) {
      case SportType.cricket:
        return 'All-Rounder (Batting Main)';
      case SportType.football:
        return 'Playmaker Midfielder';
      case SportType.basketball:
        return 'Point Guard';
      case SportType.tennis:
        return 'Singles Specialist';
    }
  }

  /// Map of role name -> `Map<String, dynamic>` of stats
  Map<String, Map<String, dynamic>> get rolesData {
    if (specificStats.containsKey('roles') &&
        specificStats['roles'] is Map<String, dynamic>) {
      final rawRoles = specificStats['roles'] as Map<String, dynamic>;
      return rawRoles.map((key, value) =>
          MapEntry(key, Map<String, dynamic>.from(value as Map)));
    }
    return {
      primaryRole: specificStats,
    };
  }
}

class TeamModel {
  final String id;
  final String name;
  final String shortName;
  final SportType sport;
  final String logo;
  final String captainId;
  final List<String> playerIds;
  final String clubId;
  final int wins;
  final int losses;
  final int draws;
  final String location;
  final Color color;

  const TeamModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.sport,
    this.logo = '',
    required this.captainId,
    this.playerIds = const [],
    this.clubId = '',
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.location = '',
    this.color = AppColors.primary,
  });

  int get totalMatches => wins + losses + draws;
}

class ClubModel {
  final String id;
  final String name;
  final String logo;
  final List<SportType> sports;
  final List<String> teamIds;
  final List<String> memberIds;
  final String location;
  final String description;
  final int established;

  const ClubModel({
    required this.id,
    required this.name,
    this.logo = '',
    required this.sports,
    this.teamIds = const [],
    this.memberIds = const [],
    this.location = '',
    this.description = '',
    this.established = 2020,
  });
}

class TournamentModel {
  final String id;
  final String name;
  final SportType sport;
  final String banner;
  final String organiserId;
  final String associationId;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final int teamsCount;
  final String format;
  final String prizePool;
  final MatchStatus status;

  const TournamentModel({
    required this.id,
    required this.name,
    required this.sport,
    this.banner = '',
    required this.organiserId,
    this.associationId = '',
    required this.startDate,
    required this.endDate,
    this.location = '',
    this.teamsCount = 8,
    this.format = 'Knockout',
    this.prizePool = '',
    this.status = MatchStatus.upcoming,
  });
}

class MatchPlayer {
  final String id;
  final String name;
  final int jerseyNumber;
  final String role;
  final bool isCaptain;
  final bool isWicketKeeperOrGoalkeeper;
  final String avatar;

  const MatchPlayer({
    required this.id,
    required this.name,
    required this.jerseyNumber,
    this.role = 'Athlete',
    this.isCaptain = false,
    this.isWicketKeeperOrGoalkeeper = false,
    this.avatar = '',
  });

  MatchPlayer copyWith({
    String? id,
    String? name,
    int? jerseyNumber,
    String? role,
    bool? isCaptain,
    bool? isWicketKeeperOrGoalkeeper,
    String? avatar,
  }) {
    return MatchPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      role: role ?? this.role,
      isCaptain: isCaptain ?? this.isCaptain,
      isWicketKeeperOrGoalkeeper: isWicketKeeperOrGoalkeeper ?? this.isWicketKeeperOrGoalkeeper,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchPlayer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          jerseyNumber == other.jerseyNumber &&
          role == other.role &&
          isCaptain == other.isCaptain &&
          isWicketKeeperOrGoalkeeper == other.isWicketKeeperOrGoalkeeper;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      jerseyNumber.hashCode ^
      role.hashCode ^
      isCaptain.hashCode ^
      isWicketKeeperOrGoalkeeper.hashCode;
}

class MatchModel {
  final String id;
  final SportType sport;
  final String team1Id;
  final String team2Id;
  final String team1Name;
  final String team2Name;
  final String team1Short;
  final String team2Short;
  final DateTime dateTime;
  final String venue;
  final String tournamentId;
  final MatchStatus status;
  final dynamic scoreData;
  final String format;
  final List<MatchPlayer> team1Players;
  final List<MatchPlayer> team2Players;
  final String tossWinner;
  final String tossDecision;
  final String resultText;
  final String creatorId;

  const MatchModel({
    required this.id,
    required this.sport,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
    required this.team1Short,
    required this.team2Short,
    required this.dateTime,
    this.venue = '',
    this.tournamentId = '',
    this.status = MatchStatus.upcoming,
    this.scoreData,
    this.format = 'Standard',
    this.team1Players = const [],
    this.team2Players = const [],
    this.tossWinner = '',
    this.tossDecision = '',
    this.resultText = '',
    this.creatorId = 'u001',
  });

  MatchModel copyWith({
    String? id,
    SportType? sport,
    String? team1Id,
    String? team2Id,
    String? team1Name,
    String? team2Name,
    String? team1Short,
    String? team2Short,
    DateTime? dateTime,
    String? venue,
    String? tournamentId,
    MatchStatus? status,
    dynamic scoreData,
    String? format,
    List<MatchPlayer>? team1Players,
    List<MatchPlayer>? team2Players,
    String? tossWinner,
    String? tossDecision,
    String? resultText,
    String? creatorId,
  }) {
    return MatchModel(
      id: id ?? this.id,
      sport: sport ?? this.sport,
      team1Id: team1Id ?? this.team1Id,
      team2Id: team2Id ?? this.team2Id,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      team1Short: team1Short ?? this.team1Short,
      team2Short: team2Short ?? this.team2Short,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      tournamentId: tournamentId ?? this.tournamentId,
      status: status ?? this.status,
      scoreData: scoreData ?? this.scoreData,
      format: format ?? this.format,
      team1Players: team1Players ?? this.team1Players,
      team2Players: team2Players ?? this.team2Players,
      tossWinner: tossWinner ?? this.tossWinner,
      tossDecision: tossDecision ?? this.tossDecision,
      resultText: resultText ?? this.resultText,
      creatorId: creatorId ?? this.creatorId,
    );
  }
}

class AssociationModel {
  final String id;
  final String name;
  final List<SportType> sports;
  final String logo;
  final String country;
  final String description;
  final int membersCount;
  final int clubsCount;

  const AssociationModel({
    required this.id,
    required this.name,
    required this.sports,
    this.logo = '',
    this.country = '',
    this.description = '',
    this.membersCount = 0,
    this.clubsCount = 0,
  });
}

// ─── Feed Post Model (Twitter / X Tweet Style) ───────────────────────────────

class FeedPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorHandle;
  final String authorAvatar;
  final bool isVerified;
  final String content;
  final String? title;
  final String? category;
  final SportType? sport;
  final String? imageUrl;
  final String? mediaHeadline;
  final String? mediaSubtitle;
  final DateTime createdAt;
  int likes;
  int comments;
  int reposts;
  bool isLiked;
  bool isReposted;
  bool isBookmarked;

  FeedPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    String? authorHandle,
    this.authorAvatar = '',
    this.isVerified = false,
    required this.content,
    this.title,
    this.category,
    this.sport,
    this.imageUrl,
    this.mediaHeadline,
    this.mediaSubtitle,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.reposts = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.isBookmarked = false,
  }) : authorHandle = authorHandle ??
            '@${authorName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
}

// ─── Ads & Sponsorship Models ─────────────────────────────────────────────────

enum AdType {
  promotedPost,
  banner,
  scoreboardSponsor,
}

class AdModel {
  final String id;
  final String advertiserName;
  final String advertiserHandle;
  final String advertiserAvatar;
  final bool isVerified;
  final String badgeText; // 'Promoted', 'Sponsored', 'Official Partner'
  final String headline;
  final String bodyText;
  final String ctaText; // 'Shop Now', 'Book Ground', 'Claim Offer'
  final String ctaUrl;
  final String? promoCode;
  final String? discountTag; // '35% OFF', '20% CASHBACK'
  final String? imageUrl;
  final SportType? targetSport;
  final AdType type;
  final double rating;
  final int reviewsCount;
  int impressions;
  int clicks;

  AdModel({
    required this.id,
    required this.advertiserName,
    required this.advertiserHandle,
    this.advertiserAvatar = '',
    this.isVerified = true,
    this.badgeText = 'Promoted',
    required this.headline,
    required this.bodyText,
    required this.ctaText,
    this.ctaUrl = 'https://worldsports.app/sponsor',
    this.promoCode,
    this.discountTag,
    this.imageUrl,
    this.targetSport,
    this.type = AdType.promotedPost,
    this.rating = 4.9,
    this.reviewsCount = 1240,
    this.impressions = 0,
    this.clicks = 0,
  });
}

// ─── Extended Athletic Domain Models ─────────────────────────────────────────

class PreviousMatchModel {
  final String id;
  final SportType sport;
  final String team1Name;
  final String team2Name;
  final String team1Short;
  final String team2Short;
  final String team1Score;
  final String team2Score;
  final String resultText;
  final bool isWin;
  final DateTime date;
  final String venue;
  final String myPerformance;
  final String? mvpPlayer;

  const PreviousMatchModel({
    required this.id,
    required this.sport,
    required this.team1Name,
    required this.team2Name,
    required this.team1Short,
    required this.team2Short,
    required this.team1Score,
    required this.team2Score,
    required this.resultText,
    required this.isWin,
    required this.date,
    required this.venue,
    required this.myPerformance,
    this.mvpPlayer,
  });
}

class NearbyMatchModel {
  final String id;
  final SportType sport;
  final String matchTitle;
  final String teams;
  final String team1Name;
  final String team2Name;
  final String team1Score;
  final String? team1Overs;
  final String team2Score;
  final String? team2Overs;
  final bool isTeam1Active;
  final String venue;
  final String distance;
  final String statusText;
  final bool isLive;

  const NearbyMatchModel({
    required this.id,
    required this.sport,
    required this.matchTitle,
    this.teams = '',
    this.team1Name = '',
    this.team2Name = '',
    this.team1Score = '',
    this.team1Overs,
    this.team2Score = '',
    this.team2Overs,
    this.isTeam1Active = true,
    required this.venue,
    required this.distance,
    required this.statusText,
    this.isLive = true,
  });

  String get resolvedTeam1Name {
    if (team1Name.isNotEmpty) return team1Name;
    if (teams.contains(' vs ')) return teams.split(' vs ')[0].trim();
    if (teams.contains(' v ')) return teams.split(' v ')[0].trim();
    return teams;
  }

  String get resolvedTeam2Name {
    if (team2Name.isNotEmpty) return team2Name;
    if (teams.contains(' vs ')) return teams.split(' vs ')[1].trim();
    if (teams.contains(' v ')) return teams.split(' v ')[1].trim();
    return '';
  }
}

class SportsUpdateModel {
  final String id;
  final String title;
  final String summary;
  final String category;
  final SportType sport;
  final String timeAgo;

  const SportsUpdateModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.sport,
    required this.timeAgo,
  });
}

class ClubAssociationUpdateModel {
  final String id;
  final String sourceName;
  final String sourceType; // 'Club' | 'Association' | 'Tournament'
  final String title;
  final String content;
  final String dateText;
  final String actionLabel;

  const ClubAssociationUpdateModel({
    required this.id,
    required this.sourceName,
    required this.sourceType,
    required this.title,
    required this.content,
    required this.dateText,
    required this.actionLabel,
  });
}

class SportSkillModel {
  final SportType sport;
  final String skillName;
  final int score; // 0 - 100
  final String tier; // 'Elite', 'Master', 'Pro'
  final String category; // 'Power', 'Technique', 'Pace', 'Tactics'

  const SportSkillModel({
    required this.sport,
    required this.skillName,
    required this.score,
    required this.tier,
    required this.category,
  });
}

class AchievementModel {
  final String id;
  final String title;
  final SportType sport;
  final String year;
  final String description;
  final IconData icon;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.sport,
    required this.year,
    required this.description,
    required this.icon,
  });
}

/// ─── Sport Player Rules & Minimum Requirements ────────────────────────────────

class SportPlayerRules {
  /// Returns the minimum number of players required per team to play a match for the given sport and format.
  /// For Cricket: Cricheroes allows matches to be created and scored with a minimum of 2 players per side.
  static int getMinPlayers(SportType sport, [String? format]) {
    switch (sport) {
      case SportType.cricket:
        // Cricheroes standard: minimum 2 players per team (Striker + Non-striker)
        return 2;
      case SportType.football:
        if (format != null) {
          if (format.contains('11v11')) return 7; // Official FIFA Law 3 minimum
          if (format.contains('7v7')) return 5;
          if (format.contains('5v5') || format.toLowerCase().contains('futsal')) return 3; // Futsal Law 3 minimum
        }
        return 3;
      case SportType.basketball:
        if (format != null && (format.contains('3v3') || format.contains('3x3'))) return 3;
        return 5; // Standard 5v5 basketball court regulation
      case SportType.tennis:
        if (format != null && format.toLowerCase().contains('double')) return 2;
        return 1; // Singles tennis
    }
  }

  /// Returns user-friendly rule description explaining the minimum player requirement.
  static String getRuleDescription(SportType sport, [String? format]) {
    final min = getMinPlayers(sport, format);
    switch (sport) {
      case SportType.cricket:
        return 'Min $min players per team (Cricheroes standard: 1 Striker + 1 Non-Striker)';
      case SportType.football:
        return 'Min $min players per team (${format ?? "Official match rule"})';
      case SportType.basketball:
        return 'Min $min players per team (${format ?? "Court regulations"})';
      case SportType.tennis:
        return 'Min $min player${min > 1 ? "s" : ""} per side (${format ?? "Singles"})';
    }
  }
}
