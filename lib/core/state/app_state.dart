import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/user_storage_service.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  UserRole _selectedRole = UserRole.player;
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  int _bottomNavIndex = 0;
  SportType? _activeSportFilter;
  bool _hasSeenOnboarding = false;
  bool _isStateInitialized = false;

  UserRole get selectedRole => _selectedRole;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  int get bottomNavIndex => _bottomNavIndex;
  SportType? get activeSportFilter => _activeSportFilter;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isStateInitialized => _isStateInitialized;

  Future<void> loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final savedLoggedIn = prefs.getBool('is_logged_in') ?? false;
      if (savedLoggedIn) {
        final savedUser = await UserStorageService.loadCurrentUser();
        if (savedUser != null) {
          _currentUser = savedUser;
          _isLoggedIn = true;
          _selectedRole = savedUser.role;
        } else {
          _currentUser = MockData.demoPlayer;
          _isLoggedIn = true;
        }

        // Background sync with Supabase if session active
        final sbUser = SupabaseService.currentUser;
        if (sbUser != null) {
          SupabaseService.fetchPlayerProfile(sbUser.id).then((profile) {
            if (profile != null && _currentUser != null) {
              _currentUser = _currentUser!.copyWith(
                name: profile['full_name'] ?? _currentUser!.name,
                username: profile['username'] ?? _currentUser!.username,
                phone: profile['phone'] ?? _currentUser!.phone,
                hasCompletedProfile: profile['is_verified'] ?? _currentUser!.hasCompletedProfile,
              );
              UserStorageService.saveCurrentUser(_currentUser!);
              notifyListeners();
            }
          }).catchError((_) {});
        }
      }
    } catch (_) {}
    _isStateInitialized = true;
    notifyListeners();
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    _hasSeenOnboarding = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', value);
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    _hasSeenOnboarding = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_seen_onboarding');
    } catch (_) {}
  }

  void setRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void login(UserModel user) async {
    _currentUser = user;
    _isLoggedIn = true;
    _selectedRole = user.role;
    _hasSeenOnboarding = true;
    notifyListeners();
    await UserStorageService.saveCurrentUser(user);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (_) {}
  }

  void logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    _bottomNavIndex = 0;
    notifyListeners();
    await UserStorageService.clearCurrentUser();
    try {
      await SupabaseService.signOut();
    } catch (_) {}
  }

  void updateUserProfile({
    String? name,
    String? bio,
    String? location,
    String? phone,
    String? avatar,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      bio: bio ?? _currentUser!.bio,
      location: location ?? _currentUser!.location,
      phone: phone ?? _currentUser!.phone,
      avatar: avatar ?? _currentUser!.avatar,
    );
    notifyListeners();
    UserStorageService.updateAccountUser(_currentUser!);
  }

  void updateCricketSpecs(CricketSpecs specs) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      cricketSpecs: specs,
      hasCompletedProfile: true,
      primaryRole: specs.summary,
    );
    notifyListeners();
    UserStorageService.updateAccountUser(_currentUser!);
  }

  void updateFootballSpecs(FootballSpecs specs) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      footballSpecs: specs,
      hasCompletedProfile: true,
      primaryRole: specs.summary,
    );
    notifyListeners();
    UserStorageService.updateAccountUser(_currentUser!);
  }

  void updateBasketballSpecs(BasketballSpecs specs) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      basketballSpecs: specs,
      hasCompletedProfile: true,
      primaryRole: specs.summary,
    );
    notifyListeners();
    UserStorageService.updateAccountUser(_currentUser!);
  }

  void updateTennisSpecs(TennisSpecs specs) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      tennisSpecs: specs,
      hasCompletedProfile: true,
      primaryRole: specs.summary,
    );
    notifyListeners();
    UserStorageService.updateAccountUser(_currentUser!);
  }

  List<MatchModel> _matches = [];

  List<MatchModel> get allMatches {
    if (_matches.isEmpty) initMatchesIfEmpty();
    return List.unmodifiable(_matches);
  }

  List<MatchModel> get liveMatches {
    if (_matches.isEmpty) initMatchesIfEmpty();
    return _matches.where((m) => m.status == MatchStatus.live).toList();
  }

  List<MatchModel> get upcomingMatches {
    if (_matches.isEmpty) initMatchesIfEmpty();
    return _matches.where((m) => m.status == MatchStatus.upcoming).toList();
  }

  List<MatchModel> get completedMatches {
    if (_matches.isEmpty) initMatchesIfEmpty();
    return _matches.where((m) => m.status == MatchStatus.completed).toList();
  }

  void initMatchesIfEmpty() {
    if (_matches.isEmpty) {
      _matches = [
        ...MockData.liveMatches,
        ...MockData.upcomingMatches,
      ];
    }
  }

  void addMatch(MatchModel match) {
    if (_matches.isEmpty) initMatchesIfEmpty();
    _matches.insert(0, match);
    notifyListeners();
  }

  void updateMatchScore(String matchId, dynamic scoreData, {MatchStatus? status, String? resultText}) {
    if (_matches.isEmpty) initMatchesIfEmpty();
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      final current = _matches[index];
      _matches[index] = current.copyWith(
        scoreData: scoreData,
        status: status ?? current.status,
        resultText: resultText ?? current.resultText,
      );
      notifyListeners();
    }
  }

  void completeMatch(String matchId, {String? resultText}) {
    if (_matches.isEmpty) initMatchesIfEmpty();
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      final current = _matches[index];
      _matches[index] = current.copyWith(
        status: MatchStatus.completed,
        resultText: resultText ?? current.resultText,
      );
      notifyListeners();
    }
  }

  void setBottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  void setActiveSportFilter(SportType? sport) {
    _activeSportFilter = sport;
    notifyListeners();
  }

  SportType? get selectedSport => _activeSportFilter;

  List<FeedPost> _feedPosts = [];

  List<FeedPost> get feedPosts {
    if (_feedPosts.isEmpty) {
      _feedPosts = List.from(MockData.feedPosts);
    }
    return _feedPosts;
  }

  void togglePostLike(String postId) {
    if (_feedPosts.isEmpty) _feedPosts = List.from(MockData.feedPosts);
    final idx = _feedPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = _feedPosts[idx];
      post.isLiked = !post.isLiked;
      if (post.isLiked) {
        post.likes++;
      } else {
        post.likes = (post.likes > 0) ? post.likes - 1 : 0;
      }
      notifyListeners();
    }
  }

  void togglePostRepost(String postId) {
    if (_feedPosts.isEmpty) _feedPosts = List.from(MockData.feedPosts);
    final idx = _feedPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = _feedPosts[idx];
      post.isReposted = !post.isReposted;
      if (post.isReposted) {
        post.reposts++;
      } else {
        post.reposts = (post.reposts > 0) ? post.reposts - 1 : 0;
      }
      notifyListeners();
    }
  }

  void togglePostBookmark(String postId) {
    if (_feedPosts.isEmpty) _feedPosts = List.from(MockData.feedPosts);
    final idx = _feedPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = _feedPosts[idx];
      post.isBookmarked = !post.isBookmarked;
      notifyListeners();
    }
  }

  void incrementPostComments(String postId) {
    if (_feedPosts.isEmpty) _feedPosts = List.from(MockData.feedPosts);
    final idx = _feedPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _feedPosts[idx].comments++;
      notifyListeners();
    }
  }
}

// ─── Mock Data Provider ───────────────────────────────────────────────────────

class MockData {
  static final UserModel demoPlayer = UserModel(
    id: 'u001',
    name: 'Arjun Sharma',
    username: 'arjun_plays',
    email: 'arjun@worldsports.com',
    avatar: '',
    role: UserRole.player,
    sports: [
      SportType.cricket,
      SportType.football,
      SportType.basketball,
      SportType.tennis,
    ],
    followers: 1247,
    following: 389,
    location: 'Mumbai, India',
    bio: 'Multi-sport competitive athlete | Cricket, Football, Basketball & Lawn Tennis | Elite League competitor.',
    stats: {
      SportType.cricket: const PlayerStats(
        sport: SportType.cricket,
        matchesPlayed: 48,
        wins: 31,
        losses: 17,
        rating: 4.3,
        specificStats: {
          'primary_role': 'All-Rounder (Batting Main)',
          'runs': 1842,
          'wickets': 23,
          'hundreds': 3,
          'fifties': 12,
          'batting_avg': 41.2,
          'bowling_avg': 28.5,
          'strike_rate': 138.4,
          'roles': {
            'Batting': {
              'Career Runs': '1,842',
              'Batting Avg': '41.2',
              'Strike Rate': '138.4',
              'Centuries (100s)': '3',
              'Half-Centuries (50s)': '12',
              'Highest Score': '114*',
              'Boundaries (4s/6s)': '184 / 46',
              'Innings Played': '44',
            },
            'Bowling': {
              'Wickets': '23',
              'Bowling Avg': '28.5',
              'Economy Rate': '6.84',
              'Best Bowling': '4/22',
              'Overs Bowled': '112.4',
              'Maidens': '8',
              'Dot Ball %': '48.2%',
            },
            'Fielding': {
              'Catches': '19',
              'Direct Run Outs': '5',
              'Stumpings': '0',
              'Catching Efficiency': '92.5%',
            },
          },
        },
      ),
      SportType.football: const PlayerStats(
        sport: SportType.football,
        matchesPlayed: 36,
        wins: 22,
        losses: 14,
        rating: 4.1,
        specificStats: {
          'primary_role': 'Playmaker Midfielder',
          'goals': 18,
          'assists': 24,
          'clean_sheets': 0,
          'position': 'Midfielder',
          'pass_accuracy': '87.4%',
          'roles': {
            'Midfield': {
              'Assists': '24',
              'Pass Accuracy': '87.4%',
              'Key Passes': '58',
              'Through Balls': '31',
              'Chances Created': '42',
              'Dribble Success': '68.0%',
            },
            'Attack': {
              'Goals': '18',
              'Shots on Target': '42',
              'Shot Conversion': '21.4%',
              'Penalty Goals': '4/4',
              'Expected Goals (xG)': '15.8',
            },
            'Defense': {
              'Tackles Won': '34',
              'Interceptions': '27',
              'Ball Recoveries': '62',
              'Duels Won': '59.0%',
              'Blocks': '11',
            },
          },
        },
      ),
      SportType.basketball: const PlayerStats(
        sport: SportType.basketball,
        matchesPlayed: 21,
        wins: 14,
        losses: 7,
        rating: 3.8,
        specificStats: {
          'primary_role': 'Point Guard',
          'points': 312,
          'rebounds': 87,
          'assists': 63,
          'steals': 28,
          'position': 'Point Guard',
          'roles': {
            'Point Guard': {
              'Assists': '63',
              'Steals': '28',
              'AST/TO Ratio': '2.4',
              'Fast Break Pts': '46',
              'Floor General Rating': '89.0',
            },
            'Scoring': {
              'Total Points': '312',
              'Points Per Game': '14.8',
              'Field Goal %': '46.8%',
              '3-Point %': '38.2%',
              'Free Throw %': '84.0%',
            },
            'Defense & Rebounds': {
              'Total Rebounds': '87',
              'Defensive Boards': '69',
              'Blocks': '12',
              'Defensive Rating': '104.2',
            },
          },
        },
      ),
      SportType.tennis: const PlayerStats(
        sport: SportType.tennis,
        matchesPlayed: 24,
        wins: 18,
        losses: 6,
        rating: 4.4,
        specificStats: {
          'primary_role': 'Singles Baseline Aggressor',
          'is_individual': true,
          'individual_wins': 18,
          'individual_losses': 6,
          'aces': 142,
          'first_serve_pct': '68.5%',
          'roles': {
            'Singles': {
              'Match Record': '18W - 6L',
              'Win Rate': '75.0%',
              'Aces': '142',
              '1st Serve %': '68.5%',
              '1st Serve Pts Won': '73.2%',
              'Break Points Won': '48.1%',
              'Tiebreak Win %': '80.0%',
            },
            'Doubles': {
              'Match Record': '6W - 2L',
              'Win Rate': '75.0%',
              'Net Points Won': '64.0%',
              'Service Games Held': '82.5%',
              'Return Winners': '22',
            },
          },
        },
      ),
    },
  );

  static final UserModel demoCoach = UserModel(
    id: 'u002',
    name: 'Priya Menon',
    username: 'coach_priya',
    email: 'priya@worldsports.com',
    avatar: '',
    role: UserRole.coach,
    sports: [SportType.tennis, SportType.cricket],
    followers: 3218,
    following: 142,
    location: 'Bangalore, India',
    bio: 'High Performance Head Coach | 12 years professional circuit experience | National level tennis director.',
    stats: {},
  );

  static final UserModel demoOrganiser = UserModel(
    id: 'u003',
    name: 'Rajiv Sports Foundation',
    username: 'rajiv_sports',
    email: 'rajiv@worldsports.com',
    avatar: '',
    role: UserRole.organiser,
    sports: [SportType.cricket, SportType.football, SportType.basketball, SportType.tennis],
    followers: 8902,
    following: 67,
    location: 'Delhi, India',
    bio: 'Organising premier multi-sport invitational tournaments and youth developmental championships.',
    stats: {},
  );

  static final UserModel demoUmpire = UserModel(
    id: 'u004',
    userId: 'WS-9004',
    name: 'Anil Chaudhary',
    username: 'anil_umpire',
    email: 'anil@worldsports.com',
    avatar: '',
    role: UserRole.umpire,
    primarySport: SportType.cricket,
    primaryRole: 'Certified Elite Umpire',
    hasCompletedProfile: true,
    sports: [SportType.cricket, SportType.football],
    followers: 3410,
    following: 112,
    location: 'Delhi, India',
    bio: 'BCCI & MCA Certified Elite Umpire • 180+ matches officiated • Tournament referee & technical bylaws director.',
    stats: {},
  );

  static final List<MatchModel> liveMatches = [
    MatchModel(
      id: 'm001',
      sport: SportType.cricket,
      team1Id: 't001',
      team2Id: 't002',
      team1Name: 'Mumbai Mavericks',
      team2Name: 'Delhi Dynamos',
      team1Short: 'MUM',
      team2Short: 'DEL',
      dateTime: DateTime.now(),
      venue: 'Wankhede Stadium, Mumbai',
      tournamentId: 'tr001',
      status: MatchStatus.live,
      creatorId: 'u001',
      tossWinner: 'Delhi Dynamos',
      tossDecision: 'elected to bowl first',
      team1Players: const [
        MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman', isCaptain: true),
        MatchPlayer(id: 'c2', name: 'Virat Kohli', jerseyNumber: 18, role: 'Top-Order Batsman'),
        MatchPlayer(id: 'c7', name: 'Suryakumar Yadav', jerseyNumber: 63, role: 'Middle Order'),
        MatchPlayer(id: 'c5', name: 'Hardik Pandya', jerseyNumber: 33, role: 'All-Rounder'),
        MatchPlayer(id: 'c3', name: 'MS Dhoni', jerseyNumber: 7, role: 'Wicketkeeper', isWicketKeeperOrGoalkeeper: true),
        MatchPlayer(id: 'c6', name: 'Ravindra Jadeja', jerseyNumber: 8, role: 'All-Rounder'),
        MatchPlayer(id: 'c4', name: 'Jasprit Bumrah', jerseyNumber: 93, role: 'Fast Bowler'),
      ],
      team2Players: const [
        MatchPlayer(id: 'c9', name: 'Shubman Gill', jerseyNumber: 77, role: 'Opening Batsman', isCaptain: true),
        MatchPlayer(id: 'c13', name: 'KL Rahul', jerseyNumber: 1, role: 'Wicketkeeper', isWicketKeeperOrGoalkeeper: true),
        MatchPlayer(id: 'c8', name: 'Rishabh Pant', jerseyNumber: 17, role: 'Middle Order'),
        MatchPlayer(id: 'c16', name: 'Ben Stokes', jerseyNumber: 55, role: 'All-Rounder'),
        MatchPlayer(id: 'c10', name: 'Pat Cummins', jerseyNumber: 30, role: 'Fast Bowler'),
        MatchPlayer(id: 'c12', name: 'Rashid Khan', jerseyNumber: 19, role: 'Spin Bowler'),
        MatchPlayer(id: 'c14', name: 'Mitchell Starc', jerseyNumber: 56, role: 'Fast Bowler'),
      ],
      scoreData: {
        'team1_score': '187/4',
        'team1_overs': '18.2',
        'team2_score': '165/8',
        'team2_overs': '20.0',
        'status_text': 'MUM need 23 runs in 10 balls',
        'current_batsmen': ['Rahul K.', 'Suresh M.'],
        'current_bowler': 'Arjun S.',
      },
    ),
    MatchModel(
      id: 'm002',
      sport: SportType.football,
      team1Id: 't003',
      team2Id: 't004',
      team1Name: 'Bengaluru FC Stars',
      team2Name: 'Chennai Strikers',
      team1Short: 'BFC',
      team2Short: 'CHN',
      dateTime: DateTime.now(),
      venue: 'Sree Kanteerava Stadium',
      tournamentId: 'tr002',
      status: MatchStatus.live,
      creatorId: 'u002',
      tossWinner: 'Bengaluru FC Stars',
      tossDecision: 'kicked off first half',
      team1Players: const [
        MatchPlayer(id: 'f1', name: 'Sunil Chhetri', jerseyNumber: 11, role: 'Forward / Striker', isCaptain: true),
        MatchPlayer(id: 'f8', name: 'Gurpreet Singh Sandhu', jerseyNumber: 1, role: 'Goalkeeper', isWicketKeeperOrGoalkeeper: true),
        MatchPlayer(id: 'f9', name: 'Sandesh Jhingan', jerseyNumber: 5, role: 'Center Back'),
        MatchPlayer(id: 'f15', name: 'Sahal Abdul Samad', jerseyNumber: 10, role: 'Attacking Midfielder'),
        MatchPlayer(id: 'f6', name: 'Suresh R.', jerseyNumber: 8, role: 'Midfielder'),
        MatchPlayer(id: 'f11', name: 'Amit P.', jerseyNumber: 7, role: 'Left Winger'),
      ],
      team2Players: const [
        MatchPlayer(id: 'f2', name: 'Lionel Messi', jerseyNumber: 10, role: 'Forward / Playmaker', isCaptain: true),
        MatchPlayer(id: 'f16', name: 'Alisson Becker', jerseyNumber: 1, role: 'Goalkeeper', isWicketKeeperOrGoalkeeper: true),
        MatchPlayer(id: 'f12', name: 'Virgil van Dijk', jerseyNumber: 4, role: 'Center Back'),
        MatchPlayer(id: 'f7', name: 'Luka Modrić', jerseyNumber: 10, role: 'Central Midfielder'),
        MatchPlayer(id: 'f4', name: 'Kiran M.', jerseyNumber: 9, role: 'Forward / Winger'),
        MatchPlayer(id: 'f10', name: 'Jude Bellingham', jerseyNumber: 5, role: 'Attacking Midfielder'),
      ],
      scoreData: {
        'team1_score': 2,
        'team2_score': 1,
        'minute': 67,
        'status_text': '67\' - 2nd Half',
        'events': [
          {'type': 'goal', 'team': 1, 'player': 'Suresh R.', 'minute': 23},
          {'type': 'goal', 'team': 2, 'player': 'Kiran M.', 'minute': 41},
          {'type': 'goal', 'team': 1, 'player': 'Amit P.', 'minute': 58},
        ],
      },
    ),
    MatchModel(
      id: 'm003',
      sport: SportType.basketball,
      team1Id: 't005',
      team2Id: 't006',
      team1Name: 'Hyderabad Hawks',
      team2Name: 'Pune Panthers',
      team1Short: 'HYD',
      team2Short: 'PUN',
      dateTime: DateTime.now(),
      venue: 'Indoor Sports Complex, Hyd',
      status: MatchStatus.live,
      creatorId: 'u003',
      team1Players: const [
        MatchPlayer(id: 'b1', name: 'Stephen Curry', jerseyNumber: 30, role: 'Point Guard', isCaptain: true),
        MatchPlayer(id: 'b12', name: 'Klay Thompson', jerseyNumber: 11, role: 'Shooting Guard'),
        MatchPlayer(id: 'b13', name: 'Draymond Green', jerseyNumber: 23, role: 'Power Forward'),
        MatchPlayer(id: 'b10', name: 'Jimmy Butler', jerseyNumber: 22, role: 'Small Forward'),
        MatchPlayer(id: 'b8', name: 'Anthony Davis', jerseyNumber: 3, role: 'Center'),
      ],
      team2Players: const [
        MatchPlayer(id: 'b2', name: 'LeBron James', jerseyNumber: 23, role: 'Small Forward', isCaptain: true),
        MatchPlayer(id: 'b3', name: 'Luka Dončić', jerseyNumber: 77, role: 'Point Guard'),
        MatchPlayer(id: 'b4', name: 'Giannis Antetokounmpo', jerseyNumber: 34, role: 'Power Forward'),
        MatchPlayer(id: 'b5', name: 'Nikola Jokić', jerseyNumber: 15, role: 'Center'),
        MatchPlayer(id: 'b9', name: 'Kyrie Irving', jerseyNumber: 11, role: 'Point Guard'),
      ],
      scoreData: {
        'team1_score': 68,
        'team2_score': 72,
        'quarter': 3,
        'time_left': '4:23',
        'status_text': 'Q3 - 4:23 remaining',
      },
    ),
  ];

  static final List<MatchModel> upcomingMatches = [
    MatchModel(
      id: 'm004',
      sport: SportType.tennis,
      team1Id: 'p001',
      team2Id: 'p002',
      team1Name: 'Rohan Bopanna',
      team2Name: 'Sriram Balaji',
      team1Short: 'ROH',
      team2Short: 'SRI',
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      venue: 'DLTA Complex, Delhi',
      status: MatchStatus.upcoming,
    ),
    MatchModel(
      id: 'm005',
      sport: SportType.cricket,
      team1Id: 't007',
      team2Id: 't008',
      team1Name: 'Kolkata Knights',
      team2Name: 'Rajasthan Royals XI',
      team1Short: 'KKN',
      team2Short: 'RRX',
      dateTime: DateTime.now().add(const Duration(hours: 6)),
      venue: 'Eden Gardens, Kolkata',
      status: MatchStatus.upcoming,
    ),
  ];

  static final List<TournamentModel> tournaments = [
    TournamentModel(
      id: 'tr001',
      name: 'WorldSports Premier Cup',
      sport: SportType.cricket,
      organiserId: 'u003',
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 12)),
      location: 'Mumbai, India',
      teamsCount: 16,
      format: 'Round Robin + Knockout',
      prizePool: '₹5,00,000',
      status: MatchStatus.live,
    ),
    TournamentModel(
      id: 'tr002',
      name: 'South India Football League',
      sport: SportType.football,
      organiserId: 'u003',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 20)),
      location: 'Bangalore, India',
      teamsCount: 12,
      format: 'League',
      prizePool: '₹2,50,000',
      status: MatchStatus.live,
    ),
    TournamentModel(
      id: 'tr003',
      name: 'National Basketball Championship',
      sport: SportType.basketball,
      organiserId: 'u003',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 25)),
      location: 'Delhi, India',
      teamsCount: 8,
      format: 'Knockout',
      prizePool: '₹1,50,000',
      status: MatchStatus.upcoming,
    ),
    TournamentModel(
      id: 'tr004',
      name: 'All India Tennis Open',
      sport: SportType.tennis,
      organiserId: 'u003',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 21)),
      location: 'Chennai, India',
      teamsCount: 32,
      format: 'Singles & Doubles',
      prizePool: '₹80,000',
      status: MatchStatus.upcoming,
    ),
  ];

  static final List<TeamModel> teams = [
    TeamModel(
      id: 't001',
      name: 'Mumbai Mavericks',
      shortName: 'MUM',
      sport: SportType.cricket,
      captainId: 'u001',
      wins: 12,
      losses: 4,
      draws: 2,
      location: 'Mumbai',
      color: AppColors.cricket,
    ),
    TeamModel(
      id: 't003',
      name: 'Bengaluru FC Stars',
      shortName: 'BFC',
      sport: SportType.football,
      captainId: 'u001',
      wins: 8,
      losses: 3,
      draws: 5,
      location: 'Bangalore',
      color: AppColors.football,
    ),
    TeamModel(
      id: 't005',
      name: 'Hyderabad Hawks',
      shortName: 'HYD',
      sport: SportType.basketball,
      captainId: 'u001',
      wins: 6,
      losses: 5,
      draws: 0,
      location: 'Hyderabad',
      color: AppColors.basketball,
    ),
  ];

  static final List<ClubModel> clubs = [
    ClubModel(
      id: 'c001',
      name: 'All Rounders Sports Club',
      sports: [SportType.cricket, SportType.football, SportType.basketball],
      memberIds: ['u001'],
      location: 'Mumbai, India',
      description: 'Premier multi-sports club in Western India.',
      established: 2018,
    ),
    ClubModel(
      id: 'c002',
      name: 'South Stars Athletic Club',
      sports: [SportType.football, SportType.tennis],
      memberIds: [],
      location: 'Bangalore, India',
      description: 'Building champions in Southern India since 2015.',
      established: 2015,
    ),
  ];

  static List<FeedPost> feedPosts = [
    FeedPost(
      id: 'fp001',
      authorId: 'u004',
      authorName: 'Mumbai Cricket Association',
      authorHandle: '@MCA_Cricket',
      isVerified: true,
      category: 'Association Notice',
      title: 'Senior Division Squad Roster Submissions',
      content:
          'OFFICIAL: Registrations are officially open for the Senior Division T20 League! Affiliated clubs must submit verified 15-player rosters and medical clearances by Oct 20. #MumbaiCricket #T20League #ClubCircuit',
      sport: SportType.cricket,
      mediaHeadline: 'Senior Division T20 League • ₹5L Verified Prize Pool',
      mediaSubtitle: 'mumbaicricket.org/division-roster',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 342,
      comments: 47,
      reposts: 28,
    ),
    FeedPost(
      id: 'fp002',
      authorId: 'u005',
      authorName: 'Western Super League',
      authorHandle: '@WSL_Football',
      isVerified: true,
      category: 'Derby Highlights',
      title: 'Metro Super Division Derby Stalemate',
      content:
          'FULL TIME DRAMA at St. Andrews! Bandra Athletic and Santacruz Strikers fight to a breathless 1-1 draw in front of 3,200 fans. Sunil Chhetri with a thunderous 23\' header! #SuperDivision #FootballDerby #StAndrewsTurf',
      sport: SportType.football,
      mediaHeadline: 'Bandra Athletic 1 - 1 Santacruz Strikers • Match Highlights',
      mediaSubtitle: 'westernleague.org/derby-recap',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      likes: 645,
      comments: 89,
      reposts: 112,
    ),
    FeedPost(
      id: 'fp003',
      authorId: 'u001',
      authorName: 'Arjun Sharma',
      authorHandle: '@arjun_plays',
      isVerified: true,
      category: 'Player Journal',
      title: 'Centurion Milestone',
      content:
          'Clinical victory today! Completed my 3rd century of the division season against Dadar Union. Dedicated preparation and discipline paying off. Strong execution by Mumbai Mavericks! #Centurion #MatchWinner #GrindNeverStops',
      sport: SportType.cricket,
      mediaHeadline: '112* (64 balls) vs Dadar Union • Player of the Match',
      mediaSubtitle: 'worldsports.app/m001/scorecard',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      likes: 428,
      comments: 54,
      reposts: 19,
    ),
    FeedPost(
      id: 'fp004',
      authorId: 'u006',
      authorName: 'All-India Tennis Federation',
      authorHandle: '@AITA_Circuit',
      isVerified: true,
      category: 'Circuit Bulletin',
      title: 'National Ranking Championship Draws',
      content:
          'Official draws confirmed for the All-India Ranking Slam at Khar Gymkhana courts. Top seeded players advance to the main draw tomorrow 9:00 AM. Free spectator entry with WorldSports badge! #RankingSlam #AITA #IndianTennis',
      sport: SportType.tennis,
      mediaHeadline: 'National Ranking Slam 2024 Draws & Schedule',
      mediaSubtitle: 'aitatennis.org/slam-schedule',
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      likes: 276,
      comments: 31,
      reposts: 42,
    ),
    FeedPost(
      id: 'fp005',
      authorId: 'u007',
      authorName: 'Urban Hoops 3x3',
      authorHandle: '@UrbanHoops3x3',
      isVerified: true,
      category: 'Federation Notice',
      title: 'State 3x3 Basketball Rules Standardized',
      content:
          'Starting this Saturday, all sanctioned division 3x3 tournaments will adopt official FIBA 12-second shot clock and foul penalty regulations. Get ready for faster, higher-intensity basketball! #FIBA #UrbanHoops #3x3Tour',
      sport: SportType.basketball,
      mediaHeadline: 'FIBA Standard 3x3 Regulations Manual 2024',
      mediaSubtitle: 'urbanhoops.org/regulations',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 389,
      comments: 42,
      reposts: 64,
    ),
  ];

  static final List<NearbyMatchModel> nearbyMatches = [
    const NearbyMatchModel(
      id: 'nb001',
      sport: SportType.cricket,
      matchTitle: 'South Zone T20 League',
      teams: 'Shivaji Park Gymkhana vs Dadar Union',
      team1Name: 'Shivaji Park Gymkhana',
      team2Name: 'Dadar Union',
      team1Score: '142/3',
      team1Overs: '16.4',
      team2Score: '138/9',
      team2Overs: '20.0',
      isTeam1Active: true,
      venue: 'Shivaji Park Arena, Ground 2',
      distance: '1.2 km away',
      statusText: 'SPG need 7 runs in 20 balls',
      isLive: true,
    ),
    const NearbyMatchModel(
      id: 'nb002',
      sport: SportType.football,
      matchTitle: 'Metro Super Division Derby',
      teams: 'Bandra Athletic vs Santacruz Strikers',
      team1Name: 'Bandra Athletic Club',
      team2Name: 'Santacruz Strikers',
      team1Score: '2',
      team2Score: '1',
      isTeam1Active: true,
      venue: 'St. Andrews Turf Complex',
      distance: '2.4 km away',
      statusText: '54\' • 2nd Half',
      isLive: true,
    ),
    const NearbyMatchModel(
      id: 'nb003',
      sport: SportType.tennis,
      matchTitle: 'District Ranking Semi-Final',
      teams: 'A. Kulkarni vs R. Iyer',
      team1Name: 'Anand Kulkarni',
      team2Name: 'Rohan Iyer',
      team1Score: '6  4',
      team1Overs: '40-30',
      team2Score: '4  3',
      team2Overs: '',
      isTeam1Active: true,
      venue: 'Khar Gymkhana Tennis Courts',
      distance: '3.1 km away',
      statusText: 'Set 2 • Game 8',
      isLive: true,
    ),
    const NearbyMatchModel(
      id: 'nb004',
      sport: SportType.basketball,
      matchTitle: 'Urban 3x3 Championship',
      teams: 'Ghatkopar Dunkers vs Powai Titans',
      team1Name: 'Ghatkopar Dunkers',
      team2Name: 'Powai Titans',
      team1Score: '18',
      team2Score: '15',
      isTeam1Active: true,
      venue: 'Central YMC Indoor Arena',
      distance: '4.8 km away',
      statusText: 'Final 2 Mins',
      isLive: true,
    ),
  ];

  static final List<SportsUpdateModel> sportsUpdates = [
    const SportsUpdateModel(
      id: 'su001',
      title: 'National T20 Circuit: Quarterfinals Announced',
      summary: 'Top 8 city division squads qualify for the knockout stage beginning this Saturday. Fixtures and streaming schedule released.',
      category: 'Tournament Circuit',
      sport: SportType.cricket,
      timeAgo: '2h ago',
    ),
    const SportsUpdateModel(
      id: 'su002',
      title: 'New FIFA Standard Synthetic Turf Inaugurated',
      summary: 'Western sports authority opens the Olympic standard astroturf complex for club league bookings and night tournaments.',
      category: 'Facilities & Arena',
      sport: SportType.football,
      timeAgo: '4h ago',
    ),
    const SportsUpdateModel(
      id: 'su003',
      title: 'All-India Ranking Tennis Slam: Entries Closing',
      summary: 'Sanctioned ranking points tournament registration enters final 48 hours for singles and doubles draws.',
      category: 'Association Tour',
      sport: SportType.tennis,
      timeAgo: '7h ago',
    ),
    const SportsUpdateModel(
      id: 'su004',
      title: 'State 3x3 Basketball Rules Standardized',
      summary: 'State federation aligns regional tournament shot clocks and foul penalty regulations with FIBA international standards.',
      category: 'Federation Notice',
      sport: SportType.basketball,
      timeAgo: '1d ago',
    ),
  ];

  static final List<ClubAssociationUpdateModel> clubAssociationUpdates = [
    const ClubAssociationUpdateModel(
      id: 'cu001',
      sourceName: 'Mumbai Cricket Association',
      sourceType: 'Association',
      title: 'Division Squad Roster Submissions Open',
      content: 'Affiliated clubs must submit verified player rosters and medical clearance by October 15 for the Senior League.',
      dateText: 'Deadline: Oct 15',
      actionLabel: 'VIEW CIRCULAR',
    ),
    const ClubAssociationUpdateModel(
      id: 'cu002',
      sourceName: 'All Rounders Sports Club',
      sourceType: 'Club',
      title: 'Specialized Nets & Tactical Video Analysis',
      content: 'Mandatory session for First XI and Reserve squads tomorrow morning 6:00 AM at the Club Pavilion.',
      dateText: 'Tomorrow 6:00 AM',
      actionLabel: 'CONFIRM ATTENDANCE',
    ),
    const ClubAssociationUpdateModel(
      id: 'cu003',
      sourceName: 'WorldSports Premier Cup 2024',
      sourceType: 'Tournament',
      title: 'Quarterfinal Bracket Confirmed: Mumbai Mavericks vs Delhi Dynamos',
      content: 'Your squad Mumbai Mavericks is scheduled on Main Pitch for Matchday 12.',
      dateText: 'Live Matchday 12',
      actionLabel: 'VIEW BRACKET',
    ),
  ];

  static final List<PreviousMatchModel> previousMatches = [
    PreviousMatchModel(
      id: 'pm001',
      sport: SportType.cricket,
      team1Name: 'Mumbai Mavericks',
      team2Name: 'Pune Warriors XI',
      team1Short: 'MUM',
      team2Short: 'PUN',
      team1Score: '198/5 (20.0)',
      team2Score: '172/9 (20.0)',
      resultText: 'Won by 26 runs',
      isWin: true,
      date: DateTime.now().subtract(const Duration(days: 2)),
      venue: 'Wankhede Stadium, Mumbai',
      myPerformance: '74*(46) & 2/28 (4.0)',
      mvpPlayer: 'Arjun Sharma',
    ),
    PreviousMatchModel(
      id: 'pm002',
      sport: SportType.football,
      team1Name: 'Bengaluru FC Stars',
      team2Name: 'Goa Coast FC',
      team1Short: 'BFC',
      team2Short: 'GOA',
      team1Score: '3',
      team2Score: '1',
      resultText: 'Won 3-1',
      isWin: true,
      date: DateTime.now().subtract(const Duration(days: 5)),
      venue: 'Sree Kanteerava Stadium',
      myPerformance: '2 Goals, 1 Assist (88 mins)',
      mvpPlayer: 'Arjun Sharma',
    ),
    PreviousMatchModel(
      id: 'pm003',
      sport: SportType.basketball,
      team1Name: 'Hyderabad Hawks',
      team2Name: 'Chennai Titans',
      team1Short: 'HYD',
      team2Short: 'CHN',
      team1Score: '82',
      team2Score: '86',
      resultText: 'Lost 82-86',
      isWin: false,
      date: DateTime.now().subtract(const Duration(days: 8)),
      venue: 'Indoor Sports Complex, Hyd',
      myPerformance: '24 Pts, 8 Reb, 6 Ast',
    ),
    PreviousMatchModel(
      id: 'pm004',
      sport: SportType.tennis,
      team1Name: 'Arjun Sharma',
      team2Name: 'Vikram Malhotra',
      team1Short: 'ARJ',
      team2Short: 'VIK',
      team1Score: '6-4, 7-5',
      team2Score: '4-6, 5-7',
      resultText: 'Won in straight sets',
      isWin: true,
      date: DateTime.now().subtract(const Duration(days: 12)),
      venue: 'MSLTA Tennis Centre',
      myPerformance: '11 Aces, 78% First Serve Win',
      mvpPlayer: 'Arjun Sharma',
    ),
    PreviousMatchModel(
      id: 'pm005',
      sport: SportType.cricket,
      team1Name: 'Mumbai Mavericks',
      team2Name: 'Gujarat Titans XI',
      team1Short: 'MUM',
      team2Short: 'GTX',
      team1Score: '165/8 (20.0)',
      team2Score: '166/4 (18.5)',
      resultText: 'Lost by 6 wickets',
      isWin: false,
      date: DateTime.now().subtract(const Duration(days: 16)),
      venue: 'Brabourne Stadium, Mumbai',
      myPerformance: '38(29) & 1/32 (3.5)',
    ),
  ];

  static final List<SportSkillModel> athleteSkills = [
    // Cricket
    const SportSkillModel(sport: SportType.cricket, skillName: 'Power Hitting', score: 92, tier: 'Elite', category: 'Power'),
    const SportSkillModel(sport: SportType.cricket, skillName: 'Bowling Pace & Seam', score: 86, tier: 'Master', category: 'Technique'),
    const SportSkillModel(sport: SportType.cricket, skillName: 'Reflex Catching', score: 89, tier: 'Master', category: 'Fielding'),
    const SportSkillModel(sport: SportType.cricket, skillName: 'Tactical Match Reading', score: 94, tier: 'Elite', category: 'Tactics'),

    // Football
    const SportSkillModel(sport: SportType.football, skillName: 'Sprint Speed', score: 91, tier: 'Elite', category: 'Pace'),
    const SportSkillModel(sport: SportType.football, skillName: 'Ball Control & Dribbling', score: 88, tier: 'Master', category: 'Technique'),
    const SportSkillModel(sport: SportType.football, skillName: 'Vision & Key Passes', score: 85, tier: 'Master', category: 'Playmaking'),
    const SportSkillModel(sport: SportType.football, skillName: 'Clinical Finishing', score: 84, tier: 'Pro', category: 'Power'),

    // Basketball
    const SportSkillModel(sport: SportType.basketball, skillName: 'Perimeter Shooting', score: 83, tier: 'Pro', category: 'Technique'),
    const SportSkillModel(sport: SportType.basketball, skillName: 'Court Vision & Assists', score: 89, tier: 'Master', category: 'Tactics'),
    const SportSkillModel(sport: SportType.basketball, skillName: 'Fast Break Transition', score: 87, tier: 'Master', category: 'Pace'),

    // Tennis
    const SportSkillModel(sport: SportType.tennis, skillName: 'First Serve Velocity', score: 87, tier: 'Master', category: 'Power'),
    const SportSkillModel(sport: SportType.tennis, skillName: 'Baseline Forehand Topspin', score: 90, tier: 'Elite', category: 'Technique'),
    const SportSkillModel(sport: SportType.tennis, skillName: 'Lateral Court Agility', score: 93, tier: 'Elite', category: 'Pace'),
  ];

  static final List<AchievementModel> achievements = [
    const AchievementModel(
      id: 'ach001',
      title: 'Division MVP Trophy',
      sport: SportType.cricket,
      year: '2024',
      description: 'Awarded Most Valuable Player across 14 League Fixtures (3 Hundreds, 1842 Runs).',
      icon: Icons.military_tech_rounded,
    ),
    const AchievementModel(
      id: 'ach002',
      title: 'Golden Boot Winner',
      sport: SportType.football,
      year: '2023',
      description: 'Top goal scorer in the Metro Championship with 18 goals and 24 assists.',
      icon: Icons.sports_soccer_rounded,
    ),
    const AchievementModel(
      id: 'ach003',
      title: 'Century Milestone Crest',
      sport: SportType.cricket,
      year: '2024',
      description: 'Recognized for achieving back-to-back match-winning centuries in finals.',
      icon: Icons.workspace_premium_rounded,
    ),
    const AchievementModel(
      id: 'ach004',
      title: 'District Open Singles Finalist',
      sport: SportType.tennis,
      year: '2023',
      description: 'Runner-up in the AITA sanctioned Western State Championship.',
      icon: Icons.emoji_events_rounded,
    ),
  ];
}
