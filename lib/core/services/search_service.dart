import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../../screens/match/match_creation_screen.dart';
import '../state/app_state.dart';

/// Categories for the "What to search" filter.
enum SearchCategory {
  all,
  players,
  teams,
  grounds,
  communities,
  clubs,
  associations,
}

extension SearchCategoryExtension on SearchCategory {
  String get label {
    switch (this) {
      case SearchCategory.all:
        return 'All';
      case SearchCategory.players:
        return 'Players';
      case SearchCategory.teams:
        return 'Teams';
      case SearchCategory.grounds:
        return 'Grounds';
      case SearchCategory.communities:
        return 'Communities';
      case SearchCategory.clubs:
        return 'Clubs';
      case SearchCategory.associations:
        return 'Associations';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchCategory.all:
        return Icons.auto_awesome_rounded;
      case SearchCategory.players:
        return Icons.person_rounded;
      case SearchCategory.teams:
        return Icons.shield_rounded;
      case SearchCategory.grounds:
        return Icons.stadium_rounded;
      case SearchCategory.communities:
        return Icons.forum_rounded;
      case SearchCategory.clubs:
        return Icons.sports_score_rounded;
      case SearchCategory.associations:
        return Icons.account_balance_rounded;
    }
  }
}

/// Unified model representing any searchable entity across the WorldSports platform.
class SearchResultItem {
  final String id;
  final String title; // Entity name
  final String subtitle; // Short classification or tag
  final String description; // Full searchable bio, facility specs, bylaws, or post content
  final SearchCategory category;
  final SportType? sport; // Primary sport, or null if multi-sport
  final List<SportType> sports; // Supported sports
  final String location; // City, State, or Region
  final IconData icon;
  final Color accentColor;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    this.sport,
    this.sports = const [],
    required this.location,
    required this.icon,
    this.accentColor = AppColors.primary,
    this.metadata = const {},
    this.tags = const [],
  });

  /// Check whether this item supports or belongs to the given sport.
  bool matchesSport(SportType targetSport) {
    if (sport == targetSport) return true;
    if (sports.contains(targetSport)) return true;
    return false;
  }
}

/// Central service indexing all entities for fast, multi-filtered querying.
class SearchCatalogService {
  static List<SearchResultItem>? _cachedCatalog;

  /// Returns the master list of all searchable entities.
  static List<SearchResultItem> getAllItems() {
    if (_cachedCatalog != null) return _cachedCatalog!;
    final items = <SearchResultItem>[];

    // ── 1. PLAYERS ────────────────────────────────────────────────────────────
    // Cricket Stars from RealAthletesCatalog
    final cricketStars = RealAthletesCatalog.getAthletesForSport(SportType.cricket);
    for (final p in cricketStars) {
      items.add(
        SearchResultItem(
          id: 'player_cricket_${p.id}',
          title: p.name,
          subtitle: '${p.role} • #${p.jerseyNumber}',
          description: _generateAthleteDescription(p.name, p.role, SportType.cricket),
          category: SearchCategory.players,
          sport: SportType.cricket,
          sports: const [SportType.cricket],
          location: _assignPlayerCity(p.name),
          icon: Icons.person_rounded,
          accentColor: AppColors.cricket,
          metadata: {
            'role': p.role,
            'jersey': p.jerseyNumber,
            'isCaptain': p.isCaptain,
            'isWk': p.isWicketKeeperOrGoalkeeper,
            'rating': 4.9,
            'matches': 74,
          },
          tags: [p.role.toLowerCase(), 'cricket', 'batter', 'bowler', 'all-rounder', 'captain'],
        ),
      );
    }

    // Football Stars from RealAthletesCatalog
    final footballStars = RealAthletesCatalog.getAthletesForSport(SportType.football);
    for (final p in footballStars) {
      items.add(
        SearchResultItem(
          id: 'player_football_${p.id}',
          title: p.name,
          subtitle: '${p.role} • #${p.jerseyNumber}',
          description: _generateAthleteDescription(p.name, p.role, SportType.football),
          category: SearchCategory.players,
          sport: SportType.football,
          sports: const [SportType.football],
          location: _assignPlayerCity(p.name),
          icon: Icons.person_rounded,
          accentColor: AppColors.football,
          metadata: {
            'role': p.role,
            'jersey': p.jerseyNumber,
            'isCaptain': p.isCaptain,
            'isGk': p.isWicketKeeperOrGoalkeeper,
            'rating': 4.8,
            'matches': 68,
          },
          tags: [p.role.toLowerCase(), 'football', 'soccer', 'striker', 'midfielder', 'winger', 'goalkeeper'],
        ),
      );
    }

    // Basketball Stars from RealAthletesCatalog
    final basketballStars = RealAthletesCatalog.getAthletesForSport(SportType.basketball);
    for (final p in basketballStars) {
      items.add(
        SearchResultItem(
          id: 'player_basketball_${p.id}',
          title: p.name,
          subtitle: '${p.role} • #${p.jerseyNumber}',
          description: _generateAthleteDescription(p.name, p.role, SportType.basketball),
          category: SearchCategory.players,
          sport: SportType.basketball,
          sports: const [SportType.basketball],
          location: _assignPlayerCity(p.name),
          icon: Icons.person_rounded,
          accentColor: AppColors.basketball,
          metadata: {
            'role': p.role,
            'jersey': p.jerseyNumber,
            'isCaptain': p.isCaptain,
            'rating': 4.9,
            'matches': 52,
          },
          tags: [p.role.toLowerCase(), 'basketball', 'hoops', 'guard', 'forward', 'center', 'shooter'],
        ),
      );
    }

    // Tennis Stars from RealAthletesCatalog
    final tennisStars = RealAthletesCatalog.getAthletesForSport(SportType.tennis);
    for (final p in tennisStars) {
      items.add(
        SearchResultItem(
          id: 'player_tennis_${p.id}',
          title: p.name,
          subtitle: '${p.role} • Seed #${p.jerseyNumber}',
          description: _generateAthleteDescription(p.name, p.role, SportType.tennis),
          category: SearchCategory.players,
          sport: SportType.tennis,
          sports: const [SportType.tennis],
          location: _assignPlayerCity(p.name),
          icon: Icons.person_rounded,
          accentColor: AppColors.tennis,
          metadata: {
            'role': p.role,
            'rating': 4.9,
            'matches': 46,
          },
          tags: [p.role.toLowerCase(), 'tennis', 'racket', 'serve', 'singles', 'doubles', 'grand slam'],
        ),
      );
    }

    // Current User & Local Athletes
    items.add(
      SearchResultItem(
        id: 'player_u001',
        title: MockData.demoPlayer.name,
        subtitle: 'Multi-Sport Competitive Athlete • Div 1 Pro',
        description: MockData.demoPlayer.bio,
        category: SearchCategory.players,
        sport: SportType.cricket,
        sports: MockData.demoPlayer.sports,
        location: MockData.demoPlayer.location,
        icon: Icons.person_rounded,
        accentColor: AppColors.primary,
        metadata: {
          'rating': 4.5,
          'followers': MockData.demoPlayer.followers,
          'sportsCount': MockData.demoPlayer.sports.length,
        },
        tags: ['athlete', 'all-rounder', 'cricket', 'football', 'basketball', 'mumbai'],
      ),
    );

    items.add(
      SearchResultItem(
        id: 'player_u002',
        title: MockData.demoCoach.name,
        subtitle: 'High Performance Head Coach & Director',
        description: MockData.demoCoach.bio,
        category: SearchCategory.players,
        sport: SportType.tennis,
        sports: MockData.demoCoach.sports,
        location: MockData.demoCoach.location,
        icon: Icons.sports_rounded,
        accentColor: AppColors.tennis,
        metadata: {
          'rating': 4.9,
          'followers': MockData.demoCoach.followers,
          'role': 'Head Coach',
        },
        tags: ['coach', 'trainer', 'director', 'tennis', 'cricket', 'bangalore'],
      ),
    );

    // Nearby Local Talents
    items.add(
      const SearchResultItem(
        id: 'player_vikas',
        title: 'Vikas Kumar',
        subtitle: 'Pace All-Rounder & Striker',
        description: 'Elite district cricket all-rounder and fast football winger. Winner of Western Mumbai Turf Championship with 48 sixes in seasonal leagues.',
        category: SearchCategory.players,
        sport: SportType.cricket,
        sports: [SportType.cricket, SportType.football],
        location: 'Mumbai, India',
        icon: Icons.person_rounded,
        accentColor: AppColors.cricket,
        metadata: {'rating': 4.8, 'distance': '2.1 km away'},
        tags: ['all-rounder', 'cricket', 'football', 'mumbai'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'player_sneha',
        title: 'Sneha Rao',
        subtitle: 'Baseline Tennis Specialist & Point Guard',
        description: 'State tennis ranking gold medalist and university basketball floor general. Known for aggressive top-spin forehands and fast court transitions.',
        category: SearchCategory.players,
        sport: SportType.tennis,
        sports: [SportType.tennis, SportType.basketball],
        location: 'Bangalore, India',
        icon: Icons.person_rounded,
        accentColor: AppColors.tennis,
        metadata: {'rating': 4.6, 'distance': '3.8 km away'},
        tags: ['tennis', 'basketball', 'bangalore'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'player_aditya',
        title: 'Aditya Bose',
        subtitle: 'Box-to-Box Midfielder',
        description: 'Dynamic central midfielder for Kolkata Youth Football League. High work-rate, pin-point crossing, stamina and tactical vision.',
        category: SearchCategory.players,
        sport: SportType.football,
        sports: [SportType.football],
        location: 'Kolkata, India',
        icon: Icons.person_rounded,
        accentColor: AppColors.football,
        metadata: {'rating': 4.7, 'distance': '5.2 km away'},
        tags: ['midfielder', 'football', 'kolkata'],
      ),
    );

    // ── 2. TEAMS ──────────────────────────────────────────────────────────────
    items.add(
      const SearchResultItem(
        id: 'team_t001',
        title: 'Mumbai Mavericks',
        subtitle: 'MUM • Cricket Team • 12W 4L 2D',
        description: 'Elite division premier cricket squad featuring explosive power hitters, international pacers, and high-discipline fielding drills.',
        category: SearchCategory.teams,
        sport: SportType.cricket,
        sports: [SportType.cricket],
        location: 'Mumbai, India',
        icon: Icons.shield_rounded,
        accentColor: AppColors.cricket,
        metadata: {'wins': 12, 'losses': 4, 'draws': 2, 'captain': 'Arjun Sharma'},
        tags: ['cricket', 'team', 'mavericks', 'mumbai', 't20'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'team_t002',
        title: 'Delhi Dynamos XI',
        subtitle: 'DEL • Cricket Team • North Zone Champions',
        description: 'North zone powerhouse cricket franchise specializing in spin-bowling variations, disciplined death overs bowling, and tactical chasing.',
        category: SearchCategory.teams,
        sport: SportType.cricket,
        sports: [SportType.cricket],
        location: 'Delhi, India',
        icon: Icons.shield_rounded,
        accentColor: AppColors.cricket,
        metadata: {'wins': 10, 'losses': 5, 'draws': 1},
        tags: ['cricket', 'team', 'dynamos', 'delhi'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'team_t003',
        title: 'Bengaluru FC Stars',
        subtitle: 'BFC • Football Club • 8W 3L 5D',
        description: 'Top-tier association football team playing progressive attacking football with high pressing, structured wing play and solid central defence.',
        category: SearchCategory.teams,
        sport: SportType.football,
        sports: [SportType.football],
        location: 'Bangalore, India',
        icon: Icons.shield_rounded,
        accentColor: AppColors.football,
        metadata: {'wins': 8, 'losses': 3, 'draws': 5, 'captain': 'Sunil Chhetri'},
        tags: ['football', 'soccer', 'team', 'bangalore', 'champions'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'team_t004',
        title: 'Chennai Strikers',
        subtitle: 'CHN • Football Club • Southern Derby Contender',
        description: 'Resilient southern football team known for relentless counter-attacking football, organized low block defence, and clinical finishing.',
        category: SearchCategory.teams,
        sport: SportType.football,
        sports: [SportType.football],
        location: 'Chennai, India',
        icon: Icons.shield_rounded,
        accentColor: AppColors.football,
        metadata: {'wins': 9, 'losses': 6, 'draws': 3},
        tags: ['football', 'soccer', 'team', 'chennai', 'strikers'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'team_t005',
        title: 'Hyderabad Hawks',
        subtitle: 'HYD • Basketball Squad • 6W 5L',
        description: 'Pace-and-space basketball squad excelling in perimeter 3-point shooting, quick fast-breaks, and active switch defensive schemes.',
        category: SearchCategory.teams,
        sport: SportType.basketball,
        sports: [SportType.basketball],
        location: 'Hyderabad, India',
        icon: Icons.shield_rounded,
        accentColor: AppColors.basketball,
        metadata: {'wins': 6, 'losses': 5, 'captain': 'Arjun Sharma'},
        tags: ['basketball', 'hoops', 'team', 'hyderabad', 'hawks'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'team_t006',
        title: 'Pune Panthers',
        subtitle: 'PUN • Basketball Squad • Maharashtra Hoops',
        description: 'Physical defensive basketball outfit renowned for paint dominance, offensive rebounding, and half-court grind execution.',
        category: SearchCategory.teams,
        sport: SportType.basketball,
        sports: [SportType.basketball],
        location: 'Pune, India',
        icon: Icons.shield_rounded,
        accentColor: AppColors.basketball,
        metadata: {'wins': 7, 'losses': 4},
        tags: ['basketball', 'hoops', 'team', 'pune', 'panthers'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'team_t007',
        title: 'Kolkata Knights',
        subtitle: 'KKN • Cricket Squad • Eastern Conference',
        description: 'Historic cricket lineup featuring world-class mystery spinners and aggressive middle-order stroke makers who excel under pressure.',
        category: SearchCategory.teams,
        sport: SportType.cricket,
        sports: [SportType.cricket],
        location: 'Kolkata, India',
        icon: Icons.shield_rounded,
        accentColor: AppColors.cricket,
        metadata: {'wins': 11, 'losses': 5},
        tags: ['cricket', 'team', 'kolkata', 'knights'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'team_t008',
        title: 'Rajasthan Royals XI',
        subtitle: 'RRX • Cricket Squad • Jaipur Arena',
        description: 'Vibrant squad focusing on youth athletic fielding, raw pace bowling, and versatile all-round tactical cricket combinations.',
        category: SearchCategory.teams,
        sport: SportType.cricket,
        sports: [SportType.cricket],
        location: 'Jaipur, India',
        icon: Icons.shield_rounded,
        accentColor: AppColors.cricket,
        metadata: {'wins': 9, 'losses': 7},
        tags: ['cricket', 'team', 'rajasthan', 'jaipur'],
      ),
    );

    // ── 3. GROUNDS (VENUES) ───────────────────────────────────────────────────
    items.add(
      const SearchResultItem(
        id: 'ground_wankhede',
        title: 'Wankhede Arena & Ground',
        subtitle: 'Red Clay & Turf Pitch • Floodlights • 33,000 Capacity',
        description: 'World-renowned coastal cricket venue located near Marine Drive. Features professional red-soil bounce pitch, LED floodlight towers, digital sightscreens, full player locker rooms, and spectator grandstands.',
        category: SearchCategory.grounds,
        sport: SportType.cricket,
        sports: [SportType.cricket],
        location: 'Mumbai, India',
        icon: Icons.stadium_rounded,
        accentColor: AppColors.cricket,
        metadata: {
          'price': '₹2,500/hr',
          'rating': 4.9,
          'floodlights': true,
          'surface': 'Red Clay & Turf Pitch',
          'capacity': '33,000',
        },
        tags: ['stadium', 'ground', 'venue', 'cricket', 'pitch', 'mumbai', 'floodlights', 'turf', 'booking'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'ground_kanteerava',
        title: 'Sree Kanteerava Multi-Sport Arena',
        subtitle: 'FIFA 2-Star AstroTurf • Athletics Track • 25,000 Capacity',
        description: 'Premier central Bengaluru stadium equipped with international standard FIFA-certified synthetic astroturf, Olympic synthetic running track, floodlit night capability, and referee review booths.',
        category: SearchCategory.grounds,
        sport: SportType.football,
        sports: [SportType.football],
        location: 'Bangalore, India',
        icon: Icons.stadium_rounded,
        accentColor: AppColors.football,
        metadata: {
          'price': '₹1,800/hr',
          'rating': 4.8,
          'floodlights': true,
          'surface': 'FIFA 2-Star AstroTurf',
          'capacity': '25,000',
        },
        tags: ['stadium', 'ground', 'venue', 'football', 'soccer', 'astroturf', 'bangalore', 'floodlights'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'ground_shivaji_park',
        title: 'Shivaji Park Sports Enclave & Box Turf',
        subtitle: 'Heavy Duty Rubber Infill Turf • Multi-Pitch Cricket & Football',
        description: 'The historic cradle of Indian cricket. Houses traditional multi-pitch cricket pavilions alongside a modern high-intensity rubber-infill turf arena ideal for 7v7 football, box cricket tournaments, and community leagues.',
        category: SearchCategory.grounds,
        sport: SportType.cricket,
        sports: [SportType.cricket, SportType.football],
        location: 'Mumbai, India',
        icon: Icons.stadium_rounded,
        accentColor: AppColors.cricket,
        metadata: {
          'price': '₹1,200/hr',
          'rating': 4.7,
          'floodlights': true,
          'surface': 'Heavy Duty Rubber Infill Turf',
        },
        tags: ['stadium', 'ground', 'turf', 'cricket', 'football', 'mumbai', 'box cricket'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'ground_dlta',
        title: 'DLTA Tennis Arena Complex',
        subtitle: '6 Synthetic Hard Courts • Championship Center Court',
        description: 'National championship tennis venue at Africa Avenue with 6 pro-spec cushioned acrylic hard courts, center stadium court, floodlit evening hours, pro racket stringing shop, and player lounge.',
        category: SearchCategory.grounds,
        sport: SportType.tennis,
        sports: [SportType.tennis],
        location: 'Delhi, India',
        icon: Icons.sports_tennis_rounded,
        accentColor: AppColors.tennis,
        metadata: {
          'price': '₹1,500/hr',
          'rating': 4.9,
          'floodlights': true,
          'surface': '6 Synthetic Hard Courts',
        },
        tags: ['stadium', 'ground', 'court', 'tennis', 'hard court', 'delhi', 'center court'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'ground_eden_gardens',
        title: 'Eden Gardens Arena',
        subtitle: 'Iconic Cricket Stadium • Fast Grass Outfield • 66,000 Seats',
        description: 'Colossal and historic cricket stadium known for its electric atmosphere, lightning-fast outfield, sub-air automated drainage system, and tournament hosting pedigree.',
        category: SearchCategory.grounds,
        sport: SportType.cricket,
        sports: [SportType.cricket],
        location: 'Kolkata, India',
        icon: Icons.stadium_rounded,
        accentColor: AppColors.cricket,
        metadata: {
          'price': '₹3,000/hr',
          'rating': 4.9,
          'floodlights': true,
          'surface': 'Natural Grass & Clay Wickets',
          'capacity': '66,000',
        },
        tags: ['stadium', 'ground', 'cricket', 'kolkata', 'eden gardens'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'ground_st_andrews',
        title: 'St. Andrews Turf Complex',
        subtitle: 'FIFA Quality Pro Artificial Turf • Bandra West',
        description: 'Specialized football facility in suburban Mumbai with premium shock-pad synthetic turf, perimeter rebound netting, team dugouts, changing rooms, and evening floodlights.',
        category: SearchCategory.grounds,
        sport: SportType.football,
        sports: [SportType.football],
        location: 'Mumbai, India',
        icon: Icons.stadium_rounded,
        accentColor: AppColors.football,
        metadata: {
          'price': '₹1,600/hr',
          'rating': 4.8,
          'floodlights': true,
          'surface': 'Pro Artificial Turf',
        },
        tags: ['stadium', 'ground', 'turf', 'football', 'soccer', 'mumbai', 'bandra'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'ground_khar_gymkhana',
        title: 'Khar Gymkhana Tennis Courts',
        subtitle: 'Red Clay & Synthetic DecoTurf Courts',
        description: 'Elite sports club tennis facilities featuring 4 European red clay courts, 2 synthetic hard courts, professional ball boy services, club canteen, and state ranking tournament sanctioning.',
        category: SearchCategory.grounds,
        sport: SportType.tennis,
        sports: [SportType.tennis],
        location: 'Mumbai, India',
        icon: Icons.sports_tennis_rounded,
        accentColor: AppColors.tennis,
        metadata: {
          'price': '₹1,100/hr',
          'rating': 4.8,
          'floodlights': true,
          'surface': 'Clay & DecoTurf',
        },
        tags: ['court', 'tennis', 'clay', 'mumbai', 'ground'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'ground_central_ymc',
        title: 'Central YMC Indoor Arena',
        subtitle: 'Maple Hardwood Wooden Court • Air Conditioned • 3x3 & 5v5',
        description: 'Tournament-ready indoor basketball arena with sprung maple wood floor, official FIBA 24-second shot clocks, ceiling height clearance, electronic scoreboards, and bleachers.',
        category: SearchCategory.grounds,
        sport: SportType.basketball,
        sports: [SportType.basketball],
        location: 'Hyderabad, India',
        icon: Icons.sports_basketball_rounded,
        accentColor: AppColors.basketball,
        metadata: {
          'price': '₹1,400/hr',
          'rating': 4.7,
          'floodlights': true,
          'surface': 'Maple Hardwood Court',
        },
        tags: ['court', 'arena', 'ground', 'basketball', 'indoor', 'hardwood', 'hyderabad'],
      ),
    );

    // ── 4. COMMUNITIES ────────────────────────────────────────────────────────
    items.add(
      const SearchResultItem(
        id: 'comm_mumbai_cricket',
        title: 'Mumbai Cricket Community',
        subtitle: '15,400+ Members • Active Weekend Match Matchmaking',
        description: 'Vibrant local cricket network sharing weekend match fixtures, friendly scrimmages, net bowler recruitment, umpire assignments, and division league scouting updates.',
        category: SearchCategory.communities,
        sport: SportType.cricket,
        sports: [SportType.cricket],
        location: 'Mumbai, India',
        icon: Icons.forum_rounded,
        accentColor: AppColors.cricket,
        metadata: {'members': '15,400', 'postsWeekly': 120, 'isVerified': true},
        tags: ['community', 'cricket', 'mumbai', 'matchmaking', 'scrimmages', 'nets'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'comm_blr_footballers',
        title: 'Bangalore Footballers Collective',
        subtitle: '9,800+ Players • 7v7 Turf Pickups & Tournaments',
        description: 'The largest grassroots football hub in South India. Connect with casual and competitive players, organize Friday night 7v7 turf games, register for knockout cups, and find goalkeepers.',
        category: SearchCategory.communities,
        sport: SportType.football,
        sports: [SportType.football],
        location: 'Bangalore, India',
        icon: Icons.forum_rounded,
        accentColor: AppColors.football,
        metadata: {'members': '9,800', 'postsWeekly': 95, 'isVerified': true},
        tags: ['community', 'football', 'soccer', 'bangalore', 'turf', 'pickup'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'comm_delhi_hoopers',
        title: 'Delhi Hoopers & Streetball Hub',
        subtitle: '6,200+ Ballers • 3x3 Street Runs & Open Gyms',
        description: 'Capital city basketball collective hosting weekend 3x3 pickup battles, open run announcements at public parks, shooting technique breakdowns, and high-school tournament recaps.',
        category: SearchCategory.communities,
        sport: SportType.basketball,
        sports: [SportType.basketball],
        location: 'Delhi, India',
        icon: Icons.forum_rounded,
        accentColor: AppColors.basketball,
        metadata: {'members': '6,200', 'postsWeekly': 64, 'isVerified': true},
        tags: ['community', 'basketball', 'delhi', '3x3', 'streetball', 'hoops'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'comm_tennis_circuit',
        title: 'All-India Tennis Circuit Community',
        subtitle: '4,500+ Players • Racket Reviews & Hitting Partners',
        description: 'National amateur and collegiate tennis group. Find regular hitting partners matching your NTRP rating, read verified string tension reviews, and access state tournament draws.',
        category: SearchCategory.communities,
        sport: SportType.tennis,
        sports: [SportType.tennis],
        location: 'Chennai, India',
        icon: Icons.forum_rounded,
        accentColor: AppColors.tennis,
        metadata: {'members': '4,500', 'postsWeekly': 42, 'isVerified': true},
        tags: ['community', 'tennis', 'chennai', 'hitting partner', 'draws'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'comm_youth_sports',
        title: 'Maharashtra Youth Sports Forum',
        subtitle: '11,200+ Coaches & Athletes • Grassroots Trials',
        description: 'Multi-sport developmental forum connecting youth academies, parents, and certified coaches. Features scholarship notifications, trials calendar, and athletic conditioning webinars.',
        category: SearchCategory.communities,
        sport: null,
        sports: [SportType.cricket, SportType.football, SportType.basketball, SportType.tennis],
        location: 'Mumbai, India',
        icon: Icons.forum_rounded,
        accentColor: AppColors.primary,
        metadata: {'members': '11,200', 'postsWeekly': 80, 'isVerified': true},
        tags: ['community', 'youth', 'grassroots', 'multi-sport', 'trials', 'mumbai'],
      ),
    );

    // Feed Post items converted to searchable community entries
    for (final post in MockData.feedPosts) {
      items.add(
        SearchResultItem(
          id: 'comm_post_${post.id}',
          title: '${post.authorName}\'s Athletic Post',
          subtitle: '${post.sport?.name.toUpperCase() ?? "GENERAL"} • ${post.likes} Likes',
          description: post.content,
          category: SearchCategory.communities,
          sport: post.sport,
          sports: post.sport != null ? [post.sport!] : [],
          location: 'Mumbai, India',
          icon: Icons.article_rounded,
          accentColor: AppColors.primary,
          metadata: {
            'author': post.authorName,
            'likes': post.likes,
            'comments': post.comments,
            'type': 'Post',
          },
          tags: ['post', 'discussion', post.sport?.name ?? 'sports'],
        ),
      );
    }

    // ── 5. CLUBS ──────────────────────────────────────────────────────────────
    items.add(
      const SearchResultItem(
        id: 'club_c001',
        title: 'All Rounders Sports Club',
        subtitle: 'Est. 2018 • Multi-Sport Academy • 420+ Members',
        description: 'Premier sports club in Western India offering elite turf coaching, sanctioned internal leagues, state championship pathways, and high-performance cross-training across Cricket, Football and Basketball.',
        category: SearchCategory.clubs,
        sport: SportType.cricket,
        sports: [SportType.cricket, SportType.football, SportType.basketball],
        location: 'Mumbai, India',
        icon: Icons.sports_score_rounded,
        accentColor: AppColors.primary,
        metadata: {'established': 2018, 'members': 420, 'facilities': 'Gym, Turf, Pavilions'},
        tags: ['club', 'academy', 'mumbai', 'multi-sport', 'cricket', 'football', 'basketball'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'club_c002',
        title: 'South Stars Athletic Club',
        subtitle: 'Est. 2015 • Football & Tennis Center • 310+ Members',
        description: 'Building sports champions in Southern India with state-of-the-art conditioning facilities, floodlit tennis courts, synthetic football grounds, and licensed AFC/ITF certified trainers.',
        category: SearchCategory.clubs,
        sport: SportType.football,
        sports: [SportType.football, SportType.tennis],
        location: 'Bangalore, India',
        icon: Icons.sports_score_rounded,
        accentColor: AppColors.football,
        metadata: {'established': 2015, 'members': 310, 'facilities': 'AstroTurf, Clay Courts'},
        tags: ['club', 'academy', 'bangalore', 'football', 'tennis', 'training'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'club_c003',
        title: 'Mumbai City Athletic Club',
        subtitle: 'Est. 2012 • Premier Football & Track Club',
        description: 'Dedicated suburban football academy with youth age-group teams from U-12 to Senior Division. Features strength & conditioning gym, certified physiotherapists, and seasonal tournament participation.',
        category: SearchCategory.clubs,
        sport: SportType.football,
        sports: [SportType.football],
        location: 'Mumbai, India',
        icon: Icons.sports_score_rounded,
        accentColor: AppColors.football,
        metadata: {'established': 2012, 'members': 280},
        tags: ['club', 'football', 'mumbai', 'academy'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'club_c004',
        title: 'Deccan Hoops & Sports Club',
        subtitle: 'Est. 2019 • Basketball & Fitness Enclave',
        description: 'Hyderabad premier basketball community club. Runs 5v5 corporate leagues, elite youth high-performance camps, shooting lab equipment, and regular inter-club invitational fixtures.',
        category: SearchCategory.clubs,
        sport: SportType.basketball,
        sports: [SportType.basketball],
        location: 'Hyderabad, India',
        icon: Icons.sports_score_rounded,
        accentColor: AppColors.basketball,
        metadata: {'established': 2019, 'members': 240},
        tags: ['club', 'basketball', 'hyderabad', 'hoops'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'club_c005',
        title: 'Chennai Smashers Tennis & Racquet Club',
        subtitle: 'Est. 2010 • Tennis Academy & Pro Circuit',
        description: 'Prestigious racquet sports institution in Chennai. Specializes in junior ITF development, video stroke analysis, international coaching clinics, and sanctioned weekend tennis opens.',
        category: SearchCategory.clubs,
        sport: SportType.tennis,
        sports: [SportType.tennis],
        location: 'Chennai, India',
        icon: Icons.sports_score_rounded,
        accentColor: AppColors.tennis,
        metadata: {'established': 2010, 'members': 390},
        tags: ['club', 'tennis', 'chennai', 'racquet', 'academy'],
      ),
    );

    // ── 6. ASSOCIATIONS ───────────────────────────────────────────────────────
    items.add(
      const SearchResultItem(
        id: 'assoc_imsf',
        title: 'India Multi-Sports Federation',
        subtitle: 'National Apex Council • 48,200+ Members • 312 Clubs',
        description: 'Apex national sporting federation governing amateur multi-discipline athletic competitions, verified tournament sanctions, referee certification programs, and player ranking rosters across all 28 states.',
        category: SearchCategory.associations,
        sport: null,
        sports: [SportType.cricket, SportType.football, SportType.basketball, SportType.tennis],
        location: 'Delhi, India',
        icon: Icons.account_balance_rounded,
        accentColor: AppColors.gold,
        metadata: {'members': '48,200', 'clubs': 312, 'status': 'OFFICIAL SANCTION'},
        tags: ['association', 'federation', 'council', 'national', 'delhi', 'multi-sport', 'bylaws', 'sanctioned'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'assoc_sasc',
        title: 'South Asia Sports Council',
        subtitle: 'Regional Governing Body • 22,800+ Members • 148 Clubs',
        description: 'Regional governing council organizing inter-state championship circuits, bilateral youth athletic exchanges, official scoring handbooks, and grassroots talent development programs in cricket and football.',
        category: SearchCategory.associations,
        sport: SportType.cricket,
        sports: [SportType.cricket, SportType.football],
        location: 'Bangalore, India',
        icon: Icons.account_balance_rounded,
        accentColor: AppColors.primary,
        metadata: {'members': '22,800', 'clubs': 148, 'status': 'OFFICIAL SANCTION'},
        tags: ['association', 'council', 'south asia', 'bangalore', 'cricket', 'football', 'bylaws'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'assoc_piba',
        title: 'Pan-India Basketball Association',
        subtitle: 'Sanctioned Federation • 8,400+ Competitors • 64 Clubs',
        description: 'Official national authority regulating 3x3 street tournaments, full-court 5v5 collegiate leagues, FIBA rule compliance, and referee certification workshops across Indian metropolitan divisions.',
        category: SearchCategory.associations,
        sport: SportType.basketball,
        sports: [SportType.basketball],
        location: 'Hyderabad, India',
        icon: Icons.sports_basketball_rounded,
        accentColor: AppColors.basketball,
        metadata: {'members': '8,400', 'clubs': 64, 'status': 'OFFICIAL SANCTION'},
        tags: ['association', 'basketball', 'federation', 'hyderabad', 'fiba', '3x3'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'assoc_mca',
        title: 'Mumbai Cricket Association (MCA)',
        subtitle: 'Historic Cricket Board • 24 Division Leagues • Mumbai',
        description: 'Official governing board for cricket across Mumbai and Thane districts. Administers the prestigious Kanga League, division club registrations, umpire panels, and age-group state selections.',
        category: SearchCategory.associations,
        sport: SportType.cricket,
        sports: [SportType.cricket],
        location: 'Mumbai, India',
        icon: Icons.sports_cricket_rounded,
        accentColor: AppColors.cricket,
        metadata: {'leagues': 24, 'status': 'OFFICIAL SANCTION', 'athletes': '1,400+'},
        tags: ['association', 'cricket', 'mca', 'mumbai', 'kanga league', 'bylaws'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'assoc_ksfa',
        title: 'Karnataka State Football Association (KSFA)',
        subtitle: 'State Football Federation • Bangalore Super Division',
        description: 'Sanctioned state governing body administering the Bangalore Super Division, '
            'inter-district soccer championships, grassroots AIFF Golden Baby leagues, and referee licenses.',
        category: SearchCategory.associations,
        sport: SportType.football,
        sports: [SportType.football],
        location: 'Bangalore, India',
        icon: Icons.sports_soccer_rounded,
        accentColor: AppColors.football,
        metadata: {'leagues': 18, 'status': 'OFFICIAL SANCTION', 'athletes': '980+'},
        tags: ['association', 'football', 'soccer', 'bangalore', 'ksfa', 'state federation'],
      ),
    );

    items.add(
      const SearchResultItem(
        id: 'assoc_aita',
        title: 'All India Tennis Association (AITA)',
        subtitle: 'National Tennis Governing Body • Grand Prix Draws',
        description: 'Official governing authority for tennis across India. Manages national player rankings, Davis Cup and Billie Jean King Cup preparations, coach certification courses, and talent ranking tournaments.',
        category: SearchCategory.associations,
        sport: SportType.tennis,
        sports: [SportType.tennis],
        location: 'Delhi, India',
        icon: Icons.sports_tennis_rounded,
        accentColor: AppColors.tennis,
        metadata: {'leagues': 12, 'status': 'OFFICIAL SANCTION', 'athletes': '420+'},
        tags: ['association', 'tennis', 'aita', 'delhi', 'national ranking', 'grand slam'],
      ),
    );

    _cachedCatalog = items;
    return items;
  }

  /// Helper to assign realistic home city to famous athletes.
  static String _assignPlayerCity(String name) {
    if (name.contains('Rohit') || name.contains('Bumrah') || name.contains('Pandya') || name.contains('Suryakumar')) {
      return 'Mumbai, India';
    }
    if (name.contains('Virat') || name.contains('Pant') || name.contains('Bellingham') || name.contains('Djokovic')) {
      return 'Delhi, India';
    }
    if (name.contains('Sunil Chhetri') || name.contains('Gurpreet') || name.contains('Curry') || name.contains('Alcaraz')) {
      return 'Bangalore, India';
    }
    if (name.contains('Dhoni') || name.contains('Jadeja') || name.contains('Messi') || name.contains('Bopanna')) {
      return 'Chennai, India';
    }
    if (name.contains('Dončić') || name.contains('Jokić') || name.contains('Starc') || name.contains('Babar')) {
      return 'Hyderabad, India';
    }
    if (name.contains('Gill') || name.contains('Rahul') || name.contains('Ronaldo') || name.contains('Haaland')) {
      return 'Kolkata, India';
    }
    return 'Mumbai, India';
  }

  /// Generates descriptive text for athletes so searches match on both role, playing style, and descriptions.
  static String _generateAthleteDescription(String name, String role, SportType sport) {
    switch (sport) {
      case SportType.cricket:
        return '$name is a professional $role in competitive cricket. Renowned for match-winning tactical execution, fitness, boundary-hitting prowess, disciplined bowling spells, and championship leadership.';
      case SportType.football:
        return '$name is a world-class $role in association football. Known for speed on the ball, tactical spatial awareness, precise passing accuracy, pressing intensity, and decisive goal-scoring abilities.';
      case SportType.basketball:
        return '$name is an elite $role in competitive basketball. Features high basketball IQ, clutch perimeter shot-making, court vision, agile footwork, and aggressive defense.';
      case SportType.tennis:
        return '$name is a top-ranked $role in professional tennis. Celebrated for blistering baseline groundstrokes, clutch serve-and-volley precision, stamina, and mental fortitude in multi-set matches.';
    }
  }

  /// Primary search and filter function.
  /// Matches query against entity name (title) OR any description/subtitle/location/tags.
  /// Supports:
  /// - What to search: [category]
  /// - Location: [location]
  /// - By sports: [sport]
  static List<SearchResultItem> search({
    required String query,
    SearchCategory category = SearchCategory.all,
    String? location,
    SportType? sport,
  }) {
    final allItems = getAllItems();
    final cleanQuery = query.trim().toLowerCase();
    final cleanLocation = (location == null || location.isEmpty || location == 'All Locations' || location == 'All')
        ? null
        : location.trim().toLowerCase();

    final filtered = allItems.where((item) {
      // 1. Filter by Category ("What to search")
      if (category != SearchCategory.all && item.category != category) {
        return false;
      }

      // 2. Filter by Sports ("By sports")
      if (sport != null) {
        final matchesSport = item.matchesSport(sport) || (item.sport == null && item.sports.isEmpty);
        if (!matchesSport) return false;
      }

      // 3. Filter by Location ("Location")
      if (cleanLocation != null) {
        final locMatches = item.location.toLowerCase().contains(cleanLocation);
        if (!locMatches) return false;
      }

      // 4. Match Query against Name or ANY Description / Subtitle / Tag
      if (cleanQuery.isEmpty) return true;

      // Substring match checks
      final titleMatch = item.title.toLowerCase().contains(cleanQuery);
      final descMatch = item.description.toLowerCase().contains(cleanQuery);
      final subtitleMatch = item.subtitle.toLowerCase().contains(cleanQuery);
      final locMatch = item.location.toLowerCase().contains(cleanQuery);
      final tagMatch = item.tags.any((t) => t.toLowerCase().contains(cleanQuery));

      return titleMatch || descMatch || subtitleMatch || locMatch || tagMatch;
    }).toList();

    // Sort by relevance score
    if (cleanQuery.isNotEmpty) {
      filtered.sort((a, b) {
        final scoreA = _calculateRelevance(a, cleanQuery);
        final scoreB = _calculateRelevance(b, cleanQuery);
        return scoreB.compareTo(scoreA);
      });
    }

    return filtered;
  }

  /// Calculates relevance weighting so exact/prefix title matches rank highest.
  static int _calculateRelevance(SearchResultItem item, String query) {
    int score = 0;
    final lowerTitle = item.title.toLowerCase();
    final lowerDesc = item.description.toLowerCase();
    final lowerSub = item.subtitle.toLowerCase();

    if (lowerTitle == query) {
      score += 200;
    } else if (lowerTitle.startsWith(query)) {
      score += 100;
    } else if (lowerTitle.contains(query)) {
      score += 60;
    }

    if (lowerSub.contains(query)) {
      score += 30;
    }

    if (lowerDesc.contains(query)) {
      score += 20;
    }

    if (item.tags.any((t) => t.toLowerCase() == query)) {
      score += 25;
    }

    return score;
  }

  /// Returns available distinct cities for location filters.
  static List<String> getAvailableLocations() {
    return const [
      'All Locations',
      'Mumbai',
      'Bangalore',
      'Delhi',
      'Hyderabad',
      'Kolkata',
      'Chennai',
      'Jaipur',
    ];
  }

  /// Returns popular search tags/keywords for fast exploration.
  static List<String> getPopularKeywords() {
    return const [
      'Mumbai Mavericks',
      'Wankhede',
      'Sunil Chhetri',
      'AstroTurf',
      'Bylaws',
      'Kanga League',
      'Hardwood',
      'Rohit Sharma',
      'Stephen Curry',
      '3x3',
      'Coaching',
      'All Rounders Club',
    ];
  }

  /// Returns count of results grouped by category given active sport & location filters.
  static Map<SearchCategory, int> getCategoryCounts({
    String query = '',
    String? location,
    SportType? sport,
  }) {
    final counts = <SearchCategory, int>{
      SearchCategory.all: 0,
      SearchCategory.players: 0,
      SearchCategory.teams: 0,
      SearchCategory.grounds: 0,
      SearchCategory.communities: 0,
      SearchCategory.clubs: 0,
      SearchCategory.associations: 0,
    };

    for (final cat in SearchCategory.values) {
      final results = search(
        query: query,
        category: cat,
        location: location,
        sport: sport,
      );
      counts[cat] = results.length;
    }
    return counts;
  }
}
