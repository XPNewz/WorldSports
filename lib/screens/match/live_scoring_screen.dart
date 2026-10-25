import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import 'widgets/cricket_field_selector.dart';
import 'widgets/match_analytics_graphs.dart';

/// Models for detailed scorecard and timeline tracking
class CricketBattingRecord {
  final MatchPlayer player;
  int runs;
  int balls;
  int fours;
  int sixes;
  bool isOut;
  String dismissal;

  CricketBattingRecord({
    required this.player,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.isOut = false,
    this.dismissal = 'not out',
  });

  double get strikeRate => balls > 0 ? (runs / balls) * 100 : 0.0;

  Map<String, dynamic> toMap() => {
    'player': player.toMap(),
    'name': player.name,
    'user_id': player.userId,
    'runs': runs,
    'balls': balls,
    'fours': fours,
    'sixes': sixes,
    'is_out': isOut,
    'dismissal': dismissal,
  };

  factory CricketBattingRecord.fromMap(Map<String, dynamic> map, {MatchPlayer? fallbackPlayer}) {
    MatchPlayer p;
    if (map['player'] is Map) {
      p = MatchPlayer.fromMap(Map<String, dynamic>.from(map['player'] as Map));
    } else if (fallbackPlayer != null) {
      p = fallbackPlayer;
    } else {
      p = MatchPlayer(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        jerseyNumber: (map['jersey_number'] as num?)?.toInt() ?? 0,
        userId: map['user_id'] ?? '',
      );
    }
    return CricketBattingRecord(
      player: p,
      runs: (map['runs'] as num?)?.toInt() ?? 0,
      balls: (map['balls'] as num?)?.toInt() ?? 0,
      fours: (map['fours'] as num?)?.toInt() ?? 0,
      sixes: (map['sixes'] as num?)?.toInt() ?? 0,
      isOut: map['is_out'] ?? false,
      dismissal: map['dismissal'] ?? (map['is_out'] == true ? 'out' : 'not out'),
    );
  }
}

class CricketBowlingRecord {
  final MatchPlayer player;
  int balls;
  int maidens;
  int runs;
  int wickets;

  CricketBowlingRecord({
    required this.player,
    this.balls = 0,
    this.maidens = 0,
    this.runs = 0,
    this.wickets = 0,
  });

  String get oversStr => '${balls ~/ 6}.${balls % 6}';
  double get economy => balls > 0 ? (runs / (balls / 6.0)) : 0.0;

  Map<String, dynamic> toMap() => {
    'player': player.toMap(),
    'name': player.name,
    'user_id': player.userId,
    'balls': balls,
    'maidens': maidens,
    'runs': runs,
    'wickets': wickets,
  };

  factory CricketBowlingRecord.fromMap(Map<String, dynamic> map, {MatchPlayer? fallbackPlayer}) {
    MatchPlayer p;
    if (map['player'] is Map) {
      p = MatchPlayer.fromMap(Map<String, dynamic>.from(map['player'] as Map));
    } else if (fallbackPlayer != null) {
      p = fallbackPlayer;
    } else {
      p = MatchPlayer(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        jerseyNumber: (map['jersey_number'] as num?)?.toInt() ?? 0,
        userId: map['user_id'] ?? '',
      );
    }
    return CricketBowlingRecord(
      player: p,
      balls: (map['balls'] as num?)?.toInt() ?? 0,
      maidens: (map['maidens'] as num?)?.toInt() ?? 0,
      runs: (map['runs'] as num?)?.toInt() ?? 0,
      wickets: (map['wickets'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Innings dataset for Stumps-style multi-innings scorecard
class CricketInningsData {
  final int inningsNumber;
  final String battingTeamName;
  final String battingTeamShort;
  final String bowlingTeamName;
  final String bowlingTeamShort;
  int runs;
  int wickets;
  int balls;
  int extrasWides;
  int extrasNoBalls;
  int extrasByes;
  int extrasLegByes;
  final Map<String, CricketBattingRecord> battingRecords;
  final Map<String, CricketBowlingRecord> bowlingRecords;
  final List<String> fallOfWickets;
  bool isCompleted;
  String? completionReason;

  CricketInningsData({
    required this.inningsNumber,
    required this.battingTeamName,
    required this.battingTeamShort,
    required this.bowlingTeamName,
    required this.bowlingTeamShort,
    this.runs = 0,
    this.wickets = 0,
    this.balls = 0,
    this.extrasWides = 0,
    this.extrasNoBalls = 0,
    this.extrasByes = 0,
    this.extrasLegByes = 0,
    Map<String, CricketBattingRecord>? battingRecords,
    Map<String, CricketBowlingRecord>? bowlingRecords,
    List<String>? fallOfWickets,
    this.isCompleted = false,
    this.completionReason,
  })  : battingRecords = battingRecords ?? {},
        bowlingRecords = bowlingRecords ?? {},
        fallOfWickets = fallOfWickets ?? [];

  int get totalExtras => extrasWides + extrasNoBalls + extrasByes + extrasLegByes;
  String get oversStr => '${balls ~/ 6}.${balls % 6}';
  double get runRate => balls > 0 ? (runs / (balls / 6.0)) : 0.0;

  Map<String, dynamic> toMap() => {
    'innings_number': inningsNumber,
    'batting_team_name': battingTeamName,
    'batting_team_short': battingTeamShort,
    'bowling_team_name': bowlingTeamName,
    'bowling_team_short': bowlingTeamShort,
    'runs': runs,
    'wickets': wickets,
    'balls': balls,
    'extras_wides': extrasWides,
    'extras_no_balls': extrasNoBalls,
    'extras_byes': extrasByes,
    'extras_leg_byes': extrasLegByes,
    'is_completed': isCompleted,
    'completion_reason': completionReason,
    'batting': battingRecords.map((k, v) => MapEntry(k, v.toMap())),
    'bowling': bowlingRecords.map((k, v) => MapEntry(k, v.toMap())),
    'fall_of_wickets': fallOfWickets,
  };

  factory CricketInningsData.fromMap(Map<String, dynamic> map, {List<MatchPlayer>? allSquad}) {
    final batting = <String, CricketBattingRecord>{};
    if (map['batting'] is Map) {
      (map['batting'] as Map).forEach((k, v) {
        if (v is Map) {
          final pId = k.toString();
          MatchPlayer? fallback = allSquad != null
              ? allSquad.firstWhere(
                  (p) => p.id == pId,
                  orElse: () => MatchPlayer(
                    id: pId,
                    name: v['name']?.toString() ?? 'Player',
                    jerseyNumber: 0,
                    userId: v['user_id']?.toString() ?? '',
                  ),
                )
              : null;
          batting[pId] = CricketBattingRecord.fromMap(Map<String, dynamic>.from(v), fallbackPlayer: fallback);
        }
      });
    }

    final bowling = <String, CricketBowlingRecord>{};
    if (map['bowling'] is Map) {
      (map['bowling'] as Map).forEach((k, v) {
        if (v is Map) {
          final pId = k.toString();
          MatchPlayer? fallback = allSquad != null
              ? allSquad.firstWhere(
                  (p) => p.id == pId,
                  orElse: () => MatchPlayer(
                    id: pId,
                    name: v['name']?.toString() ?? 'Player',
                    jerseyNumber: 0,
                    userId: v['user_id']?.toString() ?? '',
                  ),
                )
              : null;
          bowling[pId] = CricketBowlingRecord.fromMap(Map<String, dynamic>.from(v), fallbackPlayer: fallback);
        }
      });
    }

    return CricketInningsData(
      inningsNumber: (map['innings_number'] as num?)?.toInt() ?? 1,
      battingTeamName: map['batting_team_name'] ?? 'Batting Team',
      battingTeamShort: map['batting_team_short'] ?? 'BAT',
      bowlingTeamName: map['bowling_team_name'] ?? 'Bowling Team',
      bowlingTeamShort: map['bowling_team_short'] ?? 'BOWL',
      runs: (map['runs'] as num?)?.toInt() ?? 0,
      wickets: (map['wickets'] as num?)?.toInt() ?? 0,
      balls: (map['balls'] as num?)?.toInt() ?? 0,
      extrasWides: (map['extras_wides'] as num?)?.toInt() ?? 0,
      extrasNoBalls: (map['extras_no_balls'] as num?)?.toInt() ?? 0,
      extrasByes: (map['extras_byes'] as num?)?.toInt() ?? 0,
      extrasLegByes: (map['extras_leg_byes'] as num?)?.toInt() ?? 0,
      isCompleted: map['is_completed'] ?? false,
      completionReason: map['completion_reason'],
      battingRecords: batting,
      bowlingRecords: bowling,
      fallOfWickets: List<String>.from(map['fall_of_wickets'] ?? []),
    );
  }
}

class MatchTimelineItem {
  final String timeOrOver;
  final String title;
  final String description;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final String teamShort;

  const MatchTimelineItem({
    required this.timeOrOver,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.teamShort,
  });

  Map<String, dynamic> toMap() => {
    'time_or_over': timeOrOver,
    'title': title,
    'description': description,
    'badge_text': badgeText,
    'badge_color': badgeColor.toARGB32(),
    'badge_text_color': badgeTextColor.toARGB32(),
    'team_short': teamShort,
  };

  factory MatchTimelineItem.fromMap(Map<String, dynamic> map) {
    return MatchTimelineItem(
      timeOrOver: map['time_or_over']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      badgeText: map['badge_text']?.toString() ?? '',
      badgeColor: map['badge_color'] != null ? Color((map['badge_color'] as num).toInt()) : const Color(0xFF059669),
      badgeTextColor: map['badge_text_color'] != null ? Color((map['badge_text_color'] as num).toInt()) : Colors.white,
      teamShort: map['team_short']?.toString() ?? '',
    );
  }
}

class LiveScoringScreen extends StatefulWidget {
  final MatchModel match;
  const LiveScoringScreen({super.key, required this.match});

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen> with SingleTickerProviderStateMixin {
  late MatchModel _match;
  late TabController _tabController;
  bool _simulateViewer = false;

  // History stack for Undo
  final List<dynamic> _history = [];

  // Cricket State
  int _cricketInnings = 1;
  int _cricketRuns = 0;
  int _cricketWickets = 0;
  int _cricketBalls = 0;
  List<String> _currentOverBalls = [];
  int _targetRuns = 0;
  int _team1FinalRuns = 0;
  int _team1FinalWickets = 0;
  String _team1FinalOvers = '0.0';

  // Multi-Innings Scorecard Data (Stumps-Style)
  late CricketInningsData _innings1;
  late CricketInningsData _innings2;
  int _selectedScorecardInnings = 1;
  int _maxOvers = 20;
  int _maxWickets = 10;
  bool _isCricketInningsOver = false;
  bool _isMatchAbandoned = false;
  String? _abandonReason;

  CricketInningsData get _currentInningsData => _cricketInnings == 1 ? _innings1 : _innings2;
  Map<String, CricketBattingRecord> get _battingRecords => _currentInningsData.battingRecords;
  Map<String, CricketBowlingRecord> get _bowlingRecords => _currentInningsData.bowlingRecords;
  List<String> get _fallOfWickets => _currentInningsData.fallOfWickets;

  String? _lastOverBowlerId;
  bool _hasPromptedOpeners = false;
  String? _calculatedMvpPlayer;

  bool get _isTestCricket => _match.format.toLowerCase().contains('test');

  bool get _team1BatsFirst {
    if (_match.sport != SportType.cricket) return true;

    // 1. Check if scoreData explicitly recorded team1_bats_first or innings1
    if (_match.scoreData is Map) {
      final sd = _match.scoreData as Map;
      if (sd['team1_bats_first'] != null) {
        return sd['team1_bats_first'] == true;
      }
      if (sd['innings1'] != null && sd['innings1'] is Map) {
        final inn1 = sd['innings1'] as Map;
        final bTeam = inn1['batting_team_name']?.toString().trim().toLowerCase() ?? '';
        final t1Name = _match.team1Name.trim().toLowerCase();
        final t1Short = _match.team1Short.trim().toLowerCase();
        if (bTeam.isNotEmpty && (t1Name.isNotEmpty || t1Short.isNotEmpty)) {
          if (bTeam == t1Name || bTeam == t1Short) return true;
          return false;
        }
      }
    }

    // 2. Compute from tossWinner & tossDecision
    final tossWinner = _match.tossWinner.trim().toLowerCase();
    final team1NameLower = _match.team1Name.trim().toLowerCase();
    final team2NameLower = _match.team2Name.trim().toLowerCase();
    final team1ShortLower = _match.team1Short.trim().toLowerCase();
    final team2ShortLower = _match.team2Short.trim().toLowerCase();

    bool isTeam1TossWinner = true;
    if (tossWinner.isNotEmpty) {
      if (tossWinner == team2NameLower || tossWinner == team2ShortLower) {
        isTeam1TossWinner = false;
      } else if (team2NameLower.isNotEmpty && (tossWinner.contains(team2NameLower) || team2NameLower.contains(tossWinner))) {
        isTeam1TossWinner = false;
      } else if (tossWinner == team1NameLower || tossWinner == team1ShortLower) {
        isTeam1TossWinner = true;
      } else if (team1NameLower.isNotEmpty && (tossWinner.contains(team1NameLower) || team1NameLower.contains(tossWinner))) {
        isTeam1TossWinner = true;
      }
    }

    final decisionLower = _match.tossDecision.trim().toLowerCase();
    final isElectedToBat = !decisionLower.contains('bowl') && !decisionLower.contains('field');

    return (isTeam1TossWinner && isElectedToBat) || (!isTeam1TossWinner && !isElectedToBat);
  }

  List<MatchPlayer> get _firstInningsBattingSquad => _team1BatsFirst ? _match.team1Players : _match.team2Players;
  List<MatchPlayer> get _firstInningsBowlingSquad => _team1BatsFirst ? _match.team2Players : _match.team1Players;
  String get _firstInningsBattingTeamName => _team1BatsFirst ? _match.team1Name : _match.team2Name;
  String get _firstInningsBattingTeamShort => _team1BatsFirst ? _match.team1Short : _match.team2Short;
  String get _firstInningsBowlingTeamName => _team1BatsFirst ? _match.team2Name : _match.team1Name;
  String get _firstInningsBowlingTeamShort => _team1BatsFirst ? _match.team2Short : _match.team1Short;

  List<MatchPlayer> get _secondInningsBattingSquad => _team1BatsFirst ? _match.team2Players : _match.team1Players;
  List<MatchPlayer> get _secondInningsBowlingSquad => _team1BatsFirst ? _match.team1Players : _match.team2Players;
  String get _secondInningsBattingTeamName => _team1BatsFirst ? _match.team2Name : _match.team1Name;
  String get _secondInningsBattingTeamShort => _team1BatsFirst ? _match.team2Short : _match.team1Short;
  String get _secondInningsBowlingTeamName => _team1BatsFirst ? _match.team1Name : _match.team2Name;
  String get _secondInningsBowlingTeamShort => _team1BatsFirst ? _match.team2Short : _match.team1Short;

  List<MatchPlayer> get _currentBattingSquad => _cricketInnings == 1 ? _firstInningsBattingSquad : _secondInningsBattingSquad;
  List<MatchPlayer> get _currentBowlingSquad => _cricketInnings == 1 ? _firstInningsBowlingSquad : _secondInningsBowlingSquad;
  String get _currentBattingTeamName => _cricketInnings == 1 ? _firstInningsBattingTeamName : _secondInningsBattingTeamName;
  String get _currentBattingTeamShort => _cricketInnings == 1 ? _firstInningsBattingTeamShort : _secondInningsBattingTeamShort;
  String get _currentBowlingTeamName => _cricketInnings == 1 ? _firstInningsBowlingTeamName : _secondInningsBowlingTeamName;
  String get _currentBowlingTeamShort => _cricketInnings == 1 ? _firstInningsBowlingTeamShort : _secondInningsBowlingTeamShort;

  // Active Batsmen & Bowler
  late MatchPlayer _striker;
  late MatchPlayer _nonStriker;
  late MatchPlayer _currentBowler;
  int _strikerRuns = 0;
  int _strikerBalls = 0;
  int _nonStrikerRuns = 0;
  int _nonStrikerBalls = 0;

  int _bowlerRuns = 0;
  int _bowlerBalls = 0;
  int _bowlerWickets = 0;

  // Timeline / Commentary Log
  final List<MatchTimelineItem> _timelineFeed = [];

  // Football State
  int _footballScoreTeam1 = 0;
  int _footballScoreTeam2 = 0;
  int _footballMinutes = 1;
  String _footballPeriod = '1st Half';
  bool _footballTimerRunning = true;
  Timer? _footballTimer;
  final List<Map<String, dynamic>> _footballEvents = [];

  // Basketball State
  int _basketballScoreTeam1 = 0;
  int _basketballScoreTeam2 = 0;
  int _basketballQuarter = 1;
  int _basketballFoulsTeam1 = 0;
  int _basketballFoulsTeam2 = 0;
  int _basketballSeconds = 600; // 10 mins
  bool _basketballTimerRunning = true;
  Timer? _basketballTimer;

  // Tennis State
  int _tennisSetsTeam1 = 0;
  int _tennisSetsTeam2 = 0;
  int _tennisPointsIndex1 = 0;
  int _tennisPointsIndex2 = 0;
  int _tennisGamesTeam1 = 0;
  int _tennisGamesTeam2 = 0;
  final List<Map<String, int>> _tennisCompletedSets = [];
  int _tennisServer = 1;

  // Table Tennis State
  bool _isTableTennisMode = false;
  int _ttGamesTeam1 = 0;
  int _ttGamesTeam2 = 0;
  int _ttPointsTeam1 = 0;
  int _ttPointsTeam2 = 0;
  int _ttServer = 1; // alternates every 2 points
  final List<Map<String, int>> _ttCompletedGames = [];

  // Cricket Analytics, Worm, Manhattan & Wagon Wheel State
  final List<CricketShotResult> _matchShots = [];
  final List<CricketOverProgress> _t1OverProgress = [];
  final List<CricketOverProgress> _t2OverProgress = [];
  int _team1TotalFours = 0;
  int _team1TotalSixes = 0;
  int _team2TotalFours = 0;
  int _team2TotalSixes = 0;
  int _team1DotBalls = 0;
  int _team2DotBalls = 0;

  // Squad display active team toggle
  int _selectedSquadTeam = 1;

  bool get isCreator {
    final currentUser = context.read<AppState>().currentUser;
    final currentUserId = currentUser?.id ?? 'u001';
    final matchCreatorId = _match.creatorId;
    return (currentUserId == matchCreatorId) && !_simulateViewer;
  }

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    _tabController = TabController(length: 6, vsync: this);
    _initSportState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && isCreator && !_hasPromptedOpeners && _match.sport == SportType.cricket && _match.status != MatchStatus.completed && _cricketBalls == 0 && _cricketRuns == 0) {
        _showOpenersSelectionSheet(isSecondInnings: false);
      }
    });
  }

  void _initSportState() {
    final t1 = _match.team1Players;
    final t2 = _match.team2Players;
    final inn1BatSquad = _firstInningsBattingSquad;
    final inn1BowlSquad = _firstInningsBowlingSquad;

    // Cricket
    _striker = inn1BatSquad.isNotEmpty ? inn1BatSquad[0] : (t1.isNotEmpty ? t1[0] : const MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman'));
    _nonStriker = inn1BatSquad.length > 1 ? inn1BatSquad[1] : (t1.length > 1 ? t1[1] : const MatchPlayer(id: 'c2', name: 'Virat Kohli', jerseyNumber: 18, role: 'Top-Order Batsman'));
    _currentBowler = inn1BowlSquad.isNotEmpty ? inn1BowlSquad.last : (t2.isNotEmpty ? t2.last : const MatchPlayer(id: 'c10', name: 'Pat Cummins', jerseyNumber: 30, role: 'Fast Bowler'));

    final bool isDemoMatch = _match.id == 'm001' || _match.id == 'm002' || _match.id == 'm003' || _match.id == 'm004';

    // Parse pre-existing score data if any (e.g. from mock matches)
    if (_match.sport == SportType.cricket) {
      int parsedOvers = 20;
      if (_match.scoreData is Map && (_match.scoreData as Map)['overs_limit'] != null) {
        final ol = (_match.scoreData as Map)['overs_limit'];
        if (ol is int && ol > 0) {
          parsedOvers = ol;
        } else if (ol is String) {
          parsedOvers = int.tryParse(ol) ?? 20;
        }
      } else {
        final regex = RegExp(r'(\d+)\s*(?:overs|over|-over|ov)', caseSensitive: false);
        final match = regex.firstMatch(_match.format);
        if (match != null) {
          parsedOvers = int.tryParse(match.group(1)!) ?? 20;
        }
      }
      _maxOvers = parsedOvers;
      _maxWickets = inn1BatSquad.isNotEmpty ? math.min(10, math.max(1, inn1BatSquad.length - 1)) : 10;

      _innings1 = CricketInningsData(
        inningsNumber: 1,
        battingTeamName: _firstInningsBattingTeamName,
        battingTeamShort: _firstInningsBattingTeamShort,
        bowlingTeamName: _firstInningsBowlingTeamName,
        bowlingTeamShort: _firstInningsBowlingTeamShort,
      );

      _innings2 = CricketInningsData(
        inningsNumber: 2,
        battingTeamName: _secondInningsBattingTeamName,
        battingTeamShort: _secondInningsBattingTeamShort,
        bowlingTeamName: _secondInningsBowlingTeamName,
        bowlingTeamShort: _secondInningsBowlingTeamShort,
      );

      // Pre-fill Innings 2 provisional squads
      for (final p in _secondInningsBattingSquad) {
        _innings2.battingRecords[p.id] = CricketBattingRecord(
          player: p,
          runs: 0,
          balls: 0,
          fours: 0,
          sixes: 0,
          isOut: false,
          dismissal: 'yet to bat',
        );
      }
      for (final p in _secondInningsBowlingSquad) {
        _innings2.bowlingRecords[p.id] = CricketBowlingRecord(
          player: p,
          balls: 0,
          runs: 0,
          wickets: 0,
          maidens: 0,
        );
      }

      if (!isDemoMatch && _match.scoreData is Map && (_match.scoreData as Map)['innings1'] != null) {
        final sd = _match.scoreData as Map;
        final allSquad = [...t1, ...t2];
        _innings1 = CricketInningsData.fromMap(Map<String, dynamic>.from(sd['innings1']), allSquad: allSquad);
        if (sd['innings2'] != null) {
          _innings2 = CricketInningsData.fromMap(Map<String, dynamic>.from(sd['innings2']), allSquad: allSquad);
        }
        _cricketInnings = (sd['current_innings'] as num?)?.toInt() ?? 1;
        _selectedScorecardInnings = _cricketInnings;
        _targetRuns = (sd['target_runs'] as num?)?.toInt() ?? 0;
        _team1FinalRuns = (sd['team1_final_runs'] as num?)?.toInt() ?? _innings1.runs;
        _team1FinalWickets = (sd['team1_final_wickets'] as num?)?.toInt() ?? _innings1.wickets;
        _team1FinalOvers = sd['team1_final_overs']?.toString() ?? _innings1.oversStr;
        _lastOverBowlerId = sd['last_over_bowler_id']?.toString();
        _calculatedMvpPlayer = sd['mvp_player']?.toString();

        final activeInn = _cricketInnings == 1 ? _innings1 : _innings2;
        _cricketRuns = activeInn.runs;
        _cricketWickets = activeInn.wickets;
        _cricketBalls = activeInn.balls;
        final activeBatSquad = _cricketInnings == 1 ? _firstInningsBattingSquad : _secondInningsBattingSquad;
        _maxWickets = activeBatSquad.isNotEmpty ? math.min(10, math.max(1, activeBatSquad.length - 1)) : 10;

        final strikerId = sd['striker_id']?.toString();
        final nonStrikerId = sd['non_striker_id']?.toString();
        final bowlerId = sd['bowler_id']?.toString();

        if (strikerId != null) {
          _striker = allSquad.firstWhere((p) => p.id == strikerId, orElse: () => _striker);
        } else if (_cricketInnings == 2 && _secondInningsBattingSquad.isNotEmpty) {
          _striker = _secondInningsBattingSquad[0];
        }
        if (nonStrikerId != null) {
          _nonStriker = allSquad.firstWhere((p) => p.id == nonStrikerId, orElse: () => _nonStriker);
        } else if (_cricketInnings == 2 && _secondInningsBattingSquad.length > 1) {
          _nonStriker = _secondInningsBattingSquad[1];
        }
        if (bowlerId != null) {
          _currentBowler = allSquad.firstWhere((p) => p.id == bowlerId, orElse: () => _currentBowler);
        } else if (_cricketInnings == 2 && _secondInningsBowlingSquad.isNotEmpty) {
          _currentBowler = _secondInningsBowlingSquad.last;
        }

        _strikerRuns = (sd['striker_runs'] as num?)?.toInt() ?? (_battingRecords[_striker.id]?.runs ?? 0);
        _strikerBalls = (sd['striker_balls'] as num?)?.toInt() ?? (_battingRecords[_striker.id]?.balls ?? 0);
        _nonStrikerRuns = (sd['non_striker_runs'] as num?)?.toInt() ?? (_battingRecords[_nonStriker.id]?.runs ?? 0);
        _nonStrikerBalls = (sd['non_striker_balls'] as num?)?.toInt() ?? (_battingRecords[_nonStriker.id]?.balls ?? 0);

        _bowlerRuns = (sd['bowler_runs'] as num?)?.toInt() ?? (_bowlingRecords[_currentBowler.id]?.runs ?? 0);
        _bowlerBalls = (sd['bowler_balls'] as num?)?.toInt() ?? (_bowlingRecords[_currentBowler.id]?.balls ?? 0);
        _bowlerWickets = (sd['bowler_wickets'] as num?)?.toInt() ?? (_bowlingRecords[_currentBowler.id]?.wickets ?? 0);

        _isCricketInningsOver = _match.status == MatchStatus.completed || activeInn.isCompleted;
        _hasPromptedOpeners = true;

        if (sd['timeline'] is List) {
          _timelineFeed.clear();
          for (final itemMap in (sd['timeline'] as List)) {
            if (itemMap is Map) {
              _timelineFeed.add(MatchTimelineItem.fromMap(Map<String, dynamic>.from(itemMap)));
            }
          }
        }
        if (sd['t1_over_progress'] is List) {
          _t1OverProgress.clear();
          for (final opMap in (sd['t1_over_progress'] as List)) {
            if (opMap is Map) {
              _t1OverProgress.add(CricketOverProgress.fromMap(Map<String, dynamic>.from(opMap)));
            }
          }
        }
        if (sd['t2_over_progress'] is List) {
          _t2OverProgress.clear();
          for (final opMap in (sd['t2_over_progress'] as List)) {
            if (opMap is Map) {
              _t2OverProgress.add(CricketOverProgress.fromMap(Map<String, dynamic>.from(opMap)));
            }
          }
        }
        if (sd['match_shots'] is List) {
          _matchShots.clear();
          for (final shotMap in (sd['match_shots'] as List)) {
            if (shotMap is Map) {
              _matchShots.add(CricketShotResult.fromMap(Map<String, dynamic>.from(shotMap)));
            }
          }
        }
        _team1TotalFours = (sd['team1_fours'] as num?)?.toInt() ?? 0;
        _team1TotalSixes = (sd['team1_sixes'] as num?)?.toInt() ?? 0;
        _team2TotalFours = (sd['team2_fours'] as num?)?.toInt() ?? 0;
        _team2TotalSixes = (sd['team2_sixes'] as num?)?.toInt() ?? 0;
        _team1DotBalls = (sd['team1_dot_balls'] as num?)?.toInt() ?? 0;
        _team2DotBalls = (sd['team2_dot_balls'] as num?)?.toInt() ?? 0;
        if (sd['current_over_balls'] is List) {
          _currentOverBalls = List<String>.from(sd['current_over_balls']);
        }
      } else if (isDemoMatch && _match.scoreData is Map) {
        final sd = _match.scoreData as Map;
        if (sd['team1_score'] != null) {
          final parts = sd['team1_score'].toString().split('/');
          _cricketRuns = int.tryParse(parts[0]) ?? 0;
          if (parts.length > 1) {
            _cricketWickets = int.tryParse(parts[1]) ?? 0;
          }
        }
        if (sd['team1_overs'] != null) {
          final overParts = sd['team1_overs'].toString().split('.');
          final o = int.tryParse(overParts[0]) ?? 0;
          final b = overParts.length > 1 ? int.tryParse(overParts[1]) ?? 0 : 0;
          _cricketBalls = (o * 6) + b;
        }
        _strikerRuns = 42;
        _strikerBalls = 26;
        _nonStrikerRuns = 38;
        _nonStrikerBalls = 24;
        _bowlerRuns = 28;
        _bowlerBalls = 20;
        _bowlerWickets = 1;

        for (final p in t1) {
          _innings1.battingRecords[p.id] = CricketBattingRecord(
            player: p,
            runs: p.id == _striker.id ? _strikerRuns : (p.id == _nonStriker.id ? _nonStrikerRuns : (p.id == 'c7' ? 24 : 0)),
            balls: p.id == _striker.id ? _strikerBalls : (p.id == _nonStriker.id ? _nonStrikerBalls : (p.id == 'c7' ? 14 : 0)),
            fours: p.id == _striker.id ? 5 : 2,
            sixes: p.id == _striker.id ? 2 : 1,
            isOut: p.id == 'c7',
            dismissal: p.id == 'c7' ? 'c Pant b Cummins' : 'not out *',
          );
        }
        for (final p in t2) {
          _innings1.bowlingRecords[p.id] = CricketBowlingRecord(
            player: p,
            balls: p.id == _currentBowler.id ? _bowlerBalls : 18,
            runs: p.id == _currentBowler.id ? _bowlerRuns : 22,
            wickets: p.id == _currentBowler.id ? _bowlerWickets : 1,
            maidens: 0,
          );
        }

        _innings1.runs = _cricketRuns;
        _innings1.wickets = _cricketWickets;
        _innings1.balls = _cricketBalls;

        _team1TotalFours = 18;
        _team1TotalSixes = 6;
        _team2TotalFours = 15;
        _team2TotalSixes = 4;
        _team1DotBalls = 36;
        _team2DotBalls = 44;
        _targetRuns = 166; // Team 2 set 165

        // Seed realistic CricHeroes/Stumps over-by-over progression for Team 1 (MUM)
        final t1OverRuns = [8, 12, 6, 8, 14, 10, 7, 9, 4, 11, 15, 8, 12, 18, 9, 13, 11, 12];
        final t1WicketsByOver = {4: 1, 9: 1, 15: 1, 18: 1};
        int cumT1Runs = 0;
        int cumT1W = 0;
        for (int ov = 1; ov <= t1OverRuns.length; ov++) {
          final r = t1OverRuns[ov - 1];
          cumT1Runs += r;
          if (t1WicketsByOver.containsKey(ov)) cumT1W += t1WicketsByOver[ov]!;
          _t1OverProgress.add(
            CricketOverProgress(
              overNumber: ov,
              runsInOver: r,
              cumulativeRuns: cumT1Runs,
              wicketsInOver: t1WicketsByOver[ov] ?? 0,
              cumulativeWickets: cumT1W,
              balls: ['1', '4', '•', '2', '1', 'W'],
            ),
          );
        }

        // Seed completed 20 overs for Team 2 (DEL - 165/8)
        final t2OverRuns = [6, 9, 11, 5, 8, 10, 7, 6, 8, 12, 9, 7, 10, 6, 8, 11, 9, 7, 8, 8];
        final t2WicketsByOver = {2: 1, 5: 1, 7: 1, 11: 1, 14: 1, 16: 1, 18: 1, 20: 1};
        int cumT2Runs = 0;
        int cumT2W = 0;
        for (int ov = 1; ov <= t2OverRuns.length; ov++) {
          final r = t2OverRuns[ov - 1];
          cumT2Runs += r;
          if (t2WicketsByOver.containsKey(ov)) cumT2W += t2WicketsByOver[ov]!;
          _t2OverProgress.add(
            CricketOverProgress(
              overNumber: ov,
              runsInOver: r,
              cumulativeRuns: cumT2Runs,
              wicketsInOver: t2WicketsByOver[ov] ?? 0,
              cumulativeWickets: cumT2W,
              balls: ['1', '•', '4', '1', '2', 'W'],
            ),
          );
        }

        // Seed realistic Wagon Wheel shots for demonstration
        _matchShots.addAll([
          const CricketShotResult(runs: 4, sector: 'Extra Cover', shotType: 'Cover Drive', angle: -0.7, distance: 0.94),
          const CricketShotResult(runs: 6, sector: 'Mid Wicket', shotType: 'Pull Shot', angle: 1.4, distance: 0.98),
          const CricketShotResult(runs: 4, sector: 'Point', shotType: 'Square Cut', angle: -1.8, distance: 0.92),
          const CricketShotResult(runs: 1, sector: 'Long Off', shotType: 'Straight Drive', angle: -0.2, distance: 0.65),
          const CricketShotResult(runs: 2, sector: 'Fine Leg', shotType: 'Glance to Fine Leg', angle: 2.8, distance: 0.72),
          const CricketShotResult(runs: 6, sector: 'Long On', shotType: 'Lofted Maximum', angle: 0.35, distance: 0.96),
          const CricketShotResult(runs: 4, sector: 'Third Man', shotType: 'Delicate Late Cut', angle: -2.3, distance: 0.91),
          const CricketShotResult(runs: 0, sector: 'Cover / Point', shotType: 'Defended softly', angle: -1.2, distance: 0.35),
        ]);

        _innings1.fallOfWickets.addAll([
          '1-34 (Shubman Gill, 3.4 ov)',
          '2-78 (Virat Kohli, 8.5 ov)',
          '3-142 (Suryakumar Yadav, 14.1 ov)',
        ]);

        _timelineFeed.addAll([
          MatchTimelineItem(
            timeOrOver: '18.2',
            title: 'SINGLE RUN',
            description: '${_currentBowler.name} pushes full on middle, ${_striker.name} works it softly through mid-wicket for a sharp single.',
            badgeText: '1',
            badgeColor: const Color(0xFFF1F5F9),
            badgeTextColor: AppColors.textPrimary,
            teamShort: _match.team1Short,
          ),
          MatchTimelineItem(
            timeOrOver: '18.1',
            title: 'FOUR RUNS',
            description: 'CRACKING SHOT! ${_striker.name} stands tall and laces a cover drive right through the inner ring to the fence.',
            badgeText: '4',
            badgeColor: const Color(0xFF059669),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
          MatchTimelineItem(
            timeOrOver: '17.6',
            title: 'WICKET! OUT',
            description: 'CAUGHT BEHIND! Sliced outside off-stump, thick edge comfortably held by keeper. Big breakthrough!',
            badgeText: 'W',
            badgeColor: const Color(0xFFEF4444),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
          MatchTimelineItem(
            timeOrOver: '17.5',
            title: 'MAXIMUM SIX',
            description: 'MONSTROUS HIT! Picked off the hips and deposited onto the second tier over deep backward square leg.',
            badgeText: '6',
            badgeColor: const Color(0xFF059669),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
        ]);
      } else {
        // Fresh match (starts clean at 0 runs, 0 wickets, 0 balls)
        _cricketRuns = 0;
        _cricketWickets = 0;
        _cricketBalls = 0;
        _strikerRuns = 0;
        _strikerBalls = 0;
        _nonStrikerRuns = 0;
        _nonStrikerBalls = 0;
        _bowlerRuns = 0;
        _bowlerBalls = 0;
        _bowlerWickets = 0;
        _t1OverProgress.add(const CricketOverProgress(overNumber: 1, runsInOver: 0, cumulativeRuns: 0));

        for (final p in _firstInningsBattingSquad) {
          _innings1.battingRecords[p.id] = CricketBattingRecord(
            player: p,
            runs: 0,
            balls: 0,
            fours: 0,
            sixes: 0,
            isOut: false,
            dismissal: (p.id == _striker.id || p.id == _nonStriker.id) ? 'not out *' : 'yet to bat',
          );
        }
        for (final p in _firstInningsBowlingSquad) {
          _innings1.bowlingRecords[p.id] = CricketBowlingRecord(
            player: p,
            balls: 0,
            runs: 0,
            wickets: 0,
            maidens: 0,
          );
        }

        _innings1.runs = 0;
        _innings1.wickets = 0;
        _innings1.balls = 0;

        final tossDesc = _match.tossWinner.isNotEmpty
            ? '${_match.tossWinner} won the toss and ${_match.tossDecision.toLowerCase().contains("elected") ? _match.tossDecision : "elected to ${_match.tossDecision}"}.'
            : 'Match initiated.';
        _timelineFeed.add(
          MatchTimelineItem(
            timeOrOver: '0.0',
            title: 'MATCH COMMENCED',
            description: '$tossDesc ${_striker.name} and ${_nonStriker.name} open the batting for $_firstInningsBattingTeamName. ${_currentBowler.name} to bowl the first over.',
            badgeText: 'START',
            badgeColor: const Color(0xFF059669),
            badgeTextColor: Colors.white,
            teamShort: _firstInningsBattingTeamShort,
          ),
        );
      }
    } else if (_match.sport == SportType.football) {
      if (isDemoMatch) {
        _footballScoreTeam1 = 2;
        _footballScoreTeam2 = 1;
        _footballMinutes = 67;
        _startFootballClock();
        _timelineFeed.addAll([
          MatchTimelineItem(
            timeOrOver: '58\'',
            title: 'GOAL! BENGALURU FC',
            description: 'Amit P. converts a delightful cross into the bottom right corner with a clinical header.',
            badgeText: '⚽',
            badgeColor: const Color(0xFF1E6E16),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
          MatchTimelineItem(
            timeOrOver: '41\'',
            title: 'GOAL! CHENNAI STRIKERS',
            description: 'Kiran M. executes a stunning curled shot past the diving goalkeeper into the top bin.',
            badgeText: '⚽',
            badgeColor: const Color(0xFF1E6E16),
            badgeTextColor: Colors.white,
            teamShort: _match.team2Short,
          ),
          MatchTimelineItem(
            timeOrOver: '23\'',
            title: 'GOAL! BENGALURU FC',
            description: 'Suresh R. pounces on a defensive rebound to slot home the opening goal.',
            badgeText: '⚽',
            badgeColor: const Color(0xFF1E6E16),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
        ]);
      } else {
        final sd = _match.scoreData is Map ? _match.scoreData as Map : null;
        if (sd != null && sd['team1_score'] != null) {
          _footballScoreTeam1 = int.tryParse(sd['team1_score'].toString()) ?? 0;
          _footballScoreTeam2 = int.tryParse(sd['team2_score'].toString()) ?? 0;
          _footballMinutes = (sd['minute'] as num?)?.toInt() ?? 1;
          if (sd['timeline'] is List) {
            _timelineFeed.clear();
            for (final item in (sd['timeline'] as List)) {
              if (item is Map) _timelineFeed.add(MatchTimelineItem.fromMap(Map<String, dynamic>.from(item)));
            }
          }
          if (sd['football_events'] is List) {
            _footballEvents.clear();
            for (final ev in (sd['football_events'] as List)) {
              if (ev is Map) _footballEvents.add(Map<String, dynamic>.from(ev));
            }
          }
        } else {
          _footballScoreTeam1 = 0;
          _footballScoreTeam2 = 0;
          _footballMinutes = 1;
          _timelineFeed.add(
            MatchTimelineItem(
              timeOrOver: '1\'',
              title: 'KICK-OFF',
              description: 'Match kicked off between ${_match.team1Name} and ${_match.team2Name}.',
              badgeText: 'START',
              badgeColor: const Color(0xFF1E6E16),
              badgeTextColor: Colors.white,
              teamShort: _match.team1Short,
            ),
          );
        }
        if (_match.status != MatchStatus.completed) {
          _startFootballClock();
        }
      }
    } else if (_match.sport == SportType.basketball) {
      if (isDemoMatch) {
        _basketballScoreTeam1 = 68;
        _basketballScoreTeam2 = 72;
        _basketballQuarter = 3;
        _startBasketballClock();
        _timelineFeed.addAll([
          MatchTimelineItem(
            timeOrOver: 'Q3 4:23',
            title: '3-POINTER SPLASH',
            description: 'Stephen Curry hits a signature step-back triple from way downtown.',
            badgeText: '+3',
            badgeColor: const Color(0xFFEA580C),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
          MatchTimelineItem(
            timeOrOver: 'Q3 5:10',
            title: 'POWER DUNK',
            description: 'Giannis Antetokounmpo storms the lane and throws down a thunderous two-handed slam.',
            badgeText: '+2',
            badgeColor: AppColors.textPrimary,
            badgeTextColor: Colors.white,
            teamShort: _match.team2Short,
          ),
        ]);
      } else {
        _basketballScoreTeam1 = 0;
        _basketballScoreTeam2 = 0;
        _basketballQuarter = 1;
        _basketballSeconds = 600;
        _startBasketballClock();
        _timelineFeed.add(
          MatchTimelineItem(
            timeOrOver: 'Q1 10:00',
            title: 'TIP-OFF',
            description: 'First quarter commenced between ${_match.team1Name} and ${_match.team2Name}.',
            badgeText: 'START',
            badgeColor: const Color(0xFFEA580C),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
        );
      }
    } else if (_match.sport == SportType.tennis) {
      _isTableTennisMode = _match.format.toLowerCase().contains('table tennis') || _match.format.toLowerCase().contains('tt');
      if (isDemoMatch) {
        _tennisSetsTeam1 = 1;
        _tennisSetsTeam2 = 1;
        _tennisGamesTeam1 = 4;
        _tennisGamesTeam2 = 3;

        // Seed realistic Table Tennis data
        _ttGamesTeam1 = 2;
        _ttGamesTeam2 = 1;
        _ttPointsTeam1 = 9;
        _ttPointsTeam2 = 7;
        _ttCompletedGames.addAll([
          {'p1': 11, 'p2': 9},
          {'p1': 8, 'p2': 11},
          {'p1': 11, 'p2': 7},
        ]);
        _timelineFeed.addAll([
          MatchTimelineItem(
            timeOrOver: 'Set 3 G7',
            title: 'GAME HELD',
            description: 'Unreturned 128 mph first serve seals the service game to love.',
            badgeText: 'GAME',
            badgeColor: const Color(0xFF65A30D),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
        ]);
      } else {
        _tennisSetsTeam1 = 0;
        _tennisSetsTeam2 = 0;
        _tennisGamesTeam1 = 0;
        _tennisGamesTeam2 = 0;
        _timelineFeed.add(
          MatchTimelineItem(
            timeOrOver: 'Set 1',
            title: 'MATCH COMMENCED',
            description: 'Set 1 underway between ${_match.team1Name} and ${_match.team2Name}.',
            badgeText: 'START',
            badgeColor: const Color(0xFF65A30D),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _footballTimer?.cancel();
    _basketballTimer?.cancel();
    super.dispose();
  }

  void _startFootballClock() {
    _footballTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (_footballTimerRunning && mounted) {
        setState(() {
          if (_footballMinutes < 90) {
            _footballMinutes++;
            if (_footballMinutes == 45) {
              _footballPeriod = 'Half Time';
              _footballTimerRunning = false;
            }
          }
        });
      }
    });
  }

  void _startBasketballClock() {
    _basketballTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_basketballTimerRunning && mounted) {
        setState(() {
          if (_basketballSeconds > 0) {
            _basketballSeconds--;
          } else {
            if (_basketballQuarter < 4) {
              _basketballQuarter++;
              _basketballSeconds = 600;
            } else {
              _basketballTimerRunning = false;
            }
          }
        });
      }
    });
  }

  void _pushHistorySnapshot(dynamic data) {
    _history.add(data);
    if (_history.length > 30) _history.removeAt(0);
  }

  Color _getSportColor() {
    switch (_match.sport) {
      case SportType.cricket:
        return const Color(0xFF059669);
      case SportType.football:
        return const Color(0xFF1E6E16);
      case SportType.basketball:
        return const Color(0xFFEA580C);
      case SportType.tennis:
        return const Color(0xFF65A30D);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCORING MUTATIONS (CREATOR ONLY)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleCricketRunTapped(int runs, {bool isBoundary = false}) async {
    if (!isCreator || _isCricketInningsOver) return;

    if (_cricketBalls >= _maxOvers * 6 && !_isTestCricket) {
      _checkCricketInningsOrMatchEnd();
      return;
    }

    // Stumps & CricHeroes interactive cricket field shot selector
    final shotResult = await CricketFieldSelectorSheet.show(
      context: context,
      runs: runs,
      isBoundary: isBoundary,
      batsmanName: _striker.name,
      batsmanJersey: _striker.jerseyNumber,
      initialIsRightHand: true,
    );

    if (shotResult != null) {
      _addCricketRun(
        shotResult.runs,
        isBoundary: shotResult.isBoundary,
        shotDirection: shotResult.sector,
        shotType: shotResult.shotType,
        angle: shotResult.angle,
        distance: shotResult.distance,
      );
    }
  }

  void _addCricketRun(
    int runs, {
    bool isBoundary = false,
    String? shotDirection,
    String? shotType,
    double? angle,
    double? distance,
  }) {
    if (!isCreator || _isCricketInningsOver) return;

    if (_cricketBalls >= _maxOvers * 6 && !_isTestCricket) {
      _checkCricketInningsOrMatchEnd();
      return;
    }

    _pushHistorySnapshot({
      'runs': _cricketRuns,
      'wickets': _cricketWickets,
      'balls': _cricketBalls,
      'strikerRuns': _strikerRuns,
      'strikerBalls': _strikerBalls,
      'nonStrikerRuns': _nonStrikerRuns,
      'nonStrikerBalls': _nonStrikerBalls,
      'bowlerRuns': _bowlerRuns,
      'bowlerBalls': _bowlerBalls,
      'overBalls': List<String>.from(_currentOverBalls),
      'striker': _striker,
      'nonStriker': _nonStriker,
      'isCricketInningsOver': _isCricketInningsOver,
    });

    setState(() {
      _cricketRuns += runs;
      _cricketBalls++;
      _strikerRuns += runs;
      _strikerBalls++;
      _bowlerRuns += runs;
      _bowlerBalls++;

      // Track boundaries and dots for analytics graphs
      if (runs == 4) {
        if (_cricketInnings == 1) _team1TotalFours++; else _team2TotalFours++;
      } else if (runs == 6) {
        if (_cricketInnings == 1) _team1TotalSixes++; else _team2TotalSixes++;
      } else if (runs == 0) {
        if (_cricketInnings == 1) _team1DotBalls++; else _team2DotBalls++;
      }

      // Record shot into Wagon Wheel
      if (shotDirection != null) {
        _matchShots.add(
          CricketShotResult(
            runs: runs,
            sector: shotDirection,
            shotType: shotType ?? (runs == 4 ? 'Boundary Four' : (runs == 6 ? 'Maximum Six' : '$runs Runs')),
            angle: angle ?? 0.0,
            distance: distance ?? 0.7,
            isBoundary: isBoundary || runs == 4 || runs == 6,
          ),
        );
      }

      // Update active over progression for Worm & Manhattan charts
      final activeList = _cricketInnings == 1 ? _t1OverProgress : _t2OverProgress;
      final currentOverNum = ((_cricketBalls - 1) ~/ 6) + 1;
      final overIdx = activeList.indexWhere((o) => o.overNumber == currentOverNum);
      if (overIdx >= 0) {
        final existing = activeList[overIdx];
        activeList[overIdx] = CricketOverProgress(
          overNumber: currentOverNum,
          runsInOver: existing.runsInOver + runs,
          cumulativeRuns: _cricketRuns,
          wicketsInOver: existing.wicketsInOver,
          cumulativeWickets: _cricketWickets,
          balls: [...existing.balls, runs == 0 ? '•' : '$runs'],
          wicketBatsmen: existing.wicketBatsmen,
        );
      } else {
        activeList.add(
          CricketOverProgress(
            overNumber: currentOverNum,
            runsInOver: runs,
            cumulativeRuns: _cricketRuns,
            wicketsInOver: 0,
            cumulativeWickets: _cricketWickets,
            balls: [runs == 0 ? '•' : '$runs'],
            wicketBatsmen: const [],
          ),
        );
      }

      // Keep innings data in sync
      _currentInningsData.runs = _cricketRuns;
      _currentInningsData.balls = _cricketBalls;

      _currentOverBalls.add(runs == 0 ? '•' : '$runs');

      // Update detailed batting record
      final bRecord = _battingRecords[_striker.id];
      if (bRecord != null) {
        bRecord.runs += runs;
        bRecord.balls++;
        if (runs == 4) bRecord.fours++;
        if (runs == 6) bRecord.sixes++;
      }

      // Update detailed bowling record
      final blRecord = _bowlingRecords[_currentBowler.id];
      if (blRecord != null) {
        blRecord.runs += runs;
        blRecord.balls++;
      }

      final overStr = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
      String desc;
      if (runs == 4) {
        desc = shotDirection != null
            ? '${_currentBowler.name} to ${_striker.name}, FOUR! Driven with majestic timing through $shotDirection. ($shotType)'
            : '${_currentBowler.name} to ${_striker.name}, FOUR! Driven with sublime timing through covers.';
      } else if (runs == 6) {
        desc = shotDirection != null
            ? '${_currentBowler.name} to ${_striker.name}, MAXIMUM SIX! Smoked high and mighty over $shotDirection into the stands! ($shotType)'
            : '${_currentBowler.name} to ${_striker.name}, SIX! Smoked high and long into the stands!';
      } else if (runs == 0) {
        desc = shotDirection != null
            ? '${_currentBowler.name} to ${_striker.name}, no run, solidly $shotType towards $shotDirection.'
            : '${_currentBowler.name} to ${_striker.name}, no run, defended solidly towards mid-off.';
      } else {
        desc = shotDirection != null
            ? '${_currentBowler.name} to ${_striker.name}, $runs run${runs > 1 ? 's' : ''}, pushed into the gap towards $shotDirection.'
            : '${_currentBowler.name} to ${_striker.name}, $runs run${runs > 1 ? 's' : ''}, pushed into the outfield.';
      }

      _timelineFeed.insert(
        0,
        MatchTimelineItem(
          timeOrOver: overStr,
          title: runs == 4 ? 'BOUNDARY FOUR' : (runs == 6 ? 'MAXIMUM SIX' : '$runs RUN${runs == 1 ? '' : 'S'}'),
          description: desc,
          badgeText: runs == 0 ? '•' : '$runs',
          badgeColor: runs == 4 || runs == 6 ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
          badgeTextColor: runs == 4 || runs == 6 ? Colors.white : AppColors.textPrimary,
          teamShort: _currentBattingTeamShort,
        ),
      );

      // Strike rotation on odd runs
      if (runs % 2 != 0) {
        _swapStrike();
      }

      // Check Over Complete (6 legal balls)
      if (_cricketBalls % 6 == 0) {
        _onOverComplete();
      }

      _syncCricketToAppState();

      _checkCricketInningsOrMatchEnd();
    });
  }

  void _addCricketExtra(String type, int runs) {
    if (!isCreator || _isCricketInningsOver) return;

    _pushHistorySnapshot({
      'runs': _cricketRuns,
      'wickets': _cricketWickets,
      'balls': _cricketBalls,
      'bowlerRuns': _bowlerRuns,
      'overBalls': List<String>.from(_currentOverBalls),
      'isCricketInningsOver': _isCricketInningsOver,
    });

    setState(() {
      _cricketRuns += runs;
      _bowlerRuns += runs;
      _currentOverBalls.add(type);

      _currentInningsData.runs = _cricketRuns;
      if (type == 'WD') {
        _currentInningsData.extrasWides += runs;
      } else if (type == 'NB') {
        _currentInningsData.extrasNoBalls += runs;
      } else if (type == 'B') {
        _currentInningsData.extrasByes += runs;
      } else if (type == 'LB') {
        _currentInningsData.extrasLegByes += runs;
      }

      final blRecord = _bowlingRecords[_currentBowler.id];
      if (blRecord != null) {
        blRecord.runs += runs;
      }

      if (type != 'WD' && type != 'NB') {
        _cricketBalls++;
        _currentInningsData.balls = _cricketBalls;
        if (_cricketBalls % 6 == 0) _onOverComplete();
      }

      final overStr = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
      _timelineFeed.insert(
        0,
        MatchTimelineItem(
          timeOrOver: overStr,
          title: 'EXTRA ($type)',
          description: '${_currentBowler.name} strays in line, umpire signals $type. $runs penalty run added.',
          badgeText: type,
          badgeColor: const Color(0xFFFEF3C7),
          badgeTextColor: const Color(0xFFD97706),
          teamShort: _currentBattingTeamShort,
        ),
      );

      _syncCricketToAppState();

      _checkCricketInningsOrMatchEnd();
    });
  }

  void _showOpenersSelectionSheet({bool isSecondInnings = false}) {
    if (!isCreator) return;

    final battingSquad = isSecondInnings ? _secondInningsBattingSquad : _firstInningsBattingSquad;
    final bowlingSquad = isSecondInnings ? _secondInningsBowlingSquad : _firstInningsBowlingSquad;
    final battingTeamName = isSecondInnings ? _secondInningsBattingTeamName : _firstInningsBattingTeamName;
    final bowlingTeamShort = isSecondInnings ? _secondInningsBowlingTeamShort : _firstInningsBowlingTeamShort;

    if (battingSquad.isEmpty || bowlingSquad.isEmpty) return;

    MatchPlayer selectedStriker = _striker;
    if (!battingSquad.any((p) => p.id == selectedStriker.id)) {
      selectedStriker = battingSquad[0];
    }

    MatchPlayer selectedNonStriker = _nonStriker;
    if (!battingSquad.any((p) => p.id == selectedNonStriker.id) || selectedNonStriker.id == selectedStriker.id) {
      selectedNonStriker = battingSquad.firstWhere((p) => p.id != selectedStriker.id, orElse: () => battingSquad[0]);
    }

    MatchPlayer selectedBowler = _currentBowler;
    if (!bowlingSquad.any((p) => p.id == selectedBowler.id)) {
      selectedBowler = bowlingSquad.last;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.sports_cricket, color: Color(0xFF059669), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSecondInnings ? 'Select 2nd Innings Openers' : 'Select Opening Batters & Bowler',
                                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              Text(
                                'Choose initial strikers for $battingTeamName',
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('OPENING STRIKER (Facing 1st Ball)', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedStriker.id,
                          isExpanded: true,
                          items: battingSquad.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text('#${p.jerseyNumber} ${p.name} (${p.role})', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setSheetState(() {
                              selectedStriker = battingSquad.firstWhere((p) => p.id == val);
                              if (selectedNonStriker.id == selectedStriker.id) {
                                selectedNonStriker = battingSquad.firstWhere((p) => p.id != val, orElse: () => battingSquad[0]);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('NON-STRIKER', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedNonStriker.id,
                          isExpanded: true,
                          items: battingSquad.where((p) => p.id != selectedStriker.id).map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text('#${p.jerseyNumber} ${p.name} (${p.role})', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setSheetState(() {
                              selectedNonStriker = battingSquad.firstWhere((p) => p.id == val);
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('OPENING BOWLER ($bowlingTeamShort)', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBowler.id,
                          isExpanded: true,
                          items: bowlingSquad.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text('#${p.jerseyNumber} ${p.name} (${p.role})', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setSheetState(() {
                              selectedBowler = bowlingSquad.firstWhere((p) => p.id == val);
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _striker = selectedStriker;
                            _nonStriker = selectedNonStriker;
                            _currentBowler = selectedBowler;
                            _hasPromptedOpeners = true;

                            final activeInn = isSecondInnings ? _innings2 : _innings1;
                            for (final p in battingSquad) {
                              final isOpening = p.id == _striker.id || p.id == _nonStriker.id;
                              if (activeInn.battingRecords.containsKey(p.id)) {
                                activeInn.battingRecords[p.id]!.dismissal = isOpening ? 'not out *' : 'yet to bat';
                                activeInn.battingRecords[p.id]!.isOut = false;
                              } else {
                                activeInn.battingRecords[p.id] = CricketBattingRecord(
                                  player: p,
                                  dismissal: isOpening ? 'not out *' : 'yet to bat',
                                );
                              }
                            }
                            _strikerRuns = 0;
                            _strikerBalls = 0;
                            _nonStrikerRuns = 0;
                            _nonStrikerBalls = 0;
                            _bowlerRuns = 0;
                            _bowlerBalls = 0;
                            _bowlerWickets = 0;
                          });
                          _syncCricketToAppState();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Confirm Openers & Start', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOverEndBowlerSelectDialog(int nextOverNum) {
    if (!isCreator || _isCricketInningsOver) return;

    final bowlingSquad = _currentBowlingSquad;
    if (bowlingSquad.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sports_cricket_rounded, color: Color(0xFF1D4ED8), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Over ${nextOverNum - 1} Complete • Select Next Bowler',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Previous bowler cannot bowl consecutive overs (MCC Law 17)',
                          style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: bowlingSquad.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = bowlingSquad[i];
                    final isRestricted = bowlingSquad.length > 1 && p.id == _lastOverBowlerId;
                    final existingRec = _bowlingRecords[p.id];
                    final statsStr = existingRec != null && existingRec.balls > 0
                        ? '${existingRec.wickets}/${existingRec.runs} (${existingRec.oversStr} ov)'
                        : 'Yet to bowl';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      enabled: !isRestricted,
                      leading: CircleAvatar(
                        backgroundColor: isRestricted ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
                        child: Text(
                          '#${p.jerseyNumber}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: isRestricted ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: isRestricted ? AppColors.textMuted : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        isRestricted ? 'Cannot bowl consecutive overs' : '${p.role} • $statsStr',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          color: isRestricted ? const Color(0xFFEF4444) : AppColors.textSecondary,
                          fontWeight: isRestricted ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isRestricted
                          ? const Icon(Icons.block_rounded, size: 20, color: Color(0xFFEF4444))
                          : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                      onTap: isRestricted
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              setState(() {
                                _currentBowler = p;
                                final rec = _bowlingRecords[p.id];
                                _bowlerRuns = rec?.runs ?? 0;
                                _bowlerBalls = rec?.balls ?? 0;
                                _bowlerWickets = rec?.wickets ?? 0;
                              });
                              _syncCricketToAppState();
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangeBowlerDialog() {
    if (!isCreator) return;

    final bowlingSquad = _currentBowlingSquad;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Bowler ($_currentBowlingTeamShort)',
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              ...bowlingSquad.map((p) {
                final isCurrent = p.id == _currentBowler.id;
                final isRestricted = bowlingSquad.length > 1 && p.id == _lastOverBowlerId && (_cricketBalls % 6 == 0);
                return ListTile(
                  enabled: !isRestricted,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Text('#${p.jerseyNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary)),
                  ),
                  title: Text(p.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    isRestricted ? 'Cannot bowl consecutive overs' : p.role,
                    style: GoogleFonts.outfit(color: isRestricted ? const Color(0xFFEF4444) : AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF059669))
                      : (isRestricted ? const Icon(Icons.block_rounded, size: 18, color: Color(0xFFEF4444)) : null),
                  onTap: isRestricted
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          setState(() {
                            final oldRec = _bowlingRecords[_currentBowler.id];
                            if (oldRec != null) {
                              oldRec.runs = _bowlerRuns;
                              oldRec.balls = _bowlerBalls;
                              oldRec.wickets = _bowlerWickets;
                            }
                            _currentBowler = p;
                            final rec = _bowlingRecords[p.id];
                            _bowlerRuns = rec?.runs ?? 0;
                            _bowlerBalls = rec?.balls ?? 0;
                            _bowlerWickets = rec?.wickets ?? 0;
                          });
                          _syncCricketToAppState();
                        },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _recordCricketWicket() {
    if (!isCreator) return;

    final battingSquad = _currentBattingSquad;
    // Only show players who have not gone to field yet (not out and not yet on field)
    final availableBatsmen = battingSquad.where((p) {
      if (p.id == _striker.id || p.id == _nonStriker.id) return false;
      final rec = _battingRecords[p.id];
      if (rec != null) {
        if (rec.isOut) return false;
        if (rec.dismissal != 'yet to bat') return false;
      }
      return true;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wicket Dismissal (${_striker.name})',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (availableBatsmen.isEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'No more batters remaining in squad. This will conclude the innings (All Out).',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Bowled', 'Caught', 'LBW', 'Run Out', 'Stumped'].map((mode) {
                  return ActionChip(
                    label: Text(mode),
                    labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (availableBatsmen.isNotEmpty) {
                        _showNextBatsmanDialog(mode, availableBatsmen);
                      } else {
                        // All remaining batters out -> Conclude innings as All Out!
                        _confirmDismissal(mode, null);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNextBatsmanDialog(String mode, List<MatchPlayer> availableBatsmen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Next Batter', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...availableBatsmen.map((p) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text('#${p.jerseyNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary)),
                    ),
                    title: Text(p.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                    subtitle: Text(p.role, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDismissal(mode, p);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _confirmDismissal(String mode, MatchPlayer? nextBatsman) {
    if (!isCreator || _isCricketInningsOver) return;

    _pushHistorySnapshot({
      'runs': _cricketRuns,
      'wickets': _cricketWickets,
      'balls': _cricketBalls,
      'bowlerWickets': _bowlerWickets,
      'bowlerBalls': _bowlerBalls,
      'overBalls': List<String>.from(_currentOverBalls),
      'striker': _striker,
      'nonStriker': _nonStriker,
      'bowler': _currentBowler,
      'strikerRuns': _strikerRuns,
      'strikerBalls': _strikerBalls,
      'isCricketInningsOver': _isCricketInningsOver,
      'dismissedBatterId': _striker.id,
      'nextBatterId': nextBatsman?.id,
      'isWicket': true,
    });

    setState(() {
      _cricketWickets++;
      _cricketBalls++;
      final isBowlerWicket = mode != 'Run Out';
      if (isBowlerWicket) {
        _bowlerWickets++;
      }
      _bowlerBalls++;
      _currentOverBalls.add('W');

      _currentInningsData.wickets = _cricketWickets;
      _currentInningsData.balls = _cricketBalls;

      final bRecord = _battingRecords[_striker.id];
      if (bRecord != null) {
        bRecord.isOut = true;
        bRecord.dismissal = mode == 'Run Out' ? 'run out' : '$mode b ${_currentBowler.name}';
      }

      final blRecord = _bowlingRecords[_currentBowler.id];
      if (blRecord != null) {
        if (isBowlerWicket) blRecord.wickets++;
        blRecord.balls++;
      }

      final overStr = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
      _fallOfWickets.insert(0, '$_cricketWickets-$_cricketRuns (${_striker.name}, $overStr ov)');

      // Update over progression for Worm and Manhattan charts
      final activeList = _cricketInnings == 1 ? _t1OverProgress : _t2OverProgress;
      final currentOverNum = ((_cricketBalls - 1) ~/ 6) + 1;
      final overIdx = activeList.indexWhere((o) => o.overNumber == currentOverNum);
      if (overIdx >= 0) {
        final existing = activeList[overIdx];
        activeList[overIdx] = CricketOverProgress(
          overNumber: currentOverNum,
          runsInOver: existing.runsInOver,
          cumulativeRuns: _cricketRuns,
          wicketsInOver: existing.wicketsInOver + 1,
          cumulativeWickets: _cricketWickets,
          balls: [...existing.balls, 'W'],
          wicketBatsmen: [...existing.wicketBatsmen, _striker.name],
        );
      } else {
        activeList.add(
          CricketOverProgress(
            overNumber: currentOverNum,
            runsInOver: 0,
            cumulativeRuns: _cricketRuns,
            wicketsInOver: 1,
            cumulativeWickets: _cricketWickets,
            balls: const ['W'],
            wicketBatsmen: [_striker.name],
          ),
        );
      }

      _timelineFeed.insert(
        0,
        MatchTimelineItem(
          timeOrOver: overStr,
          title: 'WICKET DISMISSAL',
          description: 'OUT! ${_striker.name} $mode b ${_currentBowler.name}. Stupendous bowling under pressure!',
          badgeText: 'W',
          badgeColor: const Color(0xFFEF4444),
          badgeTextColor: Colors.white,
          teamShort: _currentBattingTeamShort,
        ),
      );

      if (nextBatsman != null) {
        _striker = nextBatsman;
        _strikerRuns = 0;
        _strikerBalls = 0;
        final nextRecord = _battingRecords[nextBatsman.id];
        if (nextRecord != null) {
          nextRecord.dismissal = 'not out *';
        }
      }

      if (_cricketBalls % 6 == 0 && nextBatsman != null) {
        _onOverComplete();
      }
      _syncCricketToAppState();

      _checkCricketInningsOrMatchEnd(isForcedAllOut: nextBatsman == null);
    });
  }

  void _checkCricketInningsOrMatchEnd({bool isForcedAllOut = false}) {
    if (_match.sport != SportType.cricket) return;

    if (_cricketInnings == 1) {
      final maxBalls = _maxOvers * 6;
      final isOversUp = !_isTestCricket && _cricketBalls >= maxBalls;
      final isAllOut = isForcedAllOut || _cricketWickets >= _maxWickets;

      if (isOversUp || isAllOut) {
        _isCricketInningsOver = true;
        _innings1.isCompleted = true;
        _innings1.completionReason = isAllOut ? 'All Out' : 'Overs Completed ($_maxOvers ov)';
        _innings1.runs = _cricketRuns;
        _innings1.wickets = _cricketWickets;
        _innings1.balls = _cricketBalls;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showEndInningsDialog(isAuto: true);
        });
      }
    } else if (_cricketInnings == 2) {
      final maxBalls = _maxOvers * 6;
      final isTargetReached = _cricketRuns >= _targetRuns;
      final isOversUp = !_isTestCricket && _cricketBalls >= maxBalls;
      final isAllOut = isForcedAllOut || _cricketWickets >= _maxWickets;

      if (isTargetReached || isOversUp || isAllOut) {
        _isCricketInningsOver = true;
        _innings2.isCompleted = true;
        _innings2.completionReason = isTargetReached
            ? 'Target Chased'
            : (isAllOut ? 'All Out' : 'Overs Completed');
        _innings2.runs = _cricketRuns;
        _innings2.wickets = _cricketWickets;
        _innings2.balls = _cricketBalls;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _completeMatch();
        });
      }
    }
  }

  void _swapStrike() {
    final temp = _striker;
    _striker = _nonStriker;
    _nonStriker = temp;

    final tempRuns = _strikerRuns;
    final tempBalls = _strikerBalls;
    _strikerRuns = _nonStrikerRuns;
    _strikerBalls = _nonStrikerBalls;
    _nonStrikerRuns = tempRuns;
    _nonStrikerBalls = tempBalls;
  }

  void _onOverComplete() {
    _currentOverBalls = [];
    _swapStrike();

    // Save previous bowler figures to bowling records
    final prevRec = _bowlingRecords[_currentBowler.id];
    if (prevRec != null) {
      prevRec.runs = _bowlerRuns;
      prevRec.balls = _bowlerBalls;
      prevRec.wickets = _bowlerWickets;
    }
    _lastOverBowlerId = _currentBowler.id;

    // Initialize next over slot in progression list
    final activeList = _cricketInnings == 1 ? _t1OverProgress : _t2OverProgress;
    final nextOverNum = (_cricketBalls ~/ 6) + 1;
    if (nextOverNum <= _maxOvers && !activeList.any((o) => o.overNumber == nextOverNum)) {
      activeList.add(
        CricketOverProgress(
          overNumber: nextOverNum,
          runsInOver: 0,
          cumulativeRuns: _cricketRuns,
          wicketsInOver: 0,
          cumulativeWickets: _cricketWickets,
        ),
      );
    }

    final maxBalls = _maxOvers * 6;
    final isOversUp = !_isTestCricket && _cricketBalls >= maxBalls;
    final isAllOut = _cricketWickets >= _maxWickets;
    final isTargetReached = _cricketInnings == 2 && _cricketRuns >= _targetRuns;

    if (!isOversUp && !isAllOut && !isTargetReached && !_isCricketInningsOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showOverEndBowlerSelectDialog(nextOverNum);
      });
    }
  }

  void _showEndInningsDialog({bool isAuto = false}) {
    if (!isCreator) return;

    final overStr = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.sports_cricket_rounded, color: Color(0xFF059669), size: 24),
            const SizedBox(width: 8),
            Text('1st Innings Concluded', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_firstInningsBattingTeamName completed their 1st innings at $_cricketRuns/$_cricketWickets in $overStr overs ($_maxOvers ov max).',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARGET EQUATION',
                    style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_secondInningsBattingTeamName need ${_cricketRuns + 1} runs from $_maxOvers overs to win.',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E40AF)),
                  ),
                  Text(
                    'Required Run Rate: ${((_cricketRuns + 1) / _maxOvers).toStringAsFixed(2)} RPO',
                    style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _switchCricketInnings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Start 2nd Innings'),
          ),
        ],
      ),
    );
  }

  void _showDeclareInningsDialog() {
    if (!isCreator || !_isTestCricket) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Declare Innings?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Text(
          'Declare $_firstInningsBattingTeamName\'s 1st innings at $_cricketRuns/$_cricketWickets (${_cricketBalls ~/ 6}.${_cricketBalls % 6} ov)?',
          style: GoogleFonts.outfit(fontSize: 13.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _innings1.completionReason = 'Innings Declared';
              _switchCricketInnings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            child: const Text('Confirm Declaration'),
          ),
        ],
      ),
    );
  }

  void _switchCricketInnings() {
    setState(() {
      _team1FinalRuns = _cricketRuns;
      _team1FinalWickets = _cricketWickets;
      _team1FinalOvers = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
      _targetRuns = _cricketRuns + 1;

      // Finalize Innings 1
      _innings1.runs = _team1FinalRuns;
      _innings1.wickets = _team1FinalWickets;
      _innings1.balls = _cricketBalls;
      _innings1.isCompleted = true;

      // Switch to Innings 2
      _cricketInnings = 2;
      _selectedScorecardInnings = 2; // Automatically switch scorecard tab to 2nd innings!
      _isCricketInningsOver = false;

      _cricketRuns = 0;
      _cricketWickets = 0;
      _cricketBalls = 0;
      _currentOverBalls = [];
      _lastOverBowlerId = null;
      _hasPromptedOpeners = false;

      final battingSquad = _secondInningsBattingSquad;
      final bowlingSquad = _secondInningsBowlingSquad;
      _striker = battingSquad.isNotEmpty ? battingSquad[0] : const MatchPlayer(id: 'b1', name: 'Batter 1', jerseyNumber: 1);
      _nonStriker = battingSquad.length > 1 ? battingSquad[1] : const MatchPlayer(id: 'b2', name: 'Batter 2', jerseyNumber: 2);
      _currentBowler = bowlingSquad.isNotEmpty ? bowlingSquad.last : const MatchPlayer(id: 'bl1', name: 'Bowler 1', jerseyNumber: 99);
      _strikerRuns = 0;
      _strikerBalls = 0;
      _nonStrikerRuns = 0;
      _nonStrikerBalls = 0;
      _bowlerRuns = 0;
      _bowlerBalls = 0;
      _bowlerWickets = 0;

      _maxWickets = battingSquad.isNotEmpty ? math.min(10, math.max(1, battingSquad.length - 1)) : 10;

      // Ensure striker & non-striker in 2nd innings have 'not out *'
      if (_innings2.battingRecords.containsKey(_striker.id)) {
        _innings2.battingRecords[_striker.id]!.dismissal = 'not out *';
      }
      if (_innings2.battingRecords.containsKey(_nonStriker.id)) {
        _innings2.battingRecords[_nonStriker.id]!.dismissal = 'not out *';
      }

      _timelineFeed.insert(
        0,
        MatchTimelineItem(
          timeOrOver: 'INN 2',
          title: 'INNINGS BREAK CONCLUDED',
          description: '2nd innings underway. $_secondInningsBattingTeamName need $_targetRuns runs from $_maxOvers overs to win.',
          badgeText: 'TARGET',
          badgeColor: const Color(0xFF1D4ED8),
          badgeTextColor: Colors.white,
          teamShort: _secondInningsBattingTeamShort,
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && isCreator) {
          _showOpenersSelectionSheet(isSecondInnings: true);
        }
      });
    });

    _syncCricketToAppState();
  }

  void _undoLastAction() {
    if (!isCreator) return;

    if (_history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to undo.')),
      );
      return;
    }

    final prev = _history.removeLast();
    setState(() {
      if (_match.sport == SportType.cricket) {
        _cricketRuns = prev['runs'] ?? _cricketRuns;
        _cricketWickets = prev['wickets'] ?? _cricketWickets;
        _cricketBalls = prev['balls'] ?? _cricketBalls;
        if (prev['striker'] != null) _striker = prev['striker'];
        if (prev['nonStriker'] != null) _nonStriker = prev['nonStriker'];
        if (prev['bowler'] != null) _currentBowler = prev['bowler'];
        _strikerRuns = prev['strikerRuns'] ?? _strikerRuns;
        _strikerBalls = prev['strikerBalls'] ?? _strikerBalls;
        _nonStrikerRuns = prev['nonStrikerRuns'] ?? _nonStrikerRuns;
        _nonStrikerBalls = prev['nonStrikerBalls'] ?? _nonStrikerBalls;
        _bowlerRuns = prev['bowlerRuns'] ?? _bowlerRuns;
        _bowlerBalls = prev['bowlerBalls'] ?? _bowlerBalls;
        _bowlerWickets = prev['bowlerWickets'] ?? _bowlerWickets;
        _currentOverBalls = prev['overBalls'] != null ? List<String>.from(prev['overBalls']) : _currentOverBalls;
        _isCricketInningsOver = prev['isCricketInningsOver'] ?? false;
        _currentInningsData.runs = _cricketRuns;
        _currentInningsData.wickets = _cricketWickets;
        _currentInningsData.balls = _cricketBalls;

        if (prev['isWicket'] == true) {
          final dismissedId = prev['dismissedBatterId'];
          if (dismissedId != null && _battingRecords.containsKey(dismissedId)) {
            _battingRecords[dismissedId]!.isOut = false;
            _battingRecords[dismissedId]!.dismissal = 'not out *';
          }
          final nextId = prev['nextBatterId'];
          if (nextId != null && _battingRecords.containsKey(nextId)) {
            _battingRecords[nextId]!.dismissal = 'yet to bat';
          }
          final bwlRecord = _bowlingRecords[_currentBowler.id];
          if (bwlRecord != null) {
            bwlRecord.wickets = _bowlerWickets;
            bwlRecord.balls = _bowlerBalls;
          }
          if (_fallOfWickets.isNotEmpty) {
            _fallOfWickets.removeAt(0);
          }
        }
        if (_timelineFeed.isNotEmpty) _timelineFeed.removeAt(0);
        _syncCricketToAppState();
      } else if (_match.sport == SportType.football) {
        _footballScoreTeam1 = prev['t1'] ?? _footballScoreTeam1;
        _footballScoreTeam2 = prev['t2'] ?? _footballScoreTeam2;
        if (_footballEvents.isNotEmpty) _footballEvents.removeLast();
        if (_timelineFeed.isNotEmpty) _timelineFeed.removeAt(0);
      } else if (_match.sport == SportType.basketball) {
        _basketballScoreTeam1 = prev['t1'] ?? _basketballScoreTeam1;
        _basketballScoreTeam2 = prev['t2'] ?? _basketballScoreTeam2;
        if (_timelineFeed.isNotEmpty) _timelineFeed.removeAt(0);
      } else if (_match.sport == SportType.tennis) {
        _tennisPointsIndex1 = prev['pt1'] ?? _tennisPointsIndex1;
        _tennisPointsIndex2 = prev['pt2'] ?? _tennisPointsIndex2;
        _tennisGamesTeam1 = prev['g1'] ?? _tennisGamesTeam1;
        _tennisGamesTeam2 = prev['g2'] ?? _tennisGamesTeam2;
        if (_timelineFeed.isNotEmpty) _timelineFeed.removeAt(0);
      }
    });
  }

  Map<String, dynamic> _serializeCricketScoreData({String? customStatus}) {
    final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
    final scoreStr = '$_cricketRuns/$_cricketWickets';
    final data = <String, dynamic>{
      'overs_limit': _maxOvers,
      'current_innings': _cricketInnings,
      'team1_bats_first': _team1BatsFirst,
      'striker_id': _striker.id,
      'non_striker_id': _nonStriker.id,
      'bowler_id': _currentBowler.id,
      'last_over_bowler_id': _lastOverBowlerId,
      'striker_runs': _strikerRuns,
      'striker_balls': _strikerBalls,
      'non_striker_runs': _nonStrikerRuns,
      'non_striker_balls': _nonStrikerBalls,
      'bowler_runs': _bowlerRuns,
      'bowler_balls': _bowlerBalls,
      'bowler_wickets': _bowlerWickets,
      'target_runs': _targetRuns,
      'team1_final_runs': _team1FinalRuns,
      'team1_final_wickets': _team1FinalWickets,
      'team1_final_overs': _team1FinalOvers,
      'innings1': _innings1.toMap(),
      'innings2': _innings2.toMap(),
      'mvp_player': _calculatedMvpPlayer,
      'timeline': _timelineFeed.map((e) => e.toMap()).toList(),
      't1_over_progress': _t1OverProgress.map((e) => e.toMap()).toList(),
      't2_over_progress': _t2OverProgress.map((e) => e.toMap()).toList(),
      'match_shots': _matchShots.map((e) => e.toMap()).toList(),
      'team1_fours': _team1TotalFours,
      'team1_sixes': _team1TotalSixes,
      'team2_fours': _team2TotalFours,
      'team2_sixes': _team2TotalSixes,
      'team1_dot_balls': _team1DotBalls,
      'team2_dot_balls': _team2DotBalls,
      'current_over_balls': _currentOverBalls,
    };

    if (_cricketInnings == 1) {
      if (_team1BatsFirst) {
        data['team1_score'] = scoreStr;
        data['team1_overs'] = overs;
        data['team2_score'] = 'Yet to bat';
        data['team2_overs'] = '-';
      } else {
        data['team1_score'] = 'Yet to bat';
        data['team1_overs'] = '-';
        data['team2_score'] = scoreStr;
        data['team2_overs'] = overs;
      }
      data['status_text'] = customStatus ?? '$_firstInningsBattingTeamShort: $scoreStr ($overs ov)';
    } else {
      final needed = _targetRuns - _cricketRuns;
      final status = needed <= 0
          ? '$_secondInningsBattingTeamShort won by ${math.max(1, _maxWickets - _cricketWickets)} wickets'
          : '$_secondInningsBattingTeamShort need $needed runs ($overs ov)';
      if (_team1BatsFirst) {
        data['team1_score'] = '$_team1FinalRuns/$_team1FinalWickets ($_team1FinalOvers ov)';
        data['team2_score'] = scoreStr;
        data['team2_overs'] = overs;
      } else {
        data['team1_score'] = scoreStr;
        data['team1_overs'] = overs;
        data['team2_score'] = '$_team1FinalRuns/$_team1FinalWickets ($_team1FinalOvers ov)';
      }
      data['status_text'] = customStatus ?? status;
    }
    return data;
  }

  void _syncCricketToAppState() {
    final sd = _serializeCricketScoreData();
    context.read<AppState>().updateMatchScore(_match.id, sd);
  }

  // Football Mutations
  void _addFootballGoal(int team) {
    if (!isCreator) return;

    final squad = team == 1 ? _match.team1Players : _match.team2Players;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal Scored by Team ${team == 1 ? _match.team1Short : _match.team2Short}',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text('Select Goalscorer:', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: squad.map((p) {
                  return ActionChip(
                    label: Text('${p.name} (#${p.jerseyNumber})'),
                    labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pushHistorySnapshot({'t1': _footballScoreTeam1, 't2': _footballScoreTeam2});
                      setState(() {
                        if (team == 1) {
                          _footballScoreTeam1++;
                        } else {
                          _footballScoreTeam2++;
                        }
                        _footballEvents.insert(0, {
                          'minute': _footballMinutes,
                          'team': team,
                          'type': 'goal',
                          'player': p.name,
                        });
                        _timelineFeed.insert(
                          0,
                          MatchTimelineItem(
                            timeOrOver: '$_footballMinutes\'',
                            title: 'GOAL SCORED!',
                            description: '${p.name} puts the ball past the keeper to score for ${team == 1 ? _match.team1Short : _match.team2Short}.',
                            badgeText: '⚽',
                            badgeColor: const Color(0xFF1E6E16),
                            badgeTextColor: Colors.white,
                            teamShort: team == 1 ? _match.team1Short : _match.team2Short,
                          ),
                        );
                      });
                      context.read<AppState>().updateMatchScore(_match.id, {
                        'team1_score': _footballScoreTeam1,
                        'team2_score': _footballScoreTeam2,
                        'minute': _footballMinutes,
                        'status_text': '$_footballMinutes\' - $_footballPeriod ($_footballScoreTeam1 - $_footballScoreTeam2)',
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addFootballCard(int team, String cardType) {
    if (!isCreator) return;

    final squad = team == 1 ? _match.team1Players : _match.team2Players;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$cardType Card (Team ${team == 1 ? _match.team1Short : _match.team2Short})',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: squad.map((p) {
                  return ActionChip(
                    label: Text(p.name),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _footballEvents.insert(0, {
                          'minute': _footballMinutes,
                          'team': team,
                          'type': cardType.toLowerCase(),
                          'player': p.name,
                        });
                        _timelineFeed.insert(
                          0,
                          MatchTimelineItem(
                            timeOrOver: '$_footballMinutes\'',
                            title: '$cardType CARD',
                            description: 'Referee brandishes $cardType card to ${p.name} for an illegal challenge.',
                            badgeText: cardType == 'Yellow' ? '🟨' : '🟥',
                            badgeColor: cardType == 'Yellow' ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
                            badgeTextColor: Colors.white,
                            teamShort: team == 1 ? _match.team1Short : _match.team2Short,
                          ),
                        );
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Basketball Mutations
  void _addBasketballPoints(int team, int pts) {
    if (!isCreator) return;

    _pushHistorySnapshot({'t1': _basketballScoreTeam1, 't2': _basketballScoreTeam2});
    setState(() {
      if (team == 1) {
        _basketballScoreTeam1 += pts;
      } else {
        _basketballScoreTeam2 += pts;
      }
      _timelineFeed.insert(
        0,
        MatchTimelineItem(
          timeOrOver: 'Q$_basketballQuarter ${_basketballSeconds ~/ 60}:${(_basketballSeconds % 60).toString().padLeft(2, '0')}',
          title: '+$pts POINTS (${team == 1 ? _match.team1Short : _match.team2Short})',
          description: 'Bucket converted from the floor for ${team == 1 ? _match.team1Name : _match.team2Name}.',
          badgeText: '+$pts',
          badgeColor: const Color(0xFFEA580C),
          badgeTextColor: Colors.white,
          teamShort: team == 1 ? _match.team1Short : _match.team2Short,
        ),
      );
    });

    context.read<AppState>().updateMatchScore(_match.id, {
      'team1_score': _basketballScoreTeam1,
      'team2_score': _basketballScoreTeam2,
      'quarter': _basketballQuarter,
      'status_text': 'Q$_basketballQuarter • $_basketballScoreTeam1 - $_basketballScoreTeam2',
    });
  }

  // Tennis Mutations
  final List<String> _tennisPointLabels = ['0', '15', '30', '40', 'AD'];

  void _addTennisPoint(int team) {
    if (!isCreator) return;

    _pushHistorySnapshot({
      'pt1': _tennisPointsIndex1,
      'pt2': _tennisPointsIndex2,
      'g1': _tennisGamesTeam1,
      'g2': _tennisGamesTeam2,
    });

    setState(() {
      if (team == 1) {
        if (_tennisPointsIndex1 == 3 && _tennisPointsIndex2 < 3) {
          _winTennisGame(1);
        } else if (_tennisPointsIndex1 == 3 && _tennisPointsIndex2 == 3) {
          _tennisPointsIndex1 = 4;
        } else if (_tennisPointsIndex1 == 3 && _tennisPointsIndex2 == 4) {
          _tennisPointsIndex2 = 3;
        } else if (_tennisPointsIndex1 == 4) {
          _winTennisGame(1);
        } else {
          _tennisPointsIndex1++;
        }
      } else {
        if (_tennisPointsIndex2 == 3 && _tennisPointsIndex1 < 3) {
          _winTennisGame(2);
        } else if (_tennisPointsIndex2 == 3 && _tennisPointsIndex1 == 3) {
          _tennisPointsIndex2 = 4;
        } else if (_tennisPointsIndex2 == 3 && _tennisPointsIndex1 == 4) {
          _tennisPointsIndex1 = 3;
        } else if (_tennisPointsIndex2 == 4) {
          _winTennisGame(2);
        } else {
          _tennisPointsIndex2++;
        }
      }
    });
  }

  void _winTennisGame(int team) {
    _tennisPointsIndex1 = 0;
    _tennisPointsIndex2 = 0;
    _tennisServer = _tennisServer == 1 ? 2 : 1;

    if (team == 1) {
      _tennisGamesTeam1++;
      if (_tennisGamesTeam1 >= 6 && (_tennisGamesTeam1 - _tennisGamesTeam2) >= 2) {
        _tennisSetsTeam1++;
        _tennisCompletedSets.add({'t1': _tennisGamesTeam1, 't2': _tennisGamesTeam2});
        _tennisGamesTeam1 = 0;
        _tennisGamesTeam2 = 0;
      }
    } else {
      _tennisGamesTeam2++;
      if (_tennisGamesTeam2 >= 6 && (_tennisGamesTeam2 - _tennisGamesTeam1) >= 2) {
        _tennisSetsTeam2++;
        _tennisCompletedSets.add({'t1': _tennisGamesTeam1, 't2': _tennisGamesTeam2});
        _tennisGamesTeam1 = 0;
        _tennisGamesTeam2 = 0;
      }
    }
  }

  void _addTableTennisPoint(int player, {String? tag}) {
    if (!isCreator) return;

    _pushHistorySnapshot({
      'ttP1': _ttPointsTeam1,
      'ttP2': _ttPointsTeam2,
      'ttG1': _ttGamesTeam1,
      'ttG2': _ttGamesTeam2,
      'ttServer': _ttServer,
    });

    setState(() {
      if (player == 1) {
        _ttPointsTeam1++;
      } else {
        _ttPointsTeam2++;
      }

      // Alternate server every 2 points, or every point if in deuce (>= 10-10)
      final totalPts = _ttPointsTeam1 + _ttPointsTeam2;
      if (_ttPointsTeam1 >= 10 && _ttPointsTeam2 >= 10) {
        _ttServer = (_ttServer == 1) ? 2 : 1;
      } else {
        if (totalPts % 2 == 0) {
          _ttServer = (_ttServer == 1) ? 2 : 1;
        }
      }

      final p1Name = _match.team1Players.isNotEmpty ? _match.team1Players.first.name : _match.team1Short;
      final p2Name = _match.team2Players.isNotEmpty ? _match.team2Players.first.name : _match.team2Short;
      final scoringPlayerName = player == 1 ? p1Name : p2Name;
      final actionTag = tag != null ? ' ($tag)' : '';

      _timelineFeed.insert(
        0,
        MatchTimelineItem(
          timeOrOver: 'G${_ttCompletedGames.length + 1} ${_ttPointsTeam1}-${_ttPointsTeam2}',
          title: 'POINT WON$actionTag',
          description: '$scoringPlayerName wins rally.$actionTag Game Score: $_ttPointsTeam1 - $_ttPointsTeam2.',
          badgeText: '+1',
          badgeColor: player == 1 ? const Color(0xFF059669) : const Color(0xFF2563EB),
          badgeTextColor: Colors.white,
          teamShort: player == 1 ? _match.team1Short : _match.team2Short,
        ),
      );

      // Check Game Concluded (11 points, win by 2)
      if ((_ttPointsTeam1 >= 11 || _ttPointsTeam2 >= 11) && (_ttPointsTeam1 - _ttPointsTeam2).abs() >= 2) {
        final winner = _ttPointsTeam1 > _ttPointsTeam2 ? 1 : 2;
        final winnerName = winner == 1 ? p1Name : p2Name;
        if (winner == 1) {
          _ttGamesTeam1++;
        } else {
          _ttGamesTeam2++;
        }

        _ttCompletedGames.add({'p1': _ttPointsTeam1, 'p2': _ttPointsTeam2});

        _timelineFeed.insert(
          0,
          MatchTimelineItem(
            timeOrOver: 'GAME ${_ttCompletedGames.length}',
            title: 'GAME CONCLUDED',
            description: '$winnerName wins Game ${_ttCompletedGames.length} ($_ttPointsTeam1-$_ttPointsTeam2)! Games tally: $_ttGamesTeam1 - $_ttGamesTeam2.',
            badgeText: 'SET',
            badgeColor: const Color(0xFF8B5CF6),
            badgeTextColor: Colors.white,
            teamShort: winner == 1 ? _match.team1Short : _match.team2Short,
          ),
        );

        _ttPointsTeam1 = 0;
        _ttPointsTeam2 = 0;

        if (_ttGamesTeam1 >= 3 || _ttGamesTeam2 >= 3) {
          _completeMatch();
        }
      }
    });
  }

  void _showAbandonOrEndMatchDialog() {
    if (!isCreator) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Match Options',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Limited-overs innings conclude strictly by overs limit or all-out. You can officially abandon the match if conditions prevent play or conclude the match.',
                style: GoogleFonts.outfit(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFFEF2F2),
                leading: const Icon(Icons.cloud_off_rounded, color: Color(0xFFEF4444)),
                title: Text('Abandon Match', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFFEF4444))),
                subtitle: Text('Abandon whole match due to rain, stoppage, bad light or forfeit', style: GoogleFonts.outfit(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmAbandonMatch();
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFF8FAFC),
                leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                title: Text('Conclude / Finalize Match', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primary)),
                subtitle: Text('Conclude match and finalize current score as official result', style: GoogleFonts.outfit(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _completeMatch();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmAbandonMatch() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Abandon Match?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          content: Text(
            'Are you sure you want to abandon the match? It will be officially recorded as "Match Abandoned (No Result)".',
            style: GoogleFonts.outfit(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _abandonMatch('Stoppage / Weather');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
              child: const Text('Abandon Match'),
            ),
          ],
        );
      },
    );
  }

  void _abandonMatch(String reason) {
    if (!isCreator) return;
    setState(() {
      _isMatchAbandoned = true;
      _abandonReason = reason;
      _isCricketInningsOver = true;
    });

    final summary = 'Match Abandoned ($reason)';
    final finalScore = _match.sport == SportType.cricket
        ? _serializeCricketScoreData(customStatus: summary)
        : <String, dynamic>{'result': summary};

    context.read<AppState>().recordMatchCompletion(
      matchId: _match.id,
      resultText: summary,
      finalScoreData: finalScore,
      mvpPlayer: _calculatedMvpPlayer,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Match Abandoned', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: const Color(0xFFEF4444))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(
              summary,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'No official winner. Points and records shared per tournament rules.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: Colors.white),
            child: const Text('Return to Arena'),
          ),
        ],
      ),
    );
  }

  void _completeMatch() {
    if (!isCreator) return;

    String summary = 'Match Concluded';
    if (_match.sport == SportType.cricket) {
      if (_cricketInnings == 2) {
        if (_cricketRuns >= _targetRuns) {
          summary = '$_secondInningsBattingTeamName won by ${math.max(1, _maxWickets - _cricketWickets)} wickets';
        } else if (_cricketRuns == _targetRuns - 1) {
          summary = 'Match Tied! ($_cricketRuns runs each)';
        } else {
          final diff = _targetRuns - 1 - _cricketRuns;
          summary = '$_firstInningsBattingTeamName won by $diff runs';
        }
      } else {
        summary = '$_firstInningsBattingTeamShort completed 1st innings at $_cricketRuns/$_cricketWickets';
      }
    } else if (_match.sport == SportType.football) {
      if (_footballScoreTeam1 > _footballScoreTeam2) {
        summary = '${_match.team1Name} won $_footballScoreTeam1 - $_footballScoreTeam2';
      } else if (_footballScoreTeam2 > _footballScoreTeam1) {
        summary = '${_match.team2Name} won $_footballScoreTeam2 - $_footballScoreTeam1';
      } else {
        summary = 'Draw $_footballScoreTeam1 - $_footballScoreTeam2';
      }
    } else if (_match.sport == SportType.basketball) {
      if (_basketballScoreTeam1 > _basketballScoreTeam2) {
        summary = '${_match.team1Name} won $_basketballScoreTeam1 - $_basketballScoreTeam2';
      } else if (_basketballScoreTeam2 > _basketballScoreTeam1) {
        summary = '${_match.team2Name} won $_basketballScoreTeam2 - $_basketballScoreTeam1';
      } else {
        summary = 'Tied at $_basketballScoreTeam1 - $_basketballScoreTeam2';
      }
    } else if (_match.sport == SportType.tennis) {
      if (_tennisSetsTeam1 > _tennisSetsTeam2) {
        summary = '${_match.team1Name} won $_tennisSetsTeam1 - $_tennisSetsTeam2 in sets';
      } else if (_tennisSetsTeam2 > _tennisSetsTeam1) {
        summary = '${_match.team2Name} won $_tennisSetsTeam2 - $_tennisSetsTeam1 in sets';
      } else {
        summary = 'Match finished ($_tennisSetsTeam1 - $_tennisSetsTeam2 sets)';
      }
    }

    final Map<String, dynamic> finalScore;
    if (_match.sport == SportType.cricket) {
      finalScore = _serializeCricketScoreData(customStatus: summary);
    } else if (_match.sport == SportType.football) {
      finalScore = {
        'team1_score': '$_footballScoreTeam1',
        'team2_score': '$_footballScoreTeam2',
        'status_text': summary,
        'minute': _footballMinutes,
        'timeline': _timelineFeed.map((e) => e.toMap()).toList(),
        'football_events': _footballEvents,
      };
    } else if (_match.sport == SportType.basketball) {
      finalScore = {
        'team1_score': '$_basketballScoreTeam1',
        'team2_score': '$_basketballScoreTeam2',
        'status_text': summary,
        'quarter': _basketballQuarter,
        'timeline': _timelineFeed.map((e) => e.toMap()).toList(),
      };
    } else if (_match.sport == SportType.tennis) {
      finalScore = {
        'team1_score': '$_tennisSetsTeam1',
        'team2_score': '$_tennisSetsTeam2',
        'status_text': summary,
        'timeline': _timelineFeed.map((e) => e.toMap()).toList(),
      };
    } else {
      finalScore = {'result': summary};
    }

    context.read<AppState>().recordMatchCompletion(
      matchId: _match.id,
      resultText: summary,
      finalScoreData: finalScore,
      mvpPlayer: _calculatedMvpPlayer,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Match Completed!',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 54),
              const SizedBox(height: 12),
              Text(
                summary,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Stats and performance records have been archived to official club passports.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Return to Arena'),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD METHOD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getSportColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _match.sport.name.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: _getSportColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_match.team1Short} vs ${_match.team2Short}',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Role Mode Indicator Badge (Scorer vs Viewer)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCreator ? AppColors.primary.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCreator ? AppColors.primary : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCreator ? Icons.edit_note_rounded : Icons.visibility_rounded,
                  size: 14,
                  color: isCreator ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  isCreator ? 'SCORER' : 'VIEWER',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isCreator ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Testing Toggle (Flip between Creator and Spectator views)
          IconButton(
            icon: Icon(
              _simulateViewer ? Icons.visibility_off_rounded : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            tooltip: _simulateViewer ? 'Switched to Spectator Mode (tap to restore)' : 'Preview as Spectator',
            onPressed: () {
              setState(() {
                _simulateViewer = !_simulateViewer;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_simulateViewer ? 'Viewing match as Spectator (Scoring disabled)' : 'Scorer controls restored for match creator'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          // Creator-only Actions
          if (isCreator) ...[
            if (_match.sport == SportType.cricket && !_isCricketInningsOver && _cricketBalls == 0)
              IconButton(
                icon: const Icon(Icons.people_alt_outlined, color: AppColors.primary),
                tooltip: 'Select Openers',
                onPressed: () => _showOpenersSelectionSheet(isSecondInnings: _cricketInnings == 2),
              ),
            IconButton(
              icon: const Icon(Icons.undo_rounded, color: AppColors.textSecondary),
              tooltip: 'Undo',
              onPressed: _undoLastAction,
            ),
            TextButton(
              onPressed: _match.sport == SportType.cricket ? _showAbandonOrEndMatchDialog : _completeMatch,
              child: Text(
                'End Match',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Universal Pinned Scoreboard Header Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _buildScoreboardHeader(),
          ),

          // Executive TabBar (All 6 Tabs)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800),
              unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Summary'),
                Tab(text: 'Scoreboard'),
                Tab(text: 'Timeline'),
                Tab(text: 'Stats'),
                Tab(text: 'MOM Ranking'),
                Tab(text: 'Squads'),
              ],
            ),
          ),

          // The 6 Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildScoreboardTab(),
                _buildTimelineTab(),
                _buildStatsTab(),
                _buildMomRankingTab(),
                _buildSquadDisplayTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP HEADER BANNER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildScoreboardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isMatchAbandoned ? const Color(0xFFEF4444) : const Color(0xFFE11D48),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isMatchAbandoned ? 'ABANDONED' : 'LIVE',
                    style: GoogleFonts.outfit(
                      color: _isMatchAbandoned ? const Color(0xFFEF4444) : const Color(0xFFE11D48),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isMatchAbandoned && _abandonReason != null ? _abandonReason! : _match.format,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                _match.venue.isNotEmpty ? _match.venue : 'Arena Pitch',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Team 1
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _match.team1Short,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTeam1ScoreDisplay(),
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              Text('VS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
              // Team 2
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _match.team2Short,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTeam2ScoreDisplay(),
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTeam1ScoreDisplay() {
    switch (_match.sport) {
      case SportType.cricket:
        if (_cricketInnings == 1) {
          if (_team1BatsFirst) {
            final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
            return '$_cricketRuns/$_cricketWickets ($overs)';
          } else {
            return 'Yet to bat';
          }
        } else {
          if (_team1BatsFirst) {
            return '$_team1FinalRuns/$_team1FinalWickets ($_team1FinalOvers)';
          } else {
            final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
            return '$_cricketRuns/$_cricketWickets ($overs)';
          }
        }
      case SportType.football:
        return '$_footballScoreTeam1';
      case SportType.basketball:
        return '$_basketballScoreTeam1';
      case SportType.tennis:
        if (_isTableTennisMode) {
          return '$_ttGamesTeam1 Sets ($_ttPointsTeam1)';
        }
        return '$_tennisSetsTeam1 (${_tennisGamesTeam1}g, ${_tennisPointLabels[_tennisPointsIndex1.clamp(0, 4)]})';
    }
  }

  String _getTeam2ScoreDisplay() {
    switch (_match.sport) {
      case SportType.cricket:
        if (_cricketInnings == 1) {
          if (_team1BatsFirst) {
            return 'Yet to bat';
          } else {
            final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
            return '$_cricketRuns/$_cricketWickets ($overs)';
          }
        } else {
          if (_team1BatsFirst) {
            final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
            return '$_cricketRuns/$_cricketWickets ($overs)';
          } else {
            return '$_team1FinalRuns/$_team1FinalWickets ($_team1FinalOvers)';
          }
        }
      case SportType.football:
        return '$_footballScoreTeam2';
      case SportType.basketball:
        return '$_basketballScoreTeam2';
      case SportType.tennis:
        if (_isTableTennisMode) {
          return '$_ttGamesTeam2 Sets ($_ttPointsTeam2)';
        }
        return '$_tennisSetsTeam2 (${_tennisGamesTeam2}g, ${_tennisPointLabels[_tennisPointsIndex2.clamp(0, 4)]})';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: SUMMARY TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSummaryTab() {
    final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
    final crr = _cricketBalls > 0 ? ((_cricketRuns / _cricketBalls) * 6).toStringAsFixed(2) : '0.00';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Status Equation Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _match.sport == SportType.cricket
                            ? (_cricketInnings == 1
                                ? '$_firstInningsBattingTeamName are batting • CRR: $crr'
                                : (_cricketRuns >= _targetRuns
                                    ? '$_secondInningsBattingTeamName won by ${math.max(1, _maxWickets - _cricketWickets)} wickets'
                                    : '$_secondInningsBattingTeamName need ${_targetRuns - _cricketRuns} runs from ${(_maxOvers * 6 - _cricketBalls).clamp(0, _maxOvers * 6)} balls'))
                            : (_match.sport == SportType.football
                                ? '$_footballPeriod • Minute $_footballMinutes\''
                                : '${_match.sport.name.toUpperCase()} Live in Arena'),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF1E40AF)),
                      ),
                      if (_match.tossWinner.isNotEmpty)
                        Text(
                          '${_match.tossWinner} ${_match.tossDecision}',
                          style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // On-Crease Active Performers (Cricket)
          if (_match.sport == SportType.cricket) ...[
            Text('ACTIVE MATCHUP', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sports_cricket_rounded, size: 16, color: Color(0xFF059669)),
                          const SizedBox(width: 6),
                          Text('${_striker.name} *', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                      Text('$_strikerRuns ($_strikerBalls b) • SR ${_strikerBalls > 0 ? ((_strikerRuns / _strikerBalls) * 100).toStringAsFixed(1) : "0.0"}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('  ${_nonStriker.name}', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12.5)),
                      Text('$_nonStrikerRuns ($_nonStrikerBalls b)', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12.5)),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sports_handball_rounded, size: 15, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(_currentBowler.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5)),
                        ],
                      ),
                      Text('$_bowlerWickets/$_bowlerRuns (${_bowlerBalls ~/ 6}.${_bowlerBalls % 6} ov)', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Recent Balls Strip
          Text('RECENT PLAY SEQUENCE', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text('This Over: ', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Expanded(
                  child: _currentOverBalls.isEmpty
                      ? Text('Awaiting first delivery of over...', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMuted))
                      : Wrap(
                          spacing: 6,
                          children: _currentOverBalls.map((b) {
                            final isW = b == 'W';
                            final isBoundary = b == '4' || b == '6';
                            return Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isW ? const Color(0xFFEF4444) : (isBoundary ? const Color(0xFF059669) : Colors.white),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Center(
                                child: Text(
                                  b,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isW || isBoundary ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                Text('Ov $overs', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Match Passport Metadata
          Text('MATCH PASSPORT & VERIFICATION', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildMetaRow('Match Creator & Scorer', '@${_match.creatorId} ${isCreator ? "(You)" : "(Official Scorer)"}'),
                const Divider(height: 16),
                _buildMetaRow('Tournament / Series', _match.tournamentId.isNotEmpty ? _match.tournamentId : 'WorldSports Open Arena'),
                const Divider(height: 16),
                _buildMetaRow('Venue Location', _match.venue.isNotEmpty ? _match.venue : 'International Turf'),
                const Divider(height: 16),
                _buildMetaRow('Broadcast Feed', 'Live Synchronized • Multi-Sport Network'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12.5)),
        Text(value, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12.5)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: SCOREBOARD TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildScoreboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Detailed Scorecard Section ──
          if (_match.sport == SportType.cricket)
            _buildCricketDetailedScorecard()
          else if (_match.sport == SportType.football)
            _buildFootballDetailedScorecard()
          else if (_match.sport == SportType.basketball)
            _buildBasketballDetailedScorecard()
          else
            _buildTennisDetailedScorecard(),

          const SizedBox(height: 24),

          // ── PERMISSION GATED WORKSTATION ──
          if (isCreator) ...[
            // Creator Scoring Workstation
            Row(
              children: [
                const Icon(Icons.sports_score_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'MATCH SCORING CONSOLE (CREATOR AUTHORIZED)',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 0.8),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_match.sport == SportType.cricket)
              _buildCricketPad()
            else if (_match.sport == SportType.football)
              _buildFootballPad()
            else if (_match.sport == SportType.basketball)
              _buildBasketballPad()
            else
              _buildTennisPad(),
          ] else ...[
            // Spectator Read-Only Mode Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.shield_outlined, size: 36, color: Color(0xFF64748B)),
                  const SizedBox(height: 10),
                  Text(
                    'SPECTATOR VIEWING ONLY',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Only the verified match creator (@${_match.creatorId}) has permission to input scores for this match. You are viewing live official match broadcast stats.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCricketDetailedScorecard() {
    final t1Short = _innings1.battingTeamShort;
    final t1Score = _cricketInnings == 1
        ? '$_cricketRuns/$_cricketWickets (${_cricketBalls ~/ 6}.${_cricketBalls % 6} ov)'
        : '${_innings1.runs}/${_innings1.wickets} (${_innings1.oversStr} ov)';

    final t2Short = _innings2.battingTeamShort;
    final t2Score = _cricketInnings == 1
        ? 'Yet to bat'
        : '$_cricketRuns/$_cricketWickets (${_cricketBalls ~/ 6}.${_cricketBalls % 6} ov)';

    final currentData = _selectedScorecardInnings == 1 ? _innings1 : _innings2;
    final isSelectedInningsActive = _selectedScorecardInnings == _cricketInnings;
    final isSelectedInningsUnstarted = _selectedScorecardInnings == 2 && _cricketInnings == 1;

    final activeBatters = currentData.battingRecords.values.where((rec) {
      final isOnCrease = isSelectedInningsActive && (rec.player.id == _striker.id || rec.player.id == _nonStriker.id);
      return rec.isOut || rec.balls > 0 || rec.runs > 0 || isOnCrease;
    }).toList();

    final yetToBat = currentData.battingRecords.values.where((rec) {
      final isOnCrease = isSelectedInningsActive && (rec.player.id == _striker.id || rec.player.id == _nonStriker.id);
      return !rec.isOut && rec.balls == 0 && rec.runs == 0 && !isOnCrease;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── STUMPS-STYLE INNINGS TAB SELECTOR ───
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              // Innings 1 Tab
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedScorecardInnings = 1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _selectedScorecardInnings == 1 ? const Color(0xFF0F172A) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: _selectedScorecardInnings == 1
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$t1Short 1st Inn',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: _selectedScorecardInnings == 1 ? Colors.white : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t1Score,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                            color: _selectedScorecardInnings == 1 ? const Color(0xFF34D399) : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Innings 2 Tab
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedScorecardInnings = 2);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _selectedScorecardInnings == 2 ? const Color(0xFF0F172A) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: _selectedScorecardInnings == 2
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$t2Short 2nd Inn',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: _selectedScorecardInnings == 2 ? Colors.white : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t2Score,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                            color: _selectedScorecardInnings == 2 ? const Color(0xFF34D399) : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ─── UNSTARTED 2ND INNINGS STATE ───
        if (isSelectedInningsUnstarted) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.hourglass_empty_rounded, size: 36, color: Color(0xFF94A3B8)),
                const SizedBox(height: 8),
                Text(
                  '${_innings2.battingTeamName} - 2nd Innings',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Innings yet to commence • Target: ${_cricketRuns + 1} runs ($_maxOvers overs)',
                  style: GoogleFonts.outfit(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('PROVISIONAL BATTING SQUAD', style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _match.team2Players.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        '#${p.jerseyNumber} ${p.name}',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ] else ...[
          // ─── ACTIVE OR COMPLETED INNINGS SCORECARD ───
          // Batting Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${currentData.battingTeamName} Batting',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  isSelectedInningsActive
                      ? '$_cricketRuns/$_cricketWickets (${_cricketBalls ~/ 6}.${_cricketBalls % 6} ov)'
                      : '${currentData.runs}/${currentData.wickets} (${currentData.oversStr} ov)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF34D399), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Batting Table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('BATTER', style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(child: Text('R', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(child: Text('B', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(child: Text('4s', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(child: Text('6s', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(flex: 2, child: Text('SR', textAlign: TextAlign.right, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...activeBatters.map((rec) {
                  final isOnCrease = isSelectedInningsActive && (rec.player.id == _striker.id || rec.player.id == _nonStriker.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      rec.player.name,
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isOnCrease) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      rec.player.id == _striker.id ? '*' : '',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: const Color(0xFF059669), fontSize: 13),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                rec.dismissal,
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  color: rec.isOut
                                      ? const Color(0xFFEF4444)
                                      : (rec.dismissal.contains('not out') ? const Color(0xFF059669) : AppColors.textSecondary),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Text('${rec.runs}', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12.5))),
                        Expanded(child: Text('${rec.balls}', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(child: Text('${rec.fours}', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(child: Text('${rec.sixes}', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(flex: 2, child: Text(rec.strikeRate.toStringAsFixed(1), textAlign: TextAlign.right, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  );
                }),
                if (activeBatters.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Innings commencing • Batters yet to face delivery',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                const Divider(height: 1),
                // Extras & Total Breakdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Extras: ${currentData.totalExtras} (wd ${currentData.extrasWides}, nb ${currentData.extrasNoBalls}, b ${currentData.extrasByes}, lb ${currentData.extrasLegByes})',
                        style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Total: ${isSelectedInningsActive ? "$_cricketRuns/$_cricketWickets" : "${currentData.runs}/${currentData.wickets}"}',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Yet to bat (Google style)
          if (yetToBat.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'YET TO BAT (${yetToBat.length})',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: yetToBat.map((rec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (rec.player.jerseyNumber > 0) ...[
                              Text(
                                '#${rec.player.jerseyNumber} ',
                                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF059669)),
                              ),
                            ],
                            Text(
                              rec.player.name,
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Fall of Wickets
          if (currentData.fallOfWickets.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FALL OF WICKETS', style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: currentData.fallOfWickets.map((fow) {
                      return Text(
                        fow,
                        style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Bowling Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentData.bowlingTeamName} Bowling',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 12.5),
                ),
                Text(
                  'Overs Limit: $_maxOvers ov',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Bowling Table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('BOWLER', style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(child: Text('O', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(child: Text('M', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(child: Text('R', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(child: Text('W', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Expanded(flex: 2, child: Text('ECON', textAlign: TextAlign.right, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...currentData.bowlingRecords.values.map((bl) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(bl.player.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5), overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(child: Text(bl.oversStr, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12))),
                        Expanded(child: Text('${bl.maidens}', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12))),
                        Expanded(child: Text('${bl.runs}', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12))),
                        Expanded(child: Text('${bl.wickets}', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12.5, color: const Color(0xFFEF4444)))),
                        Expanded(flex: 2, child: Text(bl.economy.toStringAsFixed(1), textAlign: TextAlign.right, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFootballDetailedScorecard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GOALS & DISCIPLINE SUMMARY', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _buildMetaRow(_match.team1Name, '$_footballScoreTeam1 Goals'),
          const Divider(height: 14),
          _buildMetaRow(_match.team2Name, '$_footballScoreTeam2 Goals'),
          const Divider(height: 14),
          _buildMetaRow('Match Time Elapsed', '$_footballMinutes Minutes ($_footballPeriod)'),
        ],
      ),
    );
  }

  Widget _buildBasketballDetailedScorecard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUARTER BOX SCORE', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _buildMetaRow(_match.team1Name, '$_basketballScoreTeam1 Pts (Fouls: $_basketballFoulsTeam1)'),
          const Divider(height: 14),
          _buildMetaRow(_match.team2Name, '$_basketballScoreTeam2 Pts (Fouls: $_basketballFoulsTeam2)'),
          const Divider(height: 14),
          _buildMetaRow('Current Period', 'Quarter $_basketballQuarter'),
        ],
      ),
    );
  }

  Widget _buildTennisDetailedScorecard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SET-BY-SET SUMMARY', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _buildMetaRow(_match.team1Name, '$_tennisSetsTeam1 Sets Won (${_tennisGamesTeam1}g)'),
          const Divider(height: 14),
          _buildMetaRow(_match.team2Name, '$_tennisSetsTeam2 Sets Won (${_tennisGamesTeam2}g)'),
        ],
      ),
    );
  }

  // ─── SCORING KEYPAD (CRICKET) ───
  Widget _buildCricketPad() {
    // If innings is completed:
    if (_isCricketInningsOver) {
      if (_cricketInnings == 1) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            children: [
              const Icon(Icons.sports_cricket_rounded, size: 36, color: Color(0xFF059669)),
              const SizedBox(height: 8),
              Text(
                '1st Innings Concluded',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF065F46)),
              ),
              const SizedBox(height: 4),
              Text(
                '$_firstInningsBattingTeamName: $_cricketRuns/$_cricketWickets in ${_cricketBalls ~/ 6}.${_cricketBalls % 6} overs',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Target: ${_cricketRuns + 1} runs from $_maxOvers overs',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1D4ED8)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _switchCricketInnings,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start 2nd Innings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // 2nd Innings Concluded
        String matchResult;
        if (_cricketRuns >= _targetRuns) {
          matchResult = '$_secondInningsBattingTeamName won by ${math.max(1, _maxWickets - _cricketWickets)} wickets';
        } else if (_cricketRuns == _targetRuns - 1) {
          matchResult = 'Match Tied! ($_cricketRuns runs each)';
        } else {
          final diff = _targetRuns - 1 - _cricketRuns;
          matchResult = '$_firstInningsBattingTeamName won by $diff runs';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events_rounded, size: 40, color: Colors.amber),
              const SizedBox(height: 8),
              Text(
                'Match Concluded',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF1E40AF)),
              ),
              const SizedBox(height: 4),
              Text(
                matchResult,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completeMatch,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Finalize Official Match Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return Column(
      children: [
        // Runs Action Grid (Opens Stumps & CricHeroes Cricket Field Selector)
        Row(
          children: [
            _buildScoreButton('0', onTap: () => _handleCricketRunTapped(0)),
            const SizedBox(width: 8),
            _buildScoreButton('1', onTap: () => _handleCricketRunTapped(1)),
            const SizedBox(width: 8),
            _buildScoreButton('2', onTap: () => _handleCricketRunTapped(2)),
            const SizedBox(width: 8),
            _buildScoreButton('3', onTap: () => _handleCricketRunTapped(3)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildScoreButton('4', isHighlight: true, onTap: () => _handleCricketRunTapped(4, isBoundary: true)),
            const SizedBox(width: 8),
            _buildScoreButton('6', isHighlight: true, onTap: () => _handleCricketRunTapped(6, isBoundary: true)),
            const SizedBox(width: 8),
            _buildScoreButton('WD', isExtra: true, onTap: () => _addCricketExtra('WD', 1)),
            const SizedBox(width: 8),
            _buildScoreButton('NB', isExtra: true, onTap: () => _addCricketExtra('NB', 1)),
          ],
        ),
        const SizedBox(height: 12),

        // Wicket & Strike Control
        Row(
          children: [
            Expanded(
              flex: 5,
              child: ElevatedButton.icon(
                onPressed: _recordCricketWicket,
                icon: const Icon(Icons.cancel_rounded, size: 16),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('OUT / WICKET', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: OutlinedButton.icon(
                onPressed: () => setState(_swapStrike),
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Strike'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: OutlinedButton.icon(
                onPressed: _showChangeBowlerDialog,
                icon: const Icon(Icons.sports_handball_rounded, size: 15),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Bowler'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),

        // Test Cricket Declaration Option (Only allowed in Test matches)
        if (_isTestCricket && _cricketInnings == 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showDeclareInningsDialog,
              icon: const Icon(Icons.flag_circle_outlined, size: 18, color: Color(0xFF0F172A)),
              label: Text(
                'Declare 1st Innings (Test Match Only)',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF0F172A)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0F172A)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── SCORING KEYPAD (FOOTBALL) ───
  Widget _buildFootballPad() {
    return Column(
      children: [
        // Clock Controller
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _footballTimerRunning ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    onPressed: () => setState(() => _footballTimerRunning = !_footballTimerRunning),
                  ),
                  Text('$_footballMinutes\'', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 6),
                  Text('($_footballPeriod)', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(onPressed: () => setState(() => _footballMinutes += 1), child: const Text('+1m')),
                  const SizedBox(width: 6),
                  OutlinedButton(onPressed: () => setState(() => _footballMinutes += 5), child: const Text('+5m')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Goal Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addFootballGoal(1),
                icon: const Icon(Icons.sports_soccer_rounded),
                label: Text('+ Goal (${_match.team1Short})'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E6E16), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addFootballGoal(2),
                icon: const Icon(Icons.sports_soccer_rounded),
                label: Text('+ Goal (${_match.team2Short})'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Card Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addFootballCard(1, 'Yellow'),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B)), foregroundColor: const Color(0xFFD97706)),
                child: const Text('🟨 Yellow (T1)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addFootballCard(1, 'Red'),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444)), foregroundColor: const Color(0xFFEF4444)),
                child: const Text('🟥 Red (T1)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addFootballCard(2, 'Yellow'),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B)), foregroundColor: const Color(0xFFD97706)),
                child: const Text('🟨 Yellow (T2)'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── SCORING KEYPAD (BASKETBALL) ───
  Widget _buildBasketballPad() {
    return Column(
      children: [
        Text('${_match.team1Name} Scoring:', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildScoreButton('+1 FT', onTap: () => _addBasketballPoints(1, 1)),
            const SizedBox(width: 8),
            _buildScoreButton('+2 FG', isHighlight: true, onTap: () => _addBasketballPoints(1, 2)),
            const SizedBox(width: 8),
            _buildScoreButton('+3 3PT', isHighlight: true, onTap: () => _addBasketballPoints(1, 3)),
          ],
        ),
        const SizedBox(height: 14),
        Text('${_match.team2Name} Scoring:', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildScoreButton('+1 FT', onTap: () => _addBasketballPoints(2, 1)),
            const SizedBox(width: 8),
            _buildScoreButton('+2 FG', isHighlight: true, onTap: () => _addBasketballPoints(2, 2)),
            const SizedBox(width: 8),
            _buildScoreButton('+3 3PT', isHighlight: true, onTap: () => _addBasketballPoints(2, 3)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _basketballFoulsTeam1++),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                child: Text(
                  '+ Foul (${_match.team1Short}: $_basketballFoulsTeam1)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _basketballFoulsTeam2++),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                child: Text(
                  '+ Foul (${_match.team2Short}: $_basketballFoulsTeam2)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── SCORING KEYPAD (TENNIS & TABLE TENNIS) ───
  Widget _buildTennisPad() {
    final p1Name = _match.team1Players.isNotEmpty ? _match.team1Players.first.name : _match.team1Short;
    final p2Name = _match.team2Players.isNotEmpty ? _match.team2Players.first.name : _match.team2Short;

    return Column(
      children: [
        // Mode Switcher Banner (Table Tennis vs Lawn Tennis)
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isTableTennisMode ? Icons.sports_tennis_rounded : Icons.sports_baseball_rounded,
                    size: 16,
                    color: _isTableTennisMode ? const Color(0xFF059669) : const Color(0xFF65A30D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isTableTennisMode ? 'Table Tennis (11-pt Sets)' : 'Lawn Tennis (15-40 Games)',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() => _isTableTennisMode = !_isTableTennisMode);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _isTableTennisMode ? 'Switch to Tennis' : 'Switch to Table Tennis',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 10.5, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_isTableTennisMode) ...[
          // Table Tennis Active Game & Serving Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAME ${_ttCompletedGames.length + 1} (FIRST TO 11 PTS)',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11, color: const Color(0xFF047857), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Score: $_ttPointsTeam1 - $_ttPointsTeam2 (Sets: $_ttGamesTeam1-$_ttGamesTeam2)',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF059669)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports_tennis_rounded, size: 14, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                      Text(
                        'Serving: ${_ttServer == 1 ? _match.team1Short : _match.team2Short}',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF059669)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Point Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTableTennisPoint(1),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('+ Pt ($p1Name)', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTableTennisPoint(2),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('+ Pt ($p2Name)', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Table Tennis Event Tags
          Row(
            children: [
              _buildTtQuickTag('Smash Winner', () => _addTableTennisPoint(_ttServer, tag: 'Smash Winner')),
              const SizedBox(width: 6),
              _buildTtQuickTag('Service Ace', () => _addTableTennisPoint(_ttServer, tag: 'Service Ace')),
              const SizedBox(width: 6),
              _buildTtQuickTag('Unforced Error', () => _addTableTennisPoint(_ttServer == 1 ? 2 : 1, tag: 'Unforced Error')),
            ],
          ),
        ] else ...[
          // Standard Lawn Tennis Pad
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addTennisPoint(1),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF65A30D), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('+ Point (${_match.team1Short})', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addTennisPoint(2),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('+ Point (${_match.team2Short})', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTtQuickTag(String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildScoreButton(String label, {bool isHighlight = false, bool isExtra = false, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isHighlight
                ? _getSportColor().withValues(alpha: 0.12)
                : isExtra
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHighlight
                  ? _getSportColor()
                  : isExtra
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFCBD5E1),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isHighlight
                    ? _getSportColor()
                    : isExtra
                        ? const Color(0xFFD97706)
                        : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: TIMELINE TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTimelineTab() {
    if (_timelineFeed.isEmpty) {
      return Center(
        child: Text('No timeline incidents recorded yet.', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _timelineFeed.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final item = _timelineFeed[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Pill
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Center(
                  child: Text(
                    item.badgeText,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12, color: item.badgeTextColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                        Text('${item.teamShort} • ${item.timeOrOver}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.description, style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF334155), height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 4: STATS TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── CRICKET ANALYTICS (CRICHEROES & STUMPS DESIGN) ───
          if (_match.sport == SportType.cricket) ...[
            // 1. Worm Graph: Run vs Over with Wickets for BOTH Teams
            CricketWormChart(
              team1Name: _firstInningsBattingTeamName,
              team2Name: _secondInningsBattingTeamName,
              team1Short: _firstInningsBattingTeamShort,
              team2Short: _secondInningsBattingTeamShort,
              team1Overs: _t1OverProgress,
              team2Overs: _t2OverProgress,
              maxOvers: _maxOvers,
              targetRuns: _targetRuns,
            ),
            const SizedBox(height: 16),

            // 2. Manhattan Graph: Runs per Over Bar Graph with Wickets
            CricketManhattanChart(
              team1Short: _firstInningsBattingTeamShort,
              team2Short: _secondInningsBattingTeamShort,
              team1Overs: _t1OverProgress,
              team2Overs: _t2OverProgress,
              maxOvers: _maxOvers,
            ),
            const SizedBox(height: 16),

            // 3. Boundary Breakdown & Run Profile Card (4s, 6s, Boundary %, Dot Ball %)
            CricketBoundaryBreakdownCard(
              team1Short: _firstInningsBattingTeamShort,
              team2Short: _secondInningsBattingTeamShort,
              team1TotalRuns: _cricketInnings == 1 ? _cricketRuns : _innings1.runs,
              team2TotalRuns: _cricketInnings == 2 ? _cricketRuns : _innings2.runs,
              team1Fours: _team1TotalFours,
              team1Sixes: _team1TotalSixes,
              team2Fours: _team2TotalFours,
              team2Sixes: _team2TotalSixes,
              team1DotBalls: _team1DotBalls,
              team1TotalBalls: math.max(1, _cricketInnings == 1 ? _cricketBalls : _innings1.balls),
              team2DotBalls: _team2DotBalls,
              team2TotalBalls: math.max(1, _cricketInnings == 2 ? _cricketBalls : _innings2.balls),
            ),
            const SizedBox(height: 16),

            // 4. Wagon Wheel Shot Distribution Map
            CricketWagonWheelCard(shots: _matchShots),
            const SizedBox(height: 16),
          ]

          // ─── FOOTBALL ANALYTICS ───
          else if (_match.sport == SportType.football) ...[
            // Timestamp vs Goal & Attack Momentum Timeline (0' - 90')
            FootballMomentumTimelineCard(
              team1Name: _match.team1Name,
              team2Name: _match.team2Name,
              team1Short: _match.team1Short,
              team2Short: _match.team2Short,
              currentMinute: _footballMinutes,
              events: _footballEvents,
            ),
            const SizedBox(height: 16),
          ]

          // ─── BASKETBALL ANALYTICS ───
          else if (_match.sport == SportType.basketball) ...[
            // Timestamp vs Scoring & Lead Tracker Timeline
            BasketballLeadTrackerCard(
              team1Short: _match.team1Short,
              team2Short: _match.team2Short,
              team1Score: _basketballScoreTeam1,
              team2Score: _basketballScoreTeam2,
              currentQuarter: _basketballQuarter,
            ),
            const SizedBox(height: 16),
          ]

          // ─── TABLE TENNIS / TENNIS ANALYTICS ───
          else ...[
            // Table Tennis 11-point Sets, Service Points %, Longest Rally & Smash Winners
            TableTennisStatsCard(
              player1Name: _match.team1Name,
              player2Name: _match.team2Name,
              p1Sets: _isTableTennisMode ? _ttGamesTeam1 : _tennisSetsTeam1,
              p2Sets: _isTableTennisMode ? _ttGamesTeam2 : _tennisSetsTeam2,
              p1CurrentPoints: _isTableTennisMode ? _ttPointsTeam1 : _tennisGamesTeam1,
              p2CurrentPoints: _isTableTennisMode ? _ttPointsTeam2 : _tennisGamesTeam2,
              completedGames: _ttCompletedGames.isNotEmpty
                  ? _ttCompletedGames
                  : [
                      {'p1': 11, 'p2': 9},
                      {'p1': 8, 'p2': 11},
                      {'p1': 11, 'p2': 7},
                    ],
            ),
            const SizedBox(height: 16),
          ],

          // ─── HEAD-TO-HEAD COMPARATIVE TABLE ───
          Text('HEAD-TO-HEAD COMPARISON', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 10),

          // Comparison Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                if (_match.sport == SportType.cricket) ...[
                  () {
                    final t1Runs = _cricketInnings == 1 ? _cricketRuns : _innings1.runs;
                    final t1Balls = _cricketInnings == 1 ? _cricketBalls : _innings1.balls;
                    final t2Runs = _cricketInnings == 2 ? _cricketRuns : _innings2.runs;
                    final t2Balls = _cricketInnings == 2 ? _cricketBalls : _innings2.balls;
                    final t1Cr = t1Balls > 0 ? ((t1Runs / t1Balls) * 6).toStringAsFixed(2) : '0.00';
                    final t2Cr = t2Balls > 0 ? ((t2Runs / t2Balls) * 6).toStringAsFixed(2) : (_cricketInnings == 1 ? 'Yet to bat' : '0.00');
                    final t1BoundRuns = (_team1TotalFours * 4) + (_team1TotalSixes * 6);
                    final t2BoundRuns = (_team2TotalFours * 4) + (_team2TotalSixes * 6);
                    final t1BoundPct = t1Runs > 0 ? ((t1BoundRuns / t1Runs) * 100).toStringAsFixed(0) : '0';
                    final t2BoundPct = t2Runs > 0 ? ((t2BoundRuns / t2Runs) * 100).toStringAsFixed(0) : '0';
                    final t1DotPct = t1Balls > 0 ? ((_team1DotBalls / t1Balls) * 100).toStringAsFixed(0) : '0';
                    final t2DotPct = t2Balls > 0 ? ((_team2DotBalls / t2Balls) * 100).toStringAsFixed(0) : '0';
                    final totalRuns = math.max(1, t1Runs + t2Runs);
                    final t1Ratio = (t1Runs / totalRuns).clamp(0.1, 0.9);

                    return Column(
                      children: [
                        _buildStatComparisonRow('Current Run Rate', t1Cr, t2Cr, t1Ratio),
                        const Divider(height: 20),
                        _buildStatComparisonRow('Boundaries (4s / 6s)', '$_team1TotalFours / $_team1TotalSixes', '$_team2TotalFours / $_team2TotalSixes', ((_team1TotalFours + _team1TotalSixes) / math.max(1, (_team1TotalFours + _team1TotalSixes + _team2TotalFours + _team2TotalSixes))).clamp(0.1, 0.9)),
                        const Divider(height: 20),
                        _buildStatComparisonRow('Boundary Run %', '$t1BoundPct%', '$t2BoundPct%', 0.5),
                        const Divider(height: 20),
                        _buildStatComparisonRow('Dot Ball %', '$t1DotPct%', '$t2DotPct%', 0.5),
                        const Divider(height: 20),
                        _buildStatComparisonRow('Extras Conceded', '${_innings1.totalExtras}', '${_innings2.totalExtras}', 0.5),
                      ],
                    );
                  }(),
                ] else if (_match.sport == SportType.football) ...[
                  _buildStatComparisonRow('Possession', '56%', '44%', 0.56),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Shots on Target', '7', '4', 0.64),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Expected Goals (xG)', '1.84', '1.12', 0.62),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Pass Accuracy', '86%', '79%', 0.54),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Fouls Committed', '9', '13', 0.42),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Corner Kicks', '6', '3', 0.67),
                ] else if (_match.sport == SportType.basketball) ...[
                  _buildStatComparisonRow('Field Goal % (FG)', '49%', '43%', 0.53),
                  const Divider(height: 20),
                  _buildStatComparisonRow('3-Point FG % (3PT)', '44%', '32%', 0.58),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Free Throw % (FT)', '82%', '76%', 0.52),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Total Rebounds', '48', '42', 0.53),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Team Assists', '29', '21', 0.58),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Points in Paint', '52', '44', 0.54),
                ] else ...[
                  _buildStatComparisonRow('Service Points Won %', '68%', '54%', 0.56),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Attack / Smash Winners', '18', '11', 0.62),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Unforced Errors', '9', '16', 0.36),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Longest Rally Length', '23 shots', '19 shots', 0.55),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Match Phase Analysis (Cricket)
          if (_match.sport == SportType.cricket) ...[
            Text('PHASE BREAKDOWN', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildPhaseRow('Powerplay (Overs 1 - 6)', '58/1 (RR: 9.66)'),
                  const Divider(height: 16),
                  _buildPhaseRow('Middle Overs (Overs 7 - 15)', '78/2 (RR: 8.66)'),
                  const Divider(height: 16),
                  _buildPhaseRow('Death Overs (Overs 16 - 20)', '51/1 (RR: 12.75)'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatComparisonRow(String metric, String val1, String val2, double ratio) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(val1, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary)),
            Text(metric, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            Text(val2, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Expanded(flex: (ratio * 100).round(), child: Container(color: AppColors.primary)),
                Expanded(flex: ((1 - ratio) * 100).round(), child: Container(color: const Color(0xFFCBD5E1))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseRow(String phase, String stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(phase, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12.5)),
        Text(stats, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 12.5)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 5: MAN OF THE MATCH RANKING TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMomRankingTab() {
    // Generate calculated MVP ladder
    final candidates = <Map<String, dynamic>>[];

    // Batters & Bowlers from match
    final t1 = _match.team1Players;
    final t2 = _match.team2Players;

    if (_match.sport == SportType.cricket) {
      final allPlayers = [...t1, ...t2];
      for (final p in allPlayers) {
        final teamShort = t1.any((x) => x.id == p.id) ? _match.team1Short : _match.team2Short;

        // Batting across both innings
        final b1 = _innings1.battingRecords[p.id];
        final b2 = _innings2.battingRecords[p.id];
        int runs = (b1?.runs ?? 0) + (b2?.runs ?? 0);
        int balls = (b1?.balls ?? 0) + (b2?.balls ?? 0);
        int fours = (b1?.fours ?? 0) + (b2?.fours ?? 0);
        int sixes = (b1?.sixes ?? 0) + (b2?.sixes ?? 0);

        // Bowling across both innings
        final bl1 = _innings1.bowlingRecords[p.id];
        final bl2 = _innings2.bowlingRecords[p.id];
        int wBalls = (bl1?.balls ?? 0) + (bl2?.balls ?? 0);
        int wRuns = (bl1?.runs ?? 0) + (bl2?.runs ?? 0);
        int wickets = (bl1?.wickets ?? 0) + (bl2?.wickets ?? 0);
        int maidens = (bl1?.maidens ?? 0) + (bl2?.maidens ?? 0);

        // Sync live figures if currently active on crease or bowling
        if (p.id == _striker.id) {
          runs = math.max(runs, _strikerRuns);
          balls = math.max(balls, _strikerBalls);
        } else if (p.id == _nonStriker.id) {
          runs = math.max(runs, _nonStrikerRuns);
          balls = math.max(balls, _nonStrikerBalls);
        }
        if (p.id == _currentBowler.id) {
          wBalls = math.max(wBalls, _bowlerBalls);
          wRuns = math.max(wRuns, _bowlerRuns);
          wickets = math.max(wickets, _bowlerWickets);
        }

        // Calculate dynamic cricket MVP points
        double battingPts = runs * 1.5 + fours * 2.5 + sixes * 4.0;
        if (runs >= 50) {
          battingPts += 25;
        } else if (runs >= 30) {
          battingPts += 10;
        }
        if (balls >= 10) {
          final sr = (runs / balls) * 100;
          if (sr >= 150) battingPts += 12;
          else if (sr >= 120) battingPts += 6;
        }

        double bowlingPts = wickets * 30.0 + maidens * 15.0;
        if (wickets >= 3) {
          bowlingPts += 25;
        } else if (wickets >= 2) {
          bowlingPts += 12;
        }
        if (wBalls >= 6) {
          final econ = wRuns / (wBalls / 6.0);
          if (econ < 6.0) bowlingPts += 15;
          else if (econ < 7.5) bowlingPts += 8;
        }

        final totalPts = (battingPts + bowlingPts).round();
        if (totalPts > 0 || runs > 0 || balls > 0 || wickets > 0 || wBalls > 0) {
          final List<String> parts = [];
          if (balls > 0 || runs > 0) {
            parts.add('$runs runs ($balls b)${fours > 0 ? " • $fours fours" : ""}${sixes > 0 ? " • $sixes sixes" : ""}');
          }
          if (wBalls > 0 || wickets > 0) {
            parts.add('$wickets/$wRuns (${wBalls ~/ 6}.${wBalls % 6} ov)');
          }
          candidates.add({
            'player': p,
            'team': teamShort,
            'role': p.role,
            'points': math.max(totalPts, 10),
            'statLine': parts.join(' • '),
          });
        }
      }

      // If no balls have been bowled yet, provide initial ladder with active openers
      if (candidates.isEmpty) {
        if (t1.isNotEmpty) {
          candidates.add({
            'player': _striker,
            'team': _match.team1Short,
            'role': _striker.role,
            'points': 25,
            'statLine': 'Opening Batter',
          });
        }
        if (t1.length > 1) {
          candidates.add({
            'player': _nonStriker,
            'team': _match.team1Short,
            'role': _nonStriker.role,
            'points': 20,
            'statLine': 'Opening Batter',
          });
        }
        if (t2.isNotEmpty) {
          candidates.add({
            'player': _currentBowler,
            'team': _match.team2Short,
            'role': _currentBowler.role,
            'points': 20,
            'statLine': 'Opening Bowler',
          });
        }
      }
    } else if (_match.sport == SportType.football) {
      candidates.add({
        'player': t1.isNotEmpty ? t1[0] : const MatchPlayer(id: 'f1', name: 'Sunil Chhetri', jerseyNumber: 11),
        'team': _match.team1Short,
        'role': 'Forward',
        'points': 88,
        'statLine': '1 Goal • 4 Key Passes • 82% Accuracy',
      });
      candidates.add({
        'player': t2.isNotEmpty ? t2[0] : const MatchPlayer(id: 'f2', name: 'Lionel Messi', jerseyNumber: 10),
        'team': _match.team2Short,
        'role': 'Playmaker',
        'points': 82,
        'statLine': '1 Goal • 3 Dribbles • 2 Shots on target',
      });
    } else {
      candidates.add({
        'player': t1.isNotEmpty ? t1[0] : const MatchPlayer(id: 'b1', name: 'Stephen Curry', jerseyNumber: 30),
        'team': _match.team1Short,
        'role': 'Point Guard',
        'points': 94,
        'statLine': '28 Pts • 6 3PM • 5 Assists',
      });
    }

    candidates.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    final leader = candidates.isNotEmpty ? candidates.first : null;
    final maxPts = leader != null ? (leader['points'] as int) : 100;
    if (leader != null) {
      _calculatedMvpPlayer = (leader['player'] as MatchPlayer).name;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leader Spotlight Card
          if (leader != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events_rounded, size: 14, color: Colors.amber),
                            const SizedBox(width: 5),
                            Text(
                              'PROJECTED MAN OF THE MATCH',
                              style: GoogleFonts.outfit(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '#1 RANK',
                        style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '#${(leader['player'] as MatchPlayer).jerseyNumber}',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (leader['player'] as MatchPlayer).name,
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            Text(
                              '${leader['team']} • ${leader['role']}',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${leader['points']}',
                            style: GoogleFonts.outfit(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 24),
                          ),
                          Text('MVP Points', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 10.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      leader['statLine'] as String,
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Ranking Ladder Table
          Text('FULL MATCH IMPACT LADDER', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: candidates.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final item = candidates[idx];
              final pts = item['points'] as int;
              final ratio = maxPts > 0 ? (pts / maxPts).clamp(0.05, 1.0) : 0.5;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      alignment: Alignment.center,
                      child: Text('#${idx + 1}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: idx == 0 ? Colors.amber[800] : AppColors.textSecondary, fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text((item['player'] as MatchPlayer).name, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text('$pts pts', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text('${item['team']} • ${item['statLine']}', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11.5)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: SizedBox(
                              height: 4,
                              child: LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation(idx == 0 ? Colors.amber : AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 6: SQUAD DISPLAY TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSquadDisplayTab() {
    final activeSquad = _selectedSquadTeam == 1 ? _match.team1Players : _match.team2Players;
    final activeTeamName = _selectedSquadTeam == 1 ? _match.team1Name : _match.team2Name;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Toggle Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSquadTeam = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedSquadTeam == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedSquadTeam == 1 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                      ),
                      child: Center(
                        child: Text(
                          _match.team1Name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _selectedSquadTeam == 1 ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSquadTeam = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedSquadTeam == 2 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedSquadTeam == 2 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                      ),
                      child: Center(
                        child: Text(
                          _match.team2Name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _selectedSquadTeam == 2 ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('PLAYING ROSTER • $activeTeamName', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 10),

          if (activeSquad.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              alignment: Alignment.center,
              child: Text('No squad members registered.', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeSquad.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final player = activeSquad[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE2E8F0),
                        child: Text(
                          '#${player.jerseyNumber}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(player.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                                if (player.isCaptain) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                                    child: Text('C', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                                if (player.isWicketKeeperOrGoalkeeper) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      _match.sport == SportType.football ? 'GK' : 'WK',
                                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(player.role, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(
                        _selectedSquadTeam == 1 ? Icons.shield_rounded : Icons.shield_outlined,
                        size: 18,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
