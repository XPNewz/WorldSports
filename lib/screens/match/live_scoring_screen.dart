import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';

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

  // Detailed Cricket Records
  final Map<String, CricketBattingRecord> _battingRecords = {};
  final Map<String, CricketBowlingRecord> _bowlingRecords = {};
  final List<String> _fallOfWickets = [];

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
  }

  void _initSportState() {
    final t1 = _match.team1Players;
    final t2 = _match.team2Players;

    // Cricket
    _striker = t1.isNotEmpty ? t1[0] : const MatchPlayer(id: 'c1', name: 'Rohit Sharma', jerseyNumber: 45, role: 'Opening Batsman');
    _nonStriker = t1.length > 1 ? t1[1] : const MatchPlayer(id: 'c2', name: 'Virat Kohli', jerseyNumber: 18, role: 'Top-Order Batsman');
    _currentBowler = t2.isNotEmpty ? t2.last : const MatchPlayer(id: 'c10', name: 'Pat Cummins', jerseyNumber: 30, role: 'Fast Bowler');

    final bool isDemoMatch = _match.id == 'm001' || _match.id == 'm002' || _match.id == 'm003' || _match.id == 'm004';

    // Parse pre-existing score data if any (e.g. from mock matches)
    if (_match.sport == SportType.cricket) {
      if (isDemoMatch && _match.scoreData is Map) {
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
          _battingRecords[p.id] = CricketBattingRecord(
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
          _bowlingRecords[p.id] = CricketBowlingRecord(
            player: p,
            balls: p.id == _currentBowler.id ? _bowlerBalls : 18,
            runs: p.id == _currentBowler.id ? _bowlerRuns : 22,
            wickets: p.id == _currentBowler.id ? _bowlerWickets : 1,
            maidens: 0,
          );
        }

        _fallOfWickets.addAll([
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

        for (final p in t1) {
          _battingRecords[p.id] = CricketBattingRecord(
            player: p,
            runs: 0,
            balls: 0,
            fours: 0,
            sixes: 0,
            isOut: false,
            dismissal: 'not out',
          );
        }
        for (final p in t2) {
          _bowlingRecords[p.id] = CricketBowlingRecord(
            player: p,
            balls: 0,
            runs: 0,
            wickets: 0,
            maidens: 0,
          );
        }

        final tossDesc = _match.tossWinner.isNotEmpty
            ? '${_match.tossWinner} won the toss and ${_match.tossDecision.toLowerCase().contains("elected") ? _match.tossDecision : "elected to " + _match.tossDecision}.'
            : 'Match initiated.';
        _timelineFeed.add(
          MatchTimelineItem(
            timeOrOver: '0.0',
            title: 'MATCH COMMENCED',
            description: '$tossDesc ${_striker.name} and ${_nonStriker.name} open the batting for ${_match.team1Name}. ${_currentBowler.name} to bowl the first over.',
            badgeText: 'START',
            badgeColor: const Color(0xFF059669),
            badgeTextColor: Colors.white,
            teamShort: _match.team1Short,
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
        _footballScoreTeam1 = 0;
        _footballScoreTeam2 = 0;
        _footballMinutes = 1;
        _startFootballClock();
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
      if (isDemoMatch) {
        _tennisSetsTeam1 = 1;
        _tennisSetsTeam2 = 1;
        _tennisGamesTeam1 = 4;
        _tennisGamesTeam2 = 3;
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

  void _addCricketRun(int runs, {bool isBoundary = false}) {
    if (!isCreator) return;

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
    });

    setState(() {
      _cricketRuns += runs;
      _cricketBalls++;
      _strikerRuns += runs;
      _strikerBalls++;
      _bowlerRuns += runs;
      _bowlerBalls++;

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
        desc = '${_currentBowler.name} to ${_striker.name}, FOUR! Driven with sublime timing through covers.';
      } else if (runs == 6) {
        desc = '${_currentBowler.name} to ${_striker.name}, SIX! Smoked high and long into the stands!';
      } else if (runs == 0) {
        desc = '${_currentBowler.name} to ${_striker.name}, no run, defended solidly towards mid-off.';
      } else {
        desc = '${_currentBowler.name} to ${_striker.name}, $runs run${runs > 1 ? 's' : ''}, pushed into the outfield.';
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
          teamShort: _cricketInnings == 1 ? _match.team1Short : _match.team2Short,
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

      if (_cricketInnings == 2 && _cricketRuns >= _targetRuns) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _completeMatch());
      }
    });
  }

  void _addCricketExtra(String type, int runs) {
    if (!isCreator) return;

    _pushHistorySnapshot({
      'runs': _cricketRuns,
      'wickets': _cricketWickets,
      'balls': _cricketBalls,
      'bowlerRuns': _bowlerRuns,
      'overBalls': List<String>.from(_currentOverBalls),
    });

    setState(() {
      _cricketRuns += runs;
      _bowlerRuns += runs;
      _currentOverBalls.add(type);

      final blRecord = _bowlingRecords[_currentBowler.id];
      if (blRecord != null) {
        blRecord.runs += runs;
      }

      if (type != 'WD' && type != 'NB') {
        _cricketBalls++;
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
          teamShort: _cricketInnings == 1 ? _match.team1Short : _match.team2Short,
        ),
      );

      _syncCricketToAppState();

      if (_cricketInnings == 2 && _cricketRuns >= _targetRuns) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _completeMatch());
      }
    });
  }

  void _showChangeBowlerDialog() {
    if (!isCreator) return;

    final bowlingSquad = _cricketInnings == 1 ? _match.team2Players : _match.team1Players;
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
                'Select Bowler (${_cricketInnings == 1 ? _match.team2Short : _match.team1Short})',
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              ...bowlingSquad.map((p) {
                final isCurrent = p.id == _currentBowler.id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Text('#${p.jerseyNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary)),
                  ),
                  title: Text(p.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  subtitle: Text(p.role, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: Color(0xFF059669)) : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _currentBowler = p;
                      _bowlerRuns = 0;
                      _bowlerBalls = 0;
                      _bowlerWickets = 0;
                    });
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

    final battingSquad = _cricketInnings == 1 ? _match.team1Players : _match.team2Players;
    final remainingBatsmen = battingSquad.where((p) => p.id != _striker.id && p.id != _nonStriker.id).toList();

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
                      if (remainingBatsmen.length > 1) {
                        _showNextBatsmanDialog(mode, remainingBatsmen);
                      } else {
                        _confirmDismissal(mode, remainingBatsmen.isNotEmpty ? remainingBatsmen.first : null);
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

  void _showNextBatsmanDialog(String mode, List<MatchPlayer> remainingBatsmen) {
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
              ...remainingBatsmen.map((p) => ListTile(
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
    _pushHistorySnapshot({
      'runs': _cricketRuns,
      'wickets': _cricketWickets,
      'balls': _cricketBalls,
      'overBalls': List<String>.from(_currentOverBalls),
      'striker': _striker,
      'strikerRuns': _strikerRuns,
      'strikerBalls': _strikerBalls,
    });

    setState(() {
      _cricketWickets++;
      _cricketBalls++;
      _bowlerWickets++;
      _bowlerBalls++;
      _currentOverBalls.add('W');

      final bRecord = _battingRecords[_striker.id];
      if (bRecord != null) {
        bRecord.isOut = true;
        bRecord.dismissal = '$mode b ${_currentBowler.name}';
      }

      final blRecord = _bowlingRecords[_currentBowler.id];
      if (blRecord != null) {
        blRecord.wickets++;
        blRecord.balls++;
      }

      final overStr = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
      _fallOfWickets.insert(0, '$_cricketWickets-$_cricketRuns (${_striker.name}, $overStr ov)');

      _timelineFeed.insert(
        0,
        MatchTimelineItem(
          timeOrOver: overStr,
          title: 'WICKET DISMISSAL',
          description: 'OUT! ${_striker.name} $mode b ${_currentBowler.name}. Stupendous bowling under pressure!',
          badgeText: 'W',
          badgeColor: const Color(0xFFEF4444),
          badgeTextColor: Colors.white,
          teamShort: _cricketInnings == 1 ? _match.team1Short : _match.team2Short,
        ),
      );

      if (nextBatsman != null) {
        _striker = nextBatsman;
        _strikerRuns = 0;
        _strikerBalls = 0;
      }

      if (_cricketBalls % 6 == 0) {
        _onOverComplete();
      }
      _syncCricketToAppState();

      if (nextBatsman == null || _cricketWickets >= 10) {
        if (_cricketInnings == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _showEndInningsDialog());
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) => _completeMatch());
        }
      }
    });
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

    final bowlingSquad = _cricketInnings == 1 ? _match.team2Players : _match.team1Players;
    if (bowlingSquad.isNotEmpty) {
      final currentIndex = bowlingSquad.indexWhere((p) => p.id == _currentBowler.id);
      final nextIndex = (currentIndex + 1) % bowlingSquad.length;
      _currentBowler = bowlingSquad[nextIndex];
      _bowlerRuns = 0;
      _bowlerBalls = 0;
      _bowlerWickets = 0;
    }
  }

  void _showEndInningsDialog() {
    if (!isCreator) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('End 1st Innings?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Text(
          '${_match.team1Name} finished their innings at $_cricketRuns/$_cricketWickets in ${_cricketBalls ~/ 6}.${_cricketBalls % 6} overs.\n\n${_match.team2Name} will need ${_cricketRuns + 1} runs to win.',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _switchCricketInnings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Start 2nd Innings'),
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
      _cricketInnings = 2;
      _cricketRuns = 0;
      _cricketWickets = 0;
      _cricketBalls = 0;
      _currentOverBalls = [];

      final battingSquad = _match.team2Players;
      final bowlingSquad = _match.team1Players;
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

      _timelineFeed.insert(
        0,
        MatchTimelineItem(
          timeOrOver: 'INN 2',
          title: 'INNINGS BREAK CONCLUDED',
          description: '2nd innings underway. ${_match.team2Name} need $_targetRuns runs for victory.',
          badgeText: 'TARGET',
          badgeColor: const Color(0xFF1D4ED8),
          badgeTextColor: Colors.white,
          teamShort: _match.team2Short,
        ),
      );
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
        _strikerRuns = prev['strikerRuns'] ?? _strikerRuns;
        _strikerBalls = prev['strikerBalls'] ?? _strikerBalls;
        _currentOverBalls = prev['overBalls'] != null ? List<String>.from(prev['overBalls']) : _currentOverBalls;
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

  void _syncCricketToAppState() {
    final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
    final scoreStr = '$_cricketRuns/$_cricketWickets';

    if (_cricketInnings == 1) {
      context.read<AppState>().updateMatchScore(
        _match.id,
        {
          'team1_score': scoreStr,
          'team1_overs': overs,
          'status_text': '${_match.team1Short}: $scoreStr ($overs ov)',
        },
      );
    } else {
      final needed = _targetRuns - _cricketRuns;
      final status = needed <= 0
          ? '${_match.team2Short} won by ${10 - _cricketWickets} wickets'
          : '${_match.team2Short} need $needed runs ($overs ov)';
      context.read<AppState>().updateMatchScore(
        _match.id,
        {
          'team1_score': '$_team1FinalRuns/$_team1FinalWickets ($_team1FinalOvers ov)',
          'team2_score': scoreStr,
          'team2_overs': overs,
          'status_text': status,
        },
      );
    }
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

  void _completeMatch() {
    if (!isCreator) return;

    String summary = 'Match Concluded';
    if (_match.sport == SportType.cricket) {
      if (_cricketInnings == 2) {
        if (_cricketRuns >= _targetRuns) {
          summary = '${_match.team2Name} won by ${10 - _cricketWickets} wickets';
        } else if (_cricketRuns == _targetRuns - 1) {
          summary = 'Match Tied! ($_cricketRuns runs each)';
        } else {
          final diff = _targetRuns - 1 - _cricketRuns;
          summary = '${_match.team1Name} won by $diff runs';
        }
      } else {
        summary = '${_match.team1Short} completed 1st innings at $_cricketRuns/$_cricketWickets';
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

    context.read<AppState>().completeMatch(_match.id, resultText: summary);

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
            IconButton(
              icon: const Icon(Icons.undo_rounded, color: AppColors.textSecondary),
              tooltip: 'Undo',
              onPressed: _undoLastAction,
            ),
            TextButton(
              onPressed: _completeMatch,
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFE11D48),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'LIVE',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFE11D48),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _match.format,
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
          final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
          return '$_cricketRuns/$_cricketWickets ($overs)';
        } else {
          return '$_team1FinalRuns/$_team1FinalWickets ($_team1FinalOvers)';
        }
      case SportType.football:
        return '$_footballScoreTeam1';
      case SportType.basketball:
        return '$_basketballScoreTeam1';
      case SportType.tennis:
        return '$_tennisSetsTeam1 (${_tennisGamesTeam1}g, ${_tennisPointLabels[_tennisPointsIndex1.clamp(0, 4)]})';
    }
  }

  String _getTeam2ScoreDisplay() {
    switch (_match.sport) {
      case SportType.cricket:
        if (_cricketInnings == 1) {
          return 'Yet to bat';
        } else {
          final overs = '${_cricketBalls ~/ 6}.${_cricketBalls % 6}';
          return '$_cricketRuns/$_cricketWickets ($overs)';
        }
      case SportType.football:
        return '$_footballScoreTeam2';
      case SportType.basketball:
        return '$_basketballScoreTeam2';
      case SportType.tennis:
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
                                ? '${_match.team1Name} are batting • CRR: $crr'
                                : (_cricketRuns >= _targetRuns
                                    ? '${_match.team2Name} won by ${10 - _cricketWickets} wickets'
                                    : '${_match.team2Name} need ${_targetRuns - _cricketRuns} runs to win'))
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              Text(
                '${_match.team1Name} Batting',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
              ),
              Text(
                '$_cricketRuns/$_cricketWickets (${_cricketBalls ~/ 6}.${_cricketBalls % 6} ov)',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF35A629), fontSize: 13),
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
              ..._battingRecords.values.map((rec) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.player.name,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              rec.dismissal,
                              style: GoogleFonts.outfit(fontSize: 10.5, color: rec.isOut ? const Color(0xFFEF4444) : const Color(0xFF059669), fontWeight: FontWeight.w600),
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bowling Card Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${_match.team2Name} Bowling',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 12.5),
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
              ..._bowlingRecords.values.map((bl) {
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
    return Column(
      children: [
        // Runs Action Grid
        Row(
          children: [
            _buildScoreButton('0', onTap: () => _addCricketRun(0)),
            const SizedBox(width: 8),
            _buildScoreButton('1', onTap: () => _addCricketRun(1)),
            const SizedBox(width: 8),
            _buildScoreButton('2', onTap: () => _addCricketRun(2)),
            const SizedBox(width: 8),
            _buildScoreButton('3', onTap: () => _addCricketRun(3)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildScoreButton('4', isHighlight: true, onTap: () => _addCricketRun(4, isBoundary: true)),
            const SizedBox(width: 8),
            _buildScoreButton('6', isHighlight: true, onTap: () => _addCricketRun(6, isBoundary: true)),
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
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _recordCricketWicket,
                icon: const Icon(Icons.cancel_rounded, size: 18),
                label: const Text('OUT / WICKET'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(_swapStrike),
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text('Strike'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showChangeBowlerDialog,
                icon: const Icon(Icons.sports_handball_rounded, size: 16),
                label: const Text('Bowler'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),

        // Innings & Target Transition Controls
        if (_cricketInnings == 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showEndInningsDialog,
              icon: const Icon(Icons.swap_horizontal_circle_outlined, size: 18),
              label: Text(
                'End 1st Innings / Switch Sides',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
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

  // ─── SCORING KEYPAD (TENNIS) ───
  Widget _buildTennisPad() {
    return Row(
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
                  _buildStatComparisonRow('Current Run Rate', '10.20', '8.25', 0.55),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Boundaries (4s / 6s)', '24 (18/6)', '19 (15/4)', 0.60),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Boundary Run %', '58%', '48%', 0.58),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Dot Ball %', '32%', '41%', 0.44),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Extras Conceded', '8', '12', 0.40),
                ] else if (_match.sport == SportType.football) ...[
                  _buildStatComparisonRow('Possession', '56%', '44%', 0.56),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Shots on Target', '7', '4', 0.64),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Fouls Committed', '11', '14', 0.44),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Corner Kicks', '5', '3', 0.62),
                ] else ...[
                  _buildStatComparisonRow('Scoring Efficiency', '52%', '47%', 0.53),
                  const Divider(height: 20),
                  _buildStatComparisonRow('Disciplinary Fouls', '6', '8', 0.43),
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
      if (t1.isNotEmpty) {
        candidates.add({
          'player': _striker,
          'team': _match.team1Short,
          'role': _striker.role,
          'points': (_strikerRuns * 1.5 + (_strikerRuns >= 50 ? 25 : 0) + 15).round(),
          'statLine': '$_strikerRuns runs off $_strikerBalls balls • 2 Catches',
        });
      }
      if (t1.length > 1) {
        candidates.add({
          'player': _nonStriker,
          'team': _match.team1Short,
          'role': _nonStriker.role,
          'points': (_nonStrikerRuns * 1.4 + 10).round(),
          'statLine': '$_nonStrikerRuns runs off $_nonStrikerBalls balls',
        });
      }
      if (t2.isNotEmpty) {
        candidates.add({
          'player': _currentBowler,
          'team': _match.team2Short,
          'role': _currentBowler.role,
          'points': (_bowlerWickets * 35 + 20).round(),
          'statLine': '$_bowlerWickets/$_bowlerRuns in ${_bowlerBalls ~/ 6}.${_bowlerBalls % 6} ov',
        });
      }
      // Add other star performers for complete ladder
      if (t1.length > 2) {
        candidates.add({
          'player': t1[2],
          'team': _match.team1Short,
          'role': t1[2].role,
          'points': 74,
          'statLine': '38 runs (22b) • 3 Fours, 1 Six',
        });
      }
      if (t2.length > 1) {
        candidates.add({
          'player': t2[1],
          'team': _match.team2Short,
          'role': t2[1].role,
          'points': 68,
          'statLine': '2/31 (4.0 ov) • 8 Dot Balls',
        });
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
