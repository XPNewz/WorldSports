import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SportType { cricket, football, basketball, tennis }

enum UserRole { player, coach, organiser, umpire }

enum MatchStatus { upcoming, live, completed }

// ─── Sports Specialization Specs ─────────────────────────────────────────────

class CricketSpecs {
  final String battingHand; // 'Right-hand bat', 'Left-hand bat'
  final String bowlingArm; // 'Right-arm', 'Left-arm'
  final String bowlingCategory; // 'Fast / Pace', 'Spin'
  final String bowlingVariation; // Fast: 'Fast', 'Fast-Medium', 'Medium-Fast', 'Medium' | Spin: 'Off-Spinner', 'Leg-Spinner', 'Slow Left-Arm Orthodox', 'Left-Arm Unorthodox (Chinaman)'
  final bool isWicketKeeper;

  const CricketSpecs({
    this.battingHand = 'Right-hand bat',
    this.bowlingArm = 'Right-arm',
    this.bowlingCategory = 'Fast / Pace',
    this.bowlingVariation = 'Fast-Medium',
    this.isWicketKeeper = false,
  });

  String get summary {
    final list = <String>[battingHand];
    if (bowlingArm.isNotEmpty && bowlingVariation.isNotEmpty) {
      list.add('$bowlingArm $bowlingVariation');
    }
    if (isWicketKeeper) {
      list.add('Wicketkeeper');
    }
    return list.join(' • ');
  }

  CricketSpecs copyWith({
    String? battingHand,
    String? bowlingArm,
    String? bowlingCategory,
    String? bowlingVariation,
    bool? isWicketKeeper,
  }) {
    return CricketSpecs(
      battingHand: battingHand ?? this.battingHand,
      bowlingArm: bowlingArm ?? this.bowlingArm,
      bowlingCategory: bowlingCategory ?? this.bowlingCategory,
      bowlingVariation: bowlingVariation ?? this.bowlingVariation,
      isWicketKeeper: isWicketKeeper ?? this.isWicketKeeper,
    );
  }

  Map<String, dynamic> toMap() => {
    'batting_hand': battingHand,
    'bowling_arm': bowlingArm,
    'bowling_category': bowlingCategory,
    'bowling_variation': bowlingVariation,
    'is_wicketkeeper': isWicketKeeper,
  };

  factory CricketSpecs.fromMap(Map<String, dynamic> map) => CricketSpecs(
    battingHand: map['batting_hand'] ?? 'Right-hand bat',
    bowlingArm: map['bowling_arm'] ?? 'Right-arm',
    bowlingCategory: map['bowling_category'] ?? 'Fast / Pace',
    bowlingVariation: map['bowling_variation'] ?? 'Fast-Medium',
    isWicketKeeper: map['is_wicketkeeper'] ?? false,
  );
}

class FootballSpecs {
  final String position; // 'Goalkeeper', 'Defender', 'Midfielder', 'Striker / Forward'
  final String preferredFoot; // 'Right', 'Left', 'Both'

  const FootballSpecs({
    this.position = 'Striker / Forward',
    this.preferredFoot = 'Right',
  });

  String get summary => '$position • Preferred foot: $preferredFoot';

  FootballSpecs copyWith({
    String? position,
    String? preferredFoot,
  }) {
    return FootballSpecs(
      position: position ?? this.position,
      preferredFoot: preferredFoot ?? this.preferredFoot,
    );
  }

  Map<String, dynamic> toMap() => {
    'position': position,
    'preferred_foot': preferredFoot,
  };

  factory FootballSpecs.fromMap(Map<String, dynamic> map) => FootballSpecs(
    position: map['position'] ?? 'Striker / Forward',
    preferredFoot: map['preferred_foot'] ?? 'Right',
  );
}

class BasketballSpecs {
  final String position; // 'Point Guard', 'Shooting Guard', 'Small Forward', 'Power Forward', 'Center'

  const BasketballSpecs({
    this.position = 'Point Guard',
  });

  String get summary => position;

  BasketballSpecs copyWith({String? position}) => BasketballSpecs(
    position: position ?? this.position,
  );

  Map<String, dynamic> toMap() => {'position': position};
  factory BasketballSpecs.fromMap(Map<String, dynamic> map) => BasketballSpecs(
    position: map['position'] ?? 'Point Guard',
  );
}

class TennisSpecs {
  final String hand; // 'Right-handed', 'Left-handed'
  final String backhand; // 'Two-handed', 'One-handed'
  final String playstyle; // 'All-Court', 'Baseliner', 'Serve & Volley'

  const TennisSpecs({
    this.hand = 'Right-handed',
    this.backhand = 'Two-handed',
    this.playstyle = 'All-Court',
  });

  String get summary => '$hand ($backhand backhand) • $playstyle';

  TennisSpecs copyWith({
    String? hand,
    String? backhand,
    String? playstyle,
  }) => TennisSpecs(
    hand: hand ?? this.hand,
    backhand: backhand ?? this.backhand,
    playstyle: playstyle ?? this.playstyle,
  );

  Map<String, dynamic> toMap() => {
    'hand': hand,
    'backhand': backhand,
    'playstyle': playstyle,
  };

  factory TennisSpecs.fromMap(Map<String, dynamic> map) => TennisSpecs(
    hand: map['hand'] ?? 'Right-handed',
    backhand: map['backhand'] ?? 'Two-handed',
    playstyle: map['playstyle'] ?? 'All-Court',
  );
}

// ─── Models ──────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String userId;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String avatar;
  final UserRole role;
  final List<SportType> sports;
  final SportType primarySport;
  final String primaryRole;
  final CricketSpecs? cricketSpecs;
  final FootballSpecs? footballSpecs;
  final BasketballSpecs? basketballSpecs;
  final TennisSpecs? tennisSpecs;
  final bool hasCompletedProfile;
  final List<String> teamIds;
  final List<String> clubIds;
  final int followers;
  final int following;
  final Map<SportType, PlayerStats> stats;
  final String location;
  final String bio;

  const UserModel({
    required this.id,
    this.userId = 'WS-1001',
    required this.name,
    required this.username,
    required this.email,
    this.phone = '',
    this.avatar = '',
    required this.role,
    required this.sports,
    this.primarySport = SportType.cricket,
    this.primaryRole = 'All-Rounder',
    this.cricketSpecs,
    this.footballSpecs,
    this.basketballSpecs,
    this.tennisSpecs,
    this.hasCompletedProfile = false,
    this.teamIds = const [],
    this.clubIds = const [],
    this.followers = 0,
    this.following = 0,
    this.stats = const {},
    this.location = '',
    this.bio = '',
  });

  int get profileCompletionPercent {
    if (hasCompletedProfile) return 100;
    int score = 40; // baseline for created account with name & email
    if (username.isNotEmpty) score += 10;
    if (phone.isNotEmpty) score += 10;
    if (role == UserRole.umpire) {
      return 100; // Umpires don't need batting/bowling specs
    }
    if (primarySport == SportType.cricket && cricketSpecs != null) score += 40;
    if (primarySport == SportType.football && footballSpecs != null) score += 40;
    if (primarySport == SportType.basketball && basketballSpecs != null) score += 40;
    if (primarySport == SportType.tennis && tennisSpecs != null) score += 40;
    return score.clamp(0, 100);
  }

  String getSpecsSummaryForSport(SportType sport) {
    switch (sport) {
      case SportType.cricket:
        return cricketSpecs?.summary ?? 'Cricket Athlete';
      case SportType.football:
        return footballSpecs?.summary ?? 'Football Athlete';
      case SportType.basketball:
        return basketballSpecs?.summary ?? 'Basketball Athlete';
      case SportType.tennis:
        return tennisSpecs?.summary ?? 'Tennis Athlete';
    }
  }

  UserModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? avatar,
    UserRole? role,
    List<SportType>? sports,
    SportType? primarySport,
    String? primaryRole,
    CricketSpecs? cricketSpecs,
    FootballSpecs? footballSpecs,
    BasketballSpecs? basketballSpecs,
    TennisSpecs? tennisSpecs,
    bool? hasCompletedProfile,
    List<String>? teamIds,
    List<String>? clubIds,
    int? followers,
    int? following,
    Map<SportType, PlayerStats>? stats,
    String? location,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      sports: sports ?? this.sports,
      primarySport: primarySport ?? this.primarySport,
      primaryRole: primaryRole ?? this.primaryRole,
      cricketSpecs: cricketSpecs ?? this.cricketSpecs,
      footballSpecs: footballSpecs ?? this.footballSpecs,
      basketballSpecs: basketballSpecs ?? this.basketballSpecs,
      tennisSpecs: tennisSpecs ?? this.tennisSpecs,
      hasCompletedProfile: hasCompletedProfile ?? this.hasCompletedProfile,
      teamIds: teamIds ?? this.teamIds,
      clubIds: clubIds ?? this.clubIds,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      stats: stats ?? this.stats,
      location: location ?? this.location,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'role': role.name,
    'sports': sports.map((s) => s.name).toList(),
    'primary_sport': primarySport.name,
    'primary_role': primaryRole,
    'cricket_specs': cricketSpecs?.toMap(),
    'football_specs': footballSpecs?.toMap(),
    'basketball_specs': basketballSpecs?.toMap(),
    'tennis_specs': tennisSpecs?.toMap(),
    'has_completed_profile': hasCompletedProfile,
    'team_ids': teamIds,
    'club_ids': clubIds,
    'followers': followers,
    'following': following,
    'stats': stats.map((key, value) => MapEntry(key.name, value.toMap())),
    'location': location,
    'bio': bio,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final roleStr = map['role'] as String? ?? 'player';
    final userRole = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.player,
    );

    final sportsList = (map['sports'] as List<dynamic>?)
        ?.map((s) => SportType.values.firstWhere(
              (sp) => sp.name == s.toString(),
              orElse: () => SportType.cricket,
            ))
        .toList() ??
        [SportType.cricket];

    final primarySportStr = map['primary_sport'] as String? ?? 'cricket';
    final primarySport = SportType.values.firstWhere(
      (s) => s.name == primarySportStr,
      orElse: () => SportType.cricket,
    );

    final rawStats = map['stats'] as Map<String, dynamic>?;
    final statsMap = <SportType, PlayerStats>{};
    if (rawStats != null) {
      for (final entry in rawStats.entries) {
        final sport = SportType.values.firstWhere(
          (s) => s.name == entry.key,
          orElse: () => SportType.cricket,
        );
        if (entry.value is Map<String, dynamic>) {
          statsMap[sport] = PlayerStats.fromMap(entry.value as Map<String, dynamic>);
        } else if (entry.value is Map) {
          statsMap[sport] = PlayerStats.fromMap(Map<String, dynamic>.from(entry.value as Map));
        }
      }
    }

    return UserModel(
      id: map['id'] ?? 'u_guest',
      userId: map['user_id'] ?? 'WS-1001',
      name: map['name'] ?? 'Athlete',
      username: map['username'] ?? 'athlete',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      avatar: map['avatar'] ?? '',
      role: userRole,
      sports: sportsList.isEmpty ? [primarySport] : sportsList,
      primarySport: primarySport,
      primaryRole: map['primary_role'] ?? 'Athlete',
      cricketSpecs: map['cricket_specs'] != null
          ? CricketSpecs.fromMap(Map<String, dynamic>.from(map['cricket_specs']))
          : null,
      footballSpecs: map['football_specs'] != null
          ? FootballSpecs.fromMap(Map<String, dynamic>.from(map['football_specs']))
          : null,
      basketballSpecs: map['basketball_specs'] != null
          ? BasketballSpecs.fromMap(Map<String, dynamic>.from(map['basketball_specs']))
          : null,
      tennisSpecs: map['tennis_specs'] != null
          ? TennisSpecs.fromMap(Map<String, dynamic>.from(map['tennis_specs']))
          : null,
      hasCompletedProfile: map['has_completed_profile'] ?? false,
      teamIds: List<String>.from(map['team_ids'] ?? []),
      clubIds: List<String>.from(map['club_ids'] ?? []),
      followers: (map['followers'] as num?)?.toInt() ?? 0,
      following: (map['following'] as num?)?.toInt() ?? 0,
      stats: statsMap,
      location: map['location'] ?? '',
      bio: map['bio'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UserModel.fromJson(String source) => UserModel.fromMap(jsonDecode(source));
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

  Map<String, dynamic> toMap() => {
    'sport': sport.name,
    'matches_played': matchesPlayed,
    'wins': wins,
    'losses': losses,
    'rating': rating,
    'specific_stats': specificStats,
  };

  factory PlayerStats.fromMap(Map<String, dynamic> map) => PlayerStats(
    sport: SportType.values.firstWhere(
      (s) => s.name == map['sport'],
      orElse: () => SportType.cricket,
    ),
    matchesPlayed: (map['matches_played'] as num?)?.toInt() ?? 0,
    wins: (map['wins'] as num?)?.toInt() ?? 0,
    losses: (map['losses'] as num?)?.toInt() ?? 0,
    rating: (map['rating'] as num?)?.toDouble() ?? 7.0,
    specificStats: Map<String, dynamic>.from(map['specific_stats'] ?? {}),
  );
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
  final String userId;
  final String username;
  final String specsSummary;

  const MatchPlayer({
    required this.id,
    required this.name,
    required this.jerseyNumber,
    this.role = 'Athlete',
    this.isCaptain = false,
    this.isWicketKeeperOrGoalkeeper = false,
    this.avatar = '',
    this.userId = '',
    this.username = '',
    this.specsSummary = '',
  });

  MatchPlayer copyWith({
    String? id,
    String? name,
    int? jerseyNumber,
    String? role,
    bool? isCaptain,
    bool? isWicketKeeperOrGoalkeeper,
    String? avatar,
    String? userId,
    String? username,
    String? specsSummary,
  }) {
    return MatchPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      role: role ?? this.role,
      isCaptain: isCaptain ?? this.isCaptain,
      isWicketKeeperOrGoalkeeper: isWicketKeeperOrGoalkeeper ?? this.isWicketKeeperOrGoalkeeper,
      avatar: avatar ?? this.avatar,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      specsSummary: specsSummary ?? this.specsSummary,
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
  final String scorerId;
  final String scorerName;
  final String umpire1Id;
  final String umpire1Name;
  final String umpire2Id;
  final String umpire2Name;

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
    this.scorerId = '',
    this.scorerName = '',
    this.umpire1Id = '',
    this.umpire1Name = '',
    this.umpire2Id = '',
    this.umpire2Name = '',
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
    String? scorerId,
    String? scorerName,
    String? umpire1Id,
    String? umpire1Name,
    String? umpire2Id,
    String? umpire2Name,
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
      scorerId: scorerId ?? this.scorerId,
      scorerName: scorerName ?? this.scorerName,
      umpire1Id: umpire1Id ?? this.umpire1Id,
      umpire1Name: umpire1Name ?? this.umpire1Name,
      umpire2Id: umpire2Id ?? this.umpire2Id,
      umpire2Name: umpire2Name ?? this.umpire2Name,
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
