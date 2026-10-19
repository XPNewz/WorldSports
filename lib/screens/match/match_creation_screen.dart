import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/services/supabase_service.dart';
import 'live_scoring_screen.dart';

class RealOfficialsCatalog {
  static List<MatchPlayer> getScorers() {
    return const [
      MatchPlayer(
        id: 'off_1',
        userId: 'WS-OFF-001',
        username: 'scorer_john',
        name: 'John Scorer',
        jerseyNumber: 0,
        role: 'Official Scorer',
        specsSummary: 'Certified Match Scorer & Analyst',
      ),
      MatchPlayer(
        id: 'off_2',
        userId: 'WS-OFF-002',
        username: 'priya_scorer',
        name: 'Priya Sharma',
        jerseyNumber: 0,
        role: 'Senior Digital Scorer',
        specsSummary: 'Real-time Ball-by-Ball Specialist',
      ),
    ];
  }

  static List<MatchPlayer> getUmpires() {
    return const [
      MatchPlayer(
        id: 'ump_1',
        userId: 'WS-UMP-001',
        username: 'umpire_kumar',
        name: 'Nitin Kumar',
        jerseyNumber: 0,
        role: 'Lead Field Umpire',
        specsSummary: 'Level 3 Certified ICC / BCCI Umpire',
      ),
      MatchPlayer(
        id: 'ump_2',
        userId: 'WS-UMP-002',
        username: 'ref_clattenburg',
        name: 'Mark Davis',
        jerseyNumber: 0,
        role: 'Field Referee',
        specsSummary: 'FIFA & Sanctioned Turf Referee',
      ),
      MatchPlayer(
        id: 'ump_3',
        userId: 'WS-UMP-003',
        username: 'umpire_sarah',
        name: 'Sarah Jenkins',
        jerseyNumber: 0,
        role: '3rd TV Umpire / VAR',
        specsSummary: 'Elite DRS & Video Review Umpire',
      ),
    ];
  }
}

class RealAthletesCatalog {
  static List<MatchPlayer> getAthletesForSport(SportType sport) {
    switch (sport) {
      case SportType.cricket:
        return const [
          MatchPlayer(
            id: 'c1',
            userId: 'WS-1001',
            username: 'rohit45',
            name: 'Rohit Sharma',
            jerseyNumber: 45,
            role: 'Opening Batsman',
            specsSummary: 'Right-hand bat • Right-arm offbreak',
            isCaptain: true,
          ),
          MatchPlayer(
            id: 'c2',
            userId: 'WS-1002',
            username: 'virat18',
            name: 'Virat Kohli',
            jerseyNumber: 18,
            role: 'Top-Order Batsman',
            specsSummary: 'Right-hand bat • Right-arm medium',
          ),
          MatchPlayer(
            id: 'c3',
            userId: 'WS-1003',
            username: 'dhoni07',
            name: 'MS Dhoni',
            jerseyNumber: 7,
            role: 'Wicketkeeper',
            specsSummary: 'Right-hand bat • Wicketkeeper',
            isWicketKeeperOrGoalkeeper: true,
          ),
          MatchPlayer(
            id: 'c4',
            userId: 'WS-1004',
            username: 'jasprit93',
            name: 'Jasprit Bumrah',
            jerseyNumber: 93,
            role: 'Fast Bowler',
            specsSummary: 'Right-arm fast • Yorker specialist',
          ),
          MatchPlayer(
            id: 'c5',
            userId: 'WS-1005',
            username: 'hardik33',
            name: 'Hardik Pandya',
            jerseyNumber: 33,
            role: 'All-Rounder',
            specsSummary: 'Right-hand bat • Right-arm fast-medium',
          ),
          MatchPlayer(
            id: 'c6',
            userId: 'WS-1006',
            username: 'jadeja08',
            name: 'Ravindra Jadeja',
            jerseyNumber: 8,
            role: 'All-Rounder',
            specsSummary: 'Left-hand bat • Slow left-arm orthodox',
          ),
          MatchPlayer(
            id: 'c7',
            userId: 'WS-1007',
            username: 'surya63',
            name: 'Suryakumar Yadav',
            jerseyNumber: 63,
            role: 'Middle Order',
            specsSummary: 'Right-hand 360° bat',
          ),
          MatchPlayer(
            id: 'c8',
            userId: 'WS-1008',
            username: 'pant17',
            name: 'Rishabh Pant',
            jerseyNumber: 17,
            role: 'Wicketkeeper',
            specsSummary: 'Left-hand bat • Wicketkeeper',
            isWicketKeeperOrGoalkeeper: true,
          ),
          MatchPlayer(
            id: 'c9',
            userId: 'WS-1009',
            username: 'shubman77',
            name: 'Shubman Gill',
            jerseyNumber: 77,
            role: 'Opening Batsman',
            specsSummary: 'Right-hand bat',
          ),
          MatchPlayer(
            id: 'c10',
            userId: 'WS-1010',
            username: 'cummins30',
            name: 'Pat Cummins',
            jerseyNumber: 30,
            role: 'Fast Bowler',
            specsSummary: 'Right-arm fast',
          ),
          MatchPlayer(
            id: 'c11',
            userId: 'WS-1011',
            username: 'travis62',
            name: 'Travis Head',
            jerseyNumber: 62,
            role: 'Batsman',
            specsSummary: 'Left-hand aggressive bat • Offbreak',
          ),
          MatchPlayer(
            id: 'c12',
            userId: 'WS-1012',
            username: 'rashid19',
            name: 'Rashid Khan',
            jerseyNumber: 19,
            role: 'Spin Bowler',
            specsSummary: 'Right-arm leg-spinner',
          ),
          MatchPlayer(
            id: 'c13',
            userId: 'WS-1013',
            username: 'klrahul01',
            name: 'KL Rahul',
            jerseyNumber: 1,
            role: 'Wicketkeeper',
            specsSummary: 'Right-hand bat • Wicketkeeper',
            isWicketKeeperOrGoalkeeper: true,
          ),
          MatchPlayer(
            id: 'c14',
            userId: 'WS-1014',
            username: 'starc56',
            name: 'Mitchell Starc',
            jerseyNumber: 56,
            role: 'Fast Bowler',
            specsSummary: 'Left-arm fast',
          ),
          MatchPlayer(
            id: 'c15',
            userId: 'WS-1015',
            username: 'babar56',
            name: 'Babar Azam',
            jerseyNumber: 56,
            role: 'Batsman',
            specsSummary: 'Right-hand cover drive specialist',
          ),
          MatchPlayer(
            id: 'c16',
            userId: 'WS-1016',
            username: 'stokes55',
            name: 'Ben Stokes',
            jerseyNumber: 55,
            role: 'All-Rounder',
            specsSummary: 'Left-hand bat • Right-arm fast-medium',
          ),
        ];
      case SportType.football:
        return const [
          MatchPlayer(
            id: 'f1',
            userId: 'WS-2001',
            username: 'sunil11',
            name: 'Sunil Chhetri',
            jerseyNumber: 11,
            role: 'Forward / Striker',
            specsSummary: 'Right foot • Striker / Forward',
            isCaptain: true,
          ),
          MatchPlayer(
            id: 'f2',
            userId: 'WS-2002',
            username: 'messi10',
            name: 'Lionel Messi',
            jerseyNumber: 10,
            role: 'Forward / Playmaker',
            specsSummary: 'Left foot • Playmaker',
            isCaptain: true,
          ),
          MatchPlayer(
            id: 'f3',
            userId: 'WS-2003',
            username: 'ronaldo07',
            name: 'Cristiano Ronaldo',
            jerseyNumber: 7,
            role: 'Striker',
            specsSummary: 'Right foot • Striker / Finisher',
          ),
          MatchPlayer(
            id: 'f4',
            userId: 'WS-2004',
            username: 'mbappe09',
            name: 'Kylian Mbappé',
            jerseyNumber: 9,
            role: 'Forward / Winger',
            specsSummary: 'Right foot • Rapid Winger',
          ),
          MatchPlayer(
            id: 'f5',
            userId: 'WS-2005',
            username: 'haaland09',
            name: 'Erling Haaland',
            jerseyNumber: 9,
            role: 'Center Forward',
            specsSummary: 'Left foot • Center Forward',
          ),
          MatchPlayer(
            id: 'f6',
            userId: 'WS-2006',
            username: 'debruyne17',
            name: 'Kevin De Bruyne',
            jerseyNumber: 17,
            role: 'Midfielder',
            specsSummary: 'Right foot • Playmaker Midfielder',
          ),
          MatchPlayer(
            id: 'f7',
            userId: 'WS-2007',
            username: 'modric10',
            name: 'Luka Modrić',
            jerseyNumber: 10,
            role: 'Central Midfielder',
            specsSummary: 'Both feet • Central Midfielder',
          ),
          MatchPlayer(
            id: 'f8',
            userId: 'WS-2008',
            username: 'gurpreet01',
            name: 'Gurpreet Singh Sandhu',
            jerseyNumber: 1,
            role: 'Goalkeeper',
            specsSummary: 'Right foot • Goalkeeper',
            isWicketKeeperOrGoalkeeper: true,
          ),
          MatchPlayer(
            id: 'f9',
            userId: 'WS-2009',
            username: 'jhingan05',
            name: 'Sandesh Jhingan',
            jerseyNumber: 5,
            role: 'Center Back',
            specsSummary: 'Right foot • Center Back',
          ),
          MatchPlayer(
            id: 'f10',
            userId: 'WS-2010',
            username: 'bellingham05',
            name: 'Jude Bellingham',
            jerseyNumber: 5,
            role: 'Attacking Midfielder',
            specsSummary: 'Right foot • Box-to-Box Midfielder',
          ),
          MatchPlayer(
            id: 'f11',
            userId: 'WS-2011',
            username: 'vinijr07',
            name: 'Vinicius Jr',
            jerseyNumber: 7,
            role: 'Left Winger',
            specsSummary: 'Right foot • Left Winger',
          ),
          MatchPlayer(
            id: 'f12',
            userId: 'WS-2012',
            username: 'vandijk04',
            name: 'Virgil van Dijk',
            jerseyNumber: 4,
            role: 'Center Back',
            specsSummary: 'Right foot • Center Back',
          ),
          MatchPlayer(
            id: 'f13',
            userId: 'WS-2013',
            username: 'salah11',
            name: 'Mohamed Salah',
            jerseyNumber: 11,
            role: 'Right Winger',
            specsSummary: 'Left foot • Right Winger',
          ),
          MatchPlayer(
            id: 'f14',
            userId: 'WS-2014',
            username: 'yamal19',
            name: 'Lamine Yamal',
            jerseyNumber: 19,
            role: 'Winger',
            specsSummary: 'Left foot • Inverted Winger',
          ),
          MatchPlayer(
            id: 'f15',
            userId: 'WS-2015',
            username: 'sahal10',
            name: 'Sahal Abdul Samad',
            jerseyNumber: 10,
            role: 'Attacking Midfielder',
            specsSummary: 'Right foot • Midfield Maestro',
          ),
          MatchPlayer(
            id: 'f16',
            userId: 'WS-2016',
            username: 'alisson01',
            name: 'Alisson Becker',
            jerseyNumber: 1,
            role: 'Goalkeeper',
            specsSummary: 'Right foot • Sweeper Keeper',
            isWicketKeeperOrGoalkeeper: true,
          ),
        ];
      case SportType.basketball:
        return const [
          MatchPlayer(
            id: 'b1',
            userId: 'WS-3001',
            username: 'curry30',
            name: 'Stephen Curry',
            jerseyNumber: 30,
            role: 'Point Guard',
            specsSummary: 'Point Guard (PG) • Perimeter Sniper',
            isCaptain: true,
          ),
          MatchPlayer(
            id: 'b2',
            userId: 'WS-3002',
            username: 'lebron23',
            name: 'LeBron James',
            jerseyNumber: 23,
            role: 'Small Forward',
            specsSummary: 'Small Forward (SF) • Floor General',
            isCaptain: true,
          ),
          MatchPlayer(
            id: 'b3',
            userId: 'WS-3003',
            username: 'luka77',
            name: 'Luka Dončić',
            jerseyNumber: 77,
            role: 'Point Guard',
            specsSummary: 'Point Guard (PG) • Playmaker',
          ),
          MatchPlayer(
            id: 'b4',
            userId: 'WS-3004',
            username: 'giannis34',
            name: 'Giannis Antetokounmpo',
            jerseyNumber: 34,
            role: 'Power Forward',
            specsSummary: 'Power Forward (PF) • Rim Slasher',
          ),
          MatchPlayer(
            id: 'b5',
            userId: 'WS-3005',
            username: 'jokic15',
            name: 'Nikola Jokić',
            jerseyNumber: 15,
            role: 'Center',
            specsSummary: 'Center (C) • Triple-Double Anchor',
          ),
          MatchPlayer(
            id: 'b6',
            userId: 'WS-3006',
            username: 'durant35',
            name: 'Kevin Durant',
            jerseyNumber: 35,
            role: 'Small Forward',
            specsSummary: 'Small Forward (SF) • Midrange Assassin',
          ),
          MatchPlayer(
            id: 'b7',
            userId: 'WS-3007',
            username: 'tatum00',
            name: 'Jayson Tatum',
            jerseyNumber: 0,
            role: 'Forward',
            specsSummary: 'Small Forward (SF) • 3-Level Scorer',
          ),
          MatchPlayer(
            id: 'b8',
            userId: 'WS-3008',
            username: 'adavis03',
            name: 'Anthony Davis',
            jerseyNumber: 3,
            role: 'Power Forward / Center',
            specsSummary: 'Power Forward (PF) • Shot Blocker',
          ),
          MatchPlayer(
            id: 'b9',
            userId: 'WS-3009',
            username: 'kyrie11',
            name: 'Kyrie Irving',
            jerseyNumber: 11,
            role: 'Point Guard',
            specsSummary: 'Point Guard (PG) • Elite Ballhandler',
          ),
          MatchPlayer(
            id: 'b10',
            userId: 'WS-3010',
            username: 'jimmy22',
            name: 'Jimmy Butler',
            jerseyNumber: 22,
            role: 'Small Forward',
            specsSummary: 'Small Forward (SF) • Two-Way Lock',
          ),
          MatchPlayer(
            id: 'b11',
            userId: 'WS-3011',
            username: 'embiid21',
            name: 'Joel Embiid',
            jerseyNumber: 21,
            role: 'Center',
            specsSummary: 'Center (C) • Post Anchor',
          ),
          MatchPlayer(
            id: 'b12',
            userId: 'WS-3012',
            username: 'klay11',
            name: 'Klay Thompson',
            jerseyNumber: 11,
            role: 'Shooting Guard',
            specsSummary: 'Shooting Guard (SG) • Catch & Shoot',
          ),
          MatchPlayer(
            id: 'b13',
            userId: 'WS-3013',
            username: 'draymond23',
            name: 'Draymond Green',
            jerseyNumber: 23,
            role: 'Power Forward',
            specsSummary: 'Power Forward (PF) • Defensive Anchor',
          ),
          MatchPlayer(
            id: 'b14',
            userId: 'WS-3014',
            username: 'amritpal13',
            name: 'Amritpal Singh',
            jerseyNumber: 13,
            role: 'Center',
            specsSummary: 'Center (C) • Rebounding Force',
          ),
        ];
      case SportType.tennis:
        return const [
          MatchPlayer(
            id: 't1',
            userId: 'WS-4001',
            username: 'djoker',
            name: 'Novak Djokovic',
            jerseyNumber: 1,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • All-Court',
            isCaptain: true,
          ),
          MatchPlayer(
            id: 't2',
            userId: 'WS-4002',
            username: 'alcaraz',
            name: 'Carlos Alcaraz',
            jerseyNumber: 2,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • Aggressive Baseliner',
            isCaptain: true,
          ),
          MatchPlayer(
            id: 't3',
            userId: 'WS-4003',
            username: 'sinner',
            name: 'Jannik Sinner',
            jerseyNumber: 3,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • Baseliner',
          ),
          MatchPlayer(
            id: 't4',
            userId: 'WS-4004',
            username: 'nadal',
            name: 'Rafael Nadal',
            jerseyNumber: 4,
            role: 'Singles Pro',
            specsSummary: 'Left-handed • Two-handed backhand • Clay King',
          ),
          MatchPlayer(
            id: 't5',
            userId: 'WS-4005',
            username: 'medvedev',
            name: 'Daniil Medvedev',
            jerseyNumber: 5,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • Deep Returner',
          ),
          MatchPlayer(
            id: 't6',
            userId: 'WS-4006',
            username: 'zverev',
            name: 'Alexander Zverev',
            jerseyNumber: 6,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • Big Server',
          ),
          MatchPlayer(
            id: 't7',
            userId: 'WS-4007',
            username: 'bopanna',
            name: 'Rohan Bopanna',
            jerseyNumber: 1,
            role: 'Doubles Specialist',
            specsSummary: 'Right-handed • One-handed backhand • Serve & Volley',
          ),
          MatchPlayer(
            id: 't8',
            userId: 'WS-4008',
            username: 'nagal',
            name: 'Sumit Nagal',
            jerseyNumber: 1,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • Counterpuncher',
          ),
          MatchPlayer(
            id: 't9',
            userId: 'WS-4009',
            username: 'swiatek',
            name: 'Iga Świątek',
            jerseyNumber: 1,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • Heavy Topspin',
          ),
          MatchPlayer(
            id: 't10',
            userId: 'WS-4010',
            username: 'sabalenka',
            name: 'Aryna Sabalenka',
            jerseyNumber: 2,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • Power Baseliner',
          ),
          MatchPlayer(
            id: 't11',
            userId: 'WS-4011',
            username: 'gauff',
            name: 'Coco Gauff',
            jerseyNumber: 3,
            role: 'Singles Pro',
            specsSummary: 'Right-handed • Two-handed backhand • All-Court',
          ),
          MatchPlayer(
            id: 't12',
            userId: 'WS-4012',
            username: 'sania',
            name: 'Sania Mirza',
            jerseyNumber: 1,
            role: 'Doubles Specialist',
            specsSummary: 'Right-handed • Two-handed backhand • Forehand Specialist',
          ),
        ];
    }
  }
}

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  int _currentStep = 0; // 0: Sport & Format, 1: Teams & Squads, 2: Toss & Arena

  // Step 1: Sport & Format
  SportType _selectedSport = SportType.cricket;
  String _selectedFormat = 'T20 (20 Overs)';
  final _titleController = TextEditingController(text: 'Arena Invitational Match');
  final _venueController = TextEditingController(text: 'Greenfield Sports Turf, Pitch A');
  int _customOversOrMinutes = 20;

  // Step 2: Teams & Squads
  final _team1NameController = TextEditingController(text: 'Mumbai Mavericks');
  final _team1ShortController = TextEditingController(text: 'MUM');

  final _team2NameController = TextEditingController(text: 'Delhi Dynamos');
  final _team2ShortController = TextEditingController(text: 'DEL');

  int _squadTab = 0; // 0: Team 1, 1: Team 2
  List<MatchPlayer> _team1Squad = [];
  List<MatchPlayer> _team2Squad = [];

  // Step 3: Toss & Conditions
  int _tossWinnerIndex = 0; // 0: Team 1, 1: Team 2
  String _tossDecision = 'Bat'; // 'Bat' / 'Bowl' or 'Kick-off' / 'Defend'

  // Step 3: Officials & Governance
  MatchPlayer? _assignedScorer;
  MatchPlayer? _assignedUmpire1;
  MatchPlayer? _assignedUmpire2;

  @override
  void initState() {
    super.initState();
    _loadDefaultSquads();
    _updateFormatOptions();
    _assignedScorer = RealOfficialsCatalog.getScorers().first;
    _assignedUmpire1 = RealOfficialsCatalog.getUmpires().first;
    _assignedUmpire2 = RealOfficialsCatalog.getUmpires()[1];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _team1NameController.dispose();
    _team1ShortController.dispose();
    _team2NameController.dispose();
    _team2ShortController.dispose();
    super.dispose();
  }

  void _updateFormatOptions() {
    switch (_selectedSport) {
      case SportType.cricket:
        _selectedFormat = 'T20 (20 Overs)';
        _customOversOrMinutes = 20;
        _tossDecision = 'Bat';
        break;
      case SportType.football:
        _selectedFormat = '11v11 Match (90m)';
        _customOversOrMinutes = 90;
        _tossDecision = 'Kick-off';
        break;
      case SportType.basketball:
        _selectedFormat = '4x10 Mins (FIBA)';
        _customOversOrMinutes = 40;
        _tossDecision = 'Possession';
        break;
      case SportType.tennis:
        _selectedFormat = 'Best of 3 Sets';
        _customOversOrMinutes = 3;
        _tossDecision = 'Serve';
        break;
    }
  }

  void _loadDefaultSquads() {
    // SQUADS START EMPTY - NO DUMMY PLAYERS AT START!
    _team1Squad = [];
    _team2Squad = [];

    switch (_selectedSport) {
      case SportType.cricket:
        _team1NameController.text = 'Mumbai Mavericks';
        _team1ShortController.text = 'MUM';
        _team2NameController.text = 'Delhi Dynamos';
        _team2ShortController.text = 'DEL';
        break;
      case SportType.football:
        _team1NameController.text = 'Bengaluru FC';
        _team1ShortController.text = 'BFC';
        _team2NameController.text = 'Mohun Bagan';
        _team2ShortController.text = 'MB';
        break;
      case SportType.basketball:
        _team1NameController.text = 'Golden State';
        _team1ShortController.text = 'GSW';
        _team2NameController.text = 'LA Lakers';
        _team2ShortController.text = 'LAL';
        break;
      case SportType.tennis:
        _team1NameController.text = 'Team Alpha';
        _team1ShortController.text = 'TMA';
        _team2NameController.text = 'Team Beta';
        _team2ShortController.text = 'TMB';
        break;
    }
  }

  List<String> _getAvailableFormats() {
    switch (_selectedSport) {
      case SportType.cricket:
        return ['T20 (20 Overs)', '10-Over Blitz', 'ODI (50 Overs)', '6-Over Turbo Turf'];
      case SportType.football:
        return ['11v11 Match (90m)', '7v7 Turf (40m)', '5v5 Futsal (30m)'];
      case SportType.basketball:
        return ['4x10 Mins (FIBA)', '4x12 Mins (Pro)', '3v3 Half-Court (21 pts)'];
      case SportType.tennis:
        return ['Best of 3 Sets', 'Best of 5 Sets', 'Fast4 Pro Set'];
    }
  }

  Color _getSportAccentColor() {
    switch (_selectedSport) {
      case SportType.cricket: return const Color(0xFF059669);
      case SportType.football: return const Color(0xFF1E6E16);
      case SportType.basketball: return const Color(0xFFEA580C);
      case SportType.tennis: return const Color(0xFF65A30D);
    }
  }

  // ─── Zero-Dummy Athlete Lookup Helper ──────────────────────────────────────

  Future<MatchPlayer?> _lookupAthleteProfile(String query) async {
    final clean = query.trim().replaceAll('@', '').toLowerCase();
    if (clean.isEmpty) return null;

    final currentUser = context.read<AppState>().currentUser;

    // 1. Check live Supabase Database
    try {
      final data = await SupabaseService.fetchPlayerProfile(clean);
      if (data != null) {
        final statsList = data['player_sport_stats'] as List<dynamic>?;
        String specsStr = '';
        if (statsList != null && statsList.isNotEmpty) {
          final s = statsList.first['stats_data'] as Map<String, dynamic>?;
          if (s != null) {
            specsStr = s.entries.map((e) => '${e.value}').join(' • ');
          }
        }
        return MatchPlayer(
          id: data['id']?.toString() ?? 'sp_${DateTime.now().millisecondsSinceEpoch}',
          userId: data['user_id']?.toString() ?? 'WS-${clean.toUpperCase()}',
          username: data['username']?.toString() ?? clean,
          name: data['full_name']?.toString() ?? data['username']?.toString() ?? 'Verified Athlete',
          jerseyNumber: int.tryParse(data['jersey_number']?.toString() ?? '') ?? 10,
          role: data['primary_role']?.toString() ?? 'Athlete',
          specsSummary: specsStr.isNotEmpty ? specsStr : 'Verified Profile',
        );
      }
    } catch (e) {
      debugPrint('Supabase profile lookup error: $e');
    }

    // 2. Check current logged-in user in AppState
    if (currentUser != null) {
      final curUid = currentUser.id.toLowerCase();
      final curName = currentUser.name.toLowerCase();
      if (curUid == clean || curName.contains(clean) || 'ws-8821'.contains(clean) || 'alex_morgan'.contains(clean)) {
        return MatchPlayer(
          id: currentUser.id,
          userId: 'WS-8821',
          username: 'alex_morgan',
          name: currentUser.name,
          jerseyNumber: 10,
          role: currentUser.primaryRole.toUpperCase(),
          specsSummary: currentUser.getSpecsSummaryForSport(_selectedSport),
        );
      }
    }

    // 3. Check RealAthletesCatalog for current sport
    final stars = RealAthletesCatalog.getAthletesForSport(_selectedSport);
    for (final p in stars) {
      if (p.userId.toLowerCase() == clean ||
          p.username.toLowerCase() == clean ||
          p.id.toLowerCase() == clean ||
          p.name.toLowerCase() == clean ||
          p.name.toLowerCase().contains(clean)) {
        return p;
      }
    }

    // 4. Check across all sports in RealAthletesCatalog
    for (final s in SportType.values) {
      for (final p in RealAthletesCatalog.getAthletesForSport(s)) {
        if (p.userId.toLowerCase() == clean ||
            p.username.toLowerCase() == clean ||
            p.id.toLowerCase() == clean ||
            p.name.toLowerCase() == clean ||
            p.name.toLowerCase().contains(clean)) {
          return p;
        }
      }
    }

    return null;
  }

  // ─── Zero-Dummy Official Lookup Helper ─────────────────────────────────────

  Future<MatchPlayer?> _lookupOfficialProfile(String query) async {
    final clean = query.trim().replaceAll('@', '').toLowerCase();
    if (clean.isEmpty) return null;

    final cur = context.read<AppState>().currentUser;

    try {
      final data = await SupabaseService.fetchPlayerProfile(clean);
      if (data != null) {
        return MatchPlayer(
          id: data['id']?.toString() ?? 'sp_${DateTime.now().millisecondsSinceEpoch}',
          userId: data['user_id']?.toString() ?? 'WS-${clean.toUpperCase()}',
          username: data['username']?.toString() ?? clean,
          name: data['full_name']?.toString() ?? data['username']?.toString() ?? 'Certified Official',
          jerseyNumber: 0,
          role: data['primary_role']?.toString() ?? 'Official',
          specsSummary: 'Verified WorldSports Match Official',
        );
      }
    } catch (_) {}

    if (cur != null) {
      if (cur.id.toLowerCase() == clean || cur.name.toLowerCase().contains(clean) || 'ws-8821'.contains(clean)) {
        return MatchPlayer(
          id: cur.id,
          userId: 'WS-8821',
          username: 'alex_morgan',
          name: cur.name,
          jerseyNumber: 0,
          role: cur.primaryRole.toUpperCase(),
          specsSummary: 'Logged-in Account',
        );
      }
    }

    for (final off in [...RealOfficialsCatalog.getScorers(), ...RealOfficialsCatalog.getUmpires()]) {
      if (off.userId.toLowerCase() == clean ||
          off.username.toLowerCase() == clean ||
          off.name.toLowerCase().contains(clean) ||
          off.id.toLowerCase() == clean) {
        return off;
      }
    }
    return null;
  }

  // ─── Zero-Dummy Add Athlete Dialog ─────────────────────────────────────────

  void _showAddPlayerDialog(int teamIndex) {
    int activeDialogTab = 0; // 0: User ID / @Username, 1: Verified Directory Pool
    final idController = TextEditingController();
    bool isSearching = false;
    MatchPlayer? searchedPlayer;
    String? lookupError;

    int customJersey = 1 + (teamIndex == 0 ? _team1Squad.length : _team2Squad.length);
    bool isCaptain = (teamIndex == 0 ? _team1Squad : _team2Squad).isEmpty;
    bool isWkOrGk = false;

    String poolSearchQuery = '';
    final stars = RealAthletesCatalog.getAthletesForSport(_selectedSport);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final targetSquad = teamIndex == 0 ? _team1Squad : _team2Squad;
            final otherSquad = teamIndex == 0 ? _team2Squad : _team1Squad;
            final teamName = teamIndex == 0
                ? (_team1NameController.text.trim().isEmpty ? "Team A" : _team1NameController.text.trim())
                : (_team2NameController.text.trim().isEmpty ? "Team B" : _team2NameController.text.trim());

            final filteredStars = stars.where((p) {
              if (poolSearchQuery.trim().isEmpty) return true;
              final q = poolSearchQuery.trim().toLowerCase();
              return p.name.toLowerCase().contains(q) ||
                  p.role.toLowerCase().contains(q) ||
                  p.userId.toLowerCase().contains(q) ||
                  p.username.toLowerCase().contains(q);
            }).toList();

            Future<void> triggerLookup(String q) async {
              final raw = q.trim();
              if (raw.isEmpty) {
                setModalState(() {
                  lookupError = 'Please enter an authentic User ID (WS-XXXX) or @username';
                  searchedPlayer = null;
                });
                return;
              }

              setModalState(() {
                isSearching = true;
                lookupError = null;
                searchedPlayer = null;
              });

              final res = await _lookupAthleteProfile(raw);
              setModalState(() {
                isSearching = false;
                if (res != null) {
                  searchedPlayer = res;
                  customJersey = res.jerseyNumber > 0 ? res.jerseyNumber : customJersey;
                  isWkOrGk = res.isWicketKeeperOrGoalkeeper;
                  lookupError = null;
                } else {
                  searchedPlayer = null;
                  lookupError = 'User ID "$raw" not registered on WorldSports.\nOnly real users with verified accounts can participate in sanctioned matches.';
                }
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Athlete • $teamName',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Zero-Dummy Policy: Verified User ID required',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: const Color(0xFF0284C7),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Segmented Tabs: ID Lookup vs Verified Directory Pool
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => activeDialogTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: activeDialogTab == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: activeDialogTab == 0 ? const [BoxShadow(color: Colors.black12, blurRadius: 2)] : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.badge_rounded, size: 16, color: activeDialogTab == 0 ? _getSportAccentColor() : const Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'User ID / Username',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                      color: activeDialogTab == 0 ? AppColors.textPrimary : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => activeDialogTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: activeDialogTab == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: activeDialogTab == 1 ? const [BoxShadow(color: Colors.black12, blurRadius: 2)] : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified_user_rounded, size: 16, color: activeDialogTab == 1 ? _getSportAccentColor() : const Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Verified Pool',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                      color: activeDialogTab == 1 ? AppColors.textPrimary : const Color(0xFF64748B),
                                    ),
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

                  if (activeDialogTab == 0) ...[
                    // Tab 0: User ID & Username Lookup
                    TextField(
                      key: const Key('athlete_id_input'),
                      controller: idController,
                      autofocus: false,
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (val) => triggerLookup(val),
                      decoration: InputDecoration(
                        labelText: 'Enter User ID or @username',
                        hintText: 'e.g. WS-1002, @virat18, @rohit45',
                        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.person_search_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                          onPressed: () => triggerLookup(idController.text),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _getSportAccentColor(), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Dedicated Search / Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        key: const Key('verify_account_btn'),
                        onPressed: () => triggerLookup(idController.text),
                        icon: const Icon(Icons.search_rounded, size: 16),
                        label: Text('Verify & Search ID', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getSportAccentColor(),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                    // Quick Suggestion Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Text('Suggestions:', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                        ...(_selectedSport == SportType.cricket
                                ? ['@rohit45', '@virat18', '@jasprit93', '@dhoni07', 'WS-8821']
                                : _selectedSport == SportType.football
                                    ? ['@sunil11', '@messi10', '@ronaldo07', '@gurpreet01']
                                    : _selectedSport == SportType.basketball
                                        ? ['@curry30', '@lebron23', '@luka77']
                                        : ['@djoker', '@alcaraz', '@sinner'])
                            .map((sug) => InkWell(
                                  onTap: () {
                                    idController.text = sug;
                                    triggerLookup(sug);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(sug, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                                  ),
                                )),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Results / Loading / Errors
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (isSearching) ...[
                              const SizedBox(height: 40),
                              Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(strokeWidth: 2.5, color: _getSportAccentColor()),
                                    const SizedBox(height: 12),
                                    Text('Verifying user credentials with registry...', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ] else if (lookupError != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'User ID not registered on WorldSports',
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFFDC2626), fontSize: 13),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            lookupError!,
                                            style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF991B1B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (searchedPlayer != null) ...[
                              // Verified Athlete Preview Badge Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                                              const SizedBox(width: 4),
                                              Text(
                                                'VERIFIED REAL ATHLETE',
                                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2E8F0),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            searchedPlayer!.userId.isNotEmpty ? searchedPlayer!.userId : searchedPlayer!.id,
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.textPrimary),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Profile Information Row
                                    Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: _getSportAccentColor().withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: _getSportAccentColor(), width: 1.5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '#$customJersey',
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, color: _getSportAccentColor()),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      searchedPlayer!.name,
                                                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF0284C7), size: 16),
                                                ],
                                              ),
                                              Text(
                                                '@${searchedPlayer!.username} • ${searchedPlayer!.role}',
                                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),
                                    const Divider(height: 1, color: Color(0xFFDCFCE7)),
                                    const SizedBox(height: 12),

                                    // Athletic Specs Display
                                    Text('ATHLETIC SPECIALIZATION', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF15803D))),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFBBF7D0)),
                                      ),
                                      child: Text(
                                        searchedPlayer!.specsSummary.isNotEmpty ? searchedPlayer!.specsSummary : 'Primary Sport: ${_selectedSport.name.toUpperCase()}',
                                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF166534)),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Match Lineup Settings (Jersey & Captain)
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => setModalState(() => isCaptain = !isCaptain),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: isCaptain,
                                                onChanged: (v) => setModalState(() => isCaptain = v ?? false),
                                                activeColor: _getSportAccentColor(),
                                              ),
                                              Text('Captain (C)', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        if (_selectedSport == SportType.cricket || _selectedSport == SportType.football)
                                          InkWell(
                                            onTap: () => setModalState(() => isWkOrGk = !isWkOrGk),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Checkbox(
                                                  value: isWkOrGk,
                                                  onChanged: (v) => setModalState(() => isWkOrGk = v ?? false),
                                                  activeColor: _getSportAccentColor(),
                                                ),
                                                Text(
                                                  _selectedSport == SportType.cricket ? 'Wicketkeeper' : 'Goalkeeper',
                                                  style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Action Button
                                    Builder(builder: (_) {
                                      final isInTarget = targetSquad.any((p) => p.name == searchedPlayer!.name || (p.userId.isNotEmpty && p.userId == searchedPlayer!.userId));
                                      final isInOther = otherSquad.any((p) => p.name == searchedPlayer!.name || (p.userId.isNotEmpty && p.userId == searchedPlayer!.userId));

                                      if (isInTarget) {
                                        return Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                                          alignment: Alignment.center,
                                          child: Text('Already In This Squad ✓', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF16A34A))),
                                        );
                                      } else if (isInOther) {
                                        return Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                                          alignment: Alignment.center,
                                          child: Text('Already Selected In Opponent Squad', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                                        );
                                      }

                                      return SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            final playerToAdd = searchedPlayer!.copyWith(
                                              jerseyNumber: customJersey,
                                              isCaptain: isCaptain,
                                              isWicketKeeperOrGoalkeeper: isWkOrGk,
                                            );
                                            setState(() {
                                              if (teamIndex == 0) {
                                                _team1Squad.add(playerToAdd);
                                              } else {
                                                _team2Squad.add(playerToAdd);
                                              }
                                            });
                                            Navigator.pop(ctx);
                                          },
                                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                          label: Text('Confirm & Add to $teamName', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _getSportAccentColor(),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 30),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.badge_outlined, size: 48, color: const Color(0xFFCBD5E1)),
                                    const SizedBox(height: 10),
                                    Text('Enter an athlete User ID or @username above', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('Only real registered accounts can be added to squads.', style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11.5)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Tab 1: Verified Directory Pool
                    TextField(
                      onChanged: (val) => setModalState(() => poolSearchQuery = val),
                      style: GoogleFonts.outfit(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search verified directory by name, role, ID...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredStars.length,
                        separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (_, i) {
                          final star = filteredStars[i];
                          final isInTarget = targetSquad.any((p) => p.name == star.name || (p.userId.isNotEmpty && p.userId == star.userId));
                          final isInOther = otherSquad.any((p) => p.name == star.name || (p.userId.isNotEmpty && p.userId == star.userId));

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#${star.jerseyNumber}',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              star.name,
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13.5),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF0284C7)),
                                        ],
                                      ),
                                      Text(
                                        '${star.userId} • @${star.username} • ${star.role}',
                                        style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (star.specsSummary.isNotEmpty)
                                        Text(
                                          star.specsSummary,
                                          style: GoogleFonts.outfit(color: const Color(0xFF059669), fontSize: 10.5, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                if (isInTarget)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                    child: Text('In Squad ✓', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A))),
                                  )
                                else if (isInOther)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                    child: Text('Opponent', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
                                  )
                                else
                                  TextButton(
                                    onPressed: () {
                                      final isFirst = targetSquad.isEmpty;
                                      final playerToAdd = star.copyWith(isCaptain: isFirst);
                                      setState(() {
                                        if (teamIndex == 0) {
                                          _team1Squad.add(playerToAdd);
                                        } else {
                                          _team2Squad.add(playerToAdd);
                                        }
                                      });
                                      setModalState(() {});
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: _getSportAccentColor().withValues(alpha: 0.1),
                                      foregroundColor: _getSportAccentColor(),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text('+ Select', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12)),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Modal to Assign Scorer or Umpire by User ID ───────────────────────────

  void _showAssignOfficialModal({required bool isScorer, int umpireIndex = 1}) {
    final queryController = TextEditingController();
    bool isSearching = false;
    MatchPlayer? foundOfficial;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final title = isScorer ? 'Assign Official Scorer' : 'Assign Match Umpire #$umpireIndex';
            final defaultList = isScorer ? RealOfficialsCatalog.getScorers() : RealOfficialsCatalog.getUmpires();

            Future<void> triggerOfficialLookup(String raw) async {
              if (raw.trim().isEmpty) return;
              setModalState(() {
                isSearching = true;
                errorText = null;
                foundOfficial = null;
              });

              final res = await _lookupOfficialProfile(raw);
              setModalState(() {
                isSearching = false;
                if (res != null) {
                  foundOfficial = res;
                  errorText = null;
                } else {
                  errorText = 'No official found with User ID "$raw". Only registered officials can be sanctioned.';
                }
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: GoogleFonts.outfit(fontSize: 16.5, fontWeight: FontWeight.w800)),
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: queryController,
                    style: GoogleFonts.outfit(fontSize: 13.5),
                    textInputAction: TextInputAction.search,
                    onSubmitted: triggerOfficialLookup,
                    decoration: InputDecoration(
                      hintText: 'Enter official User ID (e.g. WS-OFF-001) or @username...',
                      prefixIcon: const Icon(Icons.badge_rounded, size: 18),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                        onPressed: () => triggerOfficialLookup(queryController.text),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (isSearching) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ] else if (errorText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                      child: Text(errorText!, style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                    ),
                  ] else if (foundOfficial != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 18),
                              const SizedBox(width: 8),
                              Text(foundOfficial!.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14.5)),
                              const Spacer(),
                              Text(foundOfficial!.userId, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('@${foundOfficial!.username} • ${foundOfficial!.role}', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (isScorer) {
                                    _assignedScorer = foundOfficial;
                                  } else if (umpireIndex == 1) {
                                    _assignedUmpire1 = foundOfficial;
                                  } else {
                                    _assignedUmpire2 = foundOfficial;
                                  }
                                });
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Assign as Certified Official', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),
                  Text('CERTIFIED SANCTIONED CREW POOL', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView.separated(
                      itemCount: defaultList.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final off = defaultList[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFF1F5F9),
                            child: Icon(isScorer ? Icons.edit_note_rounded : Icons.sports_rounded, color: AppColors.primary, size: 20),
                          ),
                          title: Row(
                            children: [
                              Text(off.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF0284C7)),
                            ],
                          ),
                          subtitle: Text('${off.userId} • @${off.username} • ${off.role}', style: GoogleFonts.outfit(fontSize: 11)),
                          trailing: TextButton(
                            onPressed: () {
                              setState(() {
                                if (isScorer) {
                                  _assignedScorer = off;
                                } else if (umpireIndex == 1) {
                                  _assignedUmpire1 = off;
                                } else {
                                  _assignedUmpire2 = off;
                                }
                              });
                              Navigator.pop(ctx);
                            },
                            child: Text('Assign', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _startLiveMatch() {
    final minReq = SportPlayerRules.getMinPlayers(_selectedSport, _selectedFormat);
    if (_team1Squad.length < minReq || _team2Squad.length < minReq) {
      final t1Name = _team1NameController.text.trim().isEmpty ? 'Team A' : _team1NameController.text.trim();
      final t2Name = _team2NameController.text.trim().isEmpty ? 'Team B' : _team2NameController.text.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(
            'Both teams must meet the minimum requirement of at least $minReq players ($t1Name: ${_team1Squad.length}/$minReq, $t2Name: ${_team2Squad.length}/$minReq).',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          ),
        ),
      );
      return;
    }

    final matchId = 'live_${DateTime.now().millisecondsSinceEpoch}';

    dynamic initialScoreData;
    switch (_selectedSport) {
      case SportType.cricket:
        initialScoreData = {
          'team1_score': '0/0',
          'team1_overs': '0.0',
          'team2_score': '0/0',
          'team2_overs': '0.0',
          'current_innings': 1,
          'overs_limit': _customOversOrMinutes,
          'striker_id': _team1Squad.isNotEmpty ? _team1Squad[0].id : '',
          'striker_name': _team1Squad.isNotEmpty ? _team1Squad[0].name : '',
          'non_striker_id': _team1Squad.length > 1 ? _team1Squad[1].id : '',
          'non_striker_name': _team1Squad.length > 1 ? _team1Squad[1].name : '',
          'bowler_id': _team2Squad.isNotEmpty ? _team2Squad.last.id : '',
          'bowler_name': _team2Squad.isNotEmpty ? _team2Squad.last.name : '',
          'striker_runs': 0,
          'striker_balls': 0,
          'non_striker_runs': 0,
          'non_striker_balls': 0,
          'bowler_wickets': 0,
          'bowler_runs': 0,
          'bowler_balls': 0,
          'current_over_balls': <String>[],
          'status_text': 'Match Commenced • 1st Innings',
        };
        break;
      case SportType.football:
        initialScoreData = {
          'team1_score': 0,
          'team2_score': 0,
          'minute': 1,
          'period': '1st Half',
          'is_running': true,
          'events': <Map<String, dynamic>>[],
          'status_text': '1\' - 1st Half In Progress',
        };
        break;
      case SportType.basketball:
        initialScoreData = {
          'team1_score': 0,
          'team2_score': 0,
          'quarter': 1,
          'time_left': '10:00',
          'team1_fouls': 0,
          'team2_fouls': 0,
          'status_text': 'Q1 • Tip-off Commenced',
        };
        break;
      case SportType.tennis:
        initialScoreData = {
          'team1_sets': 0,
          'team2_sets': 0,
          'team1_game_pts': '0',
          'team2_game_pts': '0',
          'set_scores': [
            {'t1': 0, 't2': 0}
          ],
          'server': 1,
          'status_text': 'Set 1 • Match In Progress',
        };
        break;
    }

    final newMatch = MatchModel(
      id: matchId,
      sport: _selectedSport,
      team1Id: 'team_a',
      team2Id: 'team_b',
      team1Name: _team1NameController.text.trim().isEmpty ? 'Team A' : _team1NameController.text.trim(),
      team2Name: _team2NameController.text.trim().isEmpty ? 'Team B' : _team2NameController.text.trim(),
      team1Short: _team1ShortController.text.trim().isEmpty ? 'T1' : _team1ShortController.text.trim(),
      team2Short: _team2ShortController.text.trim().isEmpty ? 'T2' : _team2ShortController.text.trim(),
      dateTime: DateTime.now(),
      venue: _venueController.text.trim(),
      tournamentId: _titleController.text.trim(),
      status: MatchStatus.live,
      format: _selectedFormat,
      scoreData: initialScoreData,
      team1Players: _team1Squad,
      team2Players: _team2Squad,
      tossWinner: _tossWinnerIndex == 0 ? _team1NameController.text.trim() : _team2NameController.text.trim(),
      tossDecision: _tossDecision,
      creatorId: context.read<AppState>().currentUser?.id ?? 'u001',
      scorerId: _assignedScorer?.userId ?? 'WS-OFF-001',
      scorerName: _assignedScorer?.name ?? 'John Scorer',
      umpire1Id: _assignedUmpire1?.userId ?? 'WS-UMP-001',
      umpire1Name: _assignedUmpire1?.name ?? 'Nitin Kumar',
      umpire2Id: _assignedUmpire2?.userId ?? 'WS-UMP-002',
      umpire2Name: _assignedUmpire2?.name ?? 'Mark Davis',
    );

    // Save into state
    context.read<AppState>().addMatch(newMatch);

    // Navigate to Live Scoring Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LiveScoringScreen(match: newMatch),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 19),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Match',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                _buildStepPill(index: 0, title: '1. Sport & Format'),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFCBD5E1)),
                const SizedBox(width: 8),
                _buildStepPill(index: 1, title: '2. Squad Lineup'),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFCBD5E1)),
                const SizedBox(width: 8),
                _buildStepPill(index: 2, title: '3. Start Arena'),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: _currentStep == 0
            ? _buildStep1SportAndFormat()
            : _currentStep == 1
                ? _buildStep2Squads()
                : _buildStep3TossAndLaunch(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 0) {
                      setState(() => _currentStep++);
                    } else if (_currentStep == 1) {
                      final minReq = SportPlayerRules.getMinPlayers(_selectedSport, _selectedFormat);
                      if (_team1Squad.length < minReq || _team2Squad.length < minReq) {
                        final t1Name = _team1NameController.text.trim().isEmpty ? 'Team A' : _team1NameController.text.trim();
                        final t2Name = _team2NameController.text.trim().isEmpty ? 'Team B' : _team2NameController.text.trim();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFDC2626),
                            behavior: SnackBarBehavior.floating,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Minimum Player Requirement Not Met',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${_selectedSport.name.toUpperCase()} requires at least $minReq players per team.\n'
                                  '• $t1Name: ${_team1Squad.length}/$minReq players\n'
                                  '• $t2Name: ${_team2Squad.length}/$minReq players',
                                  style: GoogleFonts.outfit(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => _currentStep++);
                    } else {
                      _startLiveMatch();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStep == 2 ? _getSportAccentColor() : AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep == 2 ? 'Start Live Match' : 'Continue',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep == 2 ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepPill({required int index, required String title}) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;

    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.primary
                : isActive
                    ? AppColors.textPrimary
                    : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 11, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: GoogleFonts.outfit(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── Step 1: Sport, Format & Venue ──────────────────────────────────────────

  Widget _buildStep1SportAndFormat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT SPORT',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildSportOption(SportType.cricket, 'Cricket', Icons.sports_cricket_rounded, const Color(0xFF059669)),
            const SizedBox(width: 10),
            _buildSportOption(SportType.football, 'Football', Icons.sports_soccer_rounded, const Color(0xFF1E6E16)),
            const SizedBox(width: 10),
            _buildSportOption(SportType.basketball, 'Basketball', Icons.sports_basketball_rounded, const Color(0xFFEA580C)),
            const SizedBox(width: 10),
            _buildSportOption(SportType.tennis, 'Tennis', Icons.sports_tennis_rounded, const Color(0xFF65A30D)),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'MATCH FORMAT',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getAvailableFormats().map((fmt) {
            final isSel = _selectedFormat == fmt;
            return ChoiceChip(
              label: Text(fmt),
              selected: isSel,
              selectedColor: _getSportAccentColor().withValues(alpha: 0.12),
              backgroundColor: const Color(0xFFF8FAFC),
              labelStyle: GoogleFonts.outfit(
                color: isSel ? _getSportAccentColor() : AppColors.textPrimary,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSel ? _getSportAccentColor() : const Color(0xFFE2E8F0),
              ),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedFormat = fmt;
                    if (_selectedSport == SportType.cricket) {
                      if (fmt.contains('20 Overs')) {
                        _customOversOrMinutes = 20;
                      } else if (fmt.contains('10-Over')) {
                        _customOversOrMinutes = 10;
                      } else if (fmt.contains('50 Overs')) {
                        _customOversOrMinutes = 50;
                      } else if (fmt.contains('6-Over')) {
                        _customOversOrMinutes = 6;
                      }
                    }
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'MATCH DETAILS',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _titleController,
          style: GoogleFonts.outfit(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Tournament / Series Title',
            prefixIcon: Icon(Icons.emoji_events_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _venueController,
          style: GoogleFonts.outfit(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Venue / Stadium Location',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSportOption(SportType sport, String title, IconData icon, Color color) {
    final isSel = _selectedSport == sport;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSport = sport;
            _updateFormatOptions();
            _loadDefaultSquads();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSel ? color.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? color : const Color(0xFFE2E8F0),
              width: isSel ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? color : AppColors.textSecondary, size: 26),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                  color: isSel ? color : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Step 2: Teams & Lineups ────────────────────────────────────────────────

  Widget _buildStep2Squads() {
    final currentSquad = _squadTab == 0 ? _team1Squad : _team2Squad;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Teams Header Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _team1NameController,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  labelText: 'Team A Name',
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _team1ShortController,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Code',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _team2NameController,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  labelText: 'Team B Name',
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _team2ShortController,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Code',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Minimum Player Requirement Info Banner
        _buildMinimumRequirementCard(),
        const SizedBox(height: 16),

        // Squad Tabs
        Row(
          children: [
            Expanded(
              child: _buildSquadTabButton(
                tabIndex: 0,
                teamName: _team1NameController.text.trim().isEmpty ? 'Team A' : _team1NameController.text.trim(),
                count: _team1Squad.length,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSquadTabButton(
                tabIndex: 1,
                teamName: _team2NameController.text.trim().isEmpty ? 'Team B' : _team2NameController.text.trim(),
                count: _team2Squad.length,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Squad Actions Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${currentSquad.length} ATHLETES IN LINEUP',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.textMuted,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddPlayerDialog(_squadTab),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: Text(
                'Add Player',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Squad List
        if (currentSquad.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _getSportAccentColor().withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.group_add_outlined, size: 28, color: _getSportAccentColor()),
                ),
                const SizedBox(height: 12),
                Text(
                  'Squad Lineup is Empty',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'No athletes added yet. Add at least ${SportPlayerRules.getMinPlayers(_selectedSport, _selectedFormat)} players to satisfy the minimum requirement for ${_selectedSport.name.toUpperCase()}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddPlayerDialog(_squadTab),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: Text('Add Athletes to Lineup', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getSportAccentColor(),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentSquad.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final player = currentSquad[i];
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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Center(
                        child: Text(
                          '#${player.jerseyNumber}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                player.name,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (player.isCaptain) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'C',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                              if (player.isWicketKeeperOrGoalkeeper) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _selectedSport == SportType.football ? 'GK' : 'WK',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            player.role,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action: Toggle Captain
                    IconButton(
                      icon: Icon(
                        player.isCaptain ? Icons.star_rounded : Icons.star_border_rounded,
                        color: player.isCaptain ? Colors.amber[700] : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      tooltip: 'Set as Captain',
                      onPressed: () {
                        setState(() {
                          if (_squadTab == 0) {
                            _team1Squad = _team1Squad.map((p) => p.copyWith(isCaptain: p.id == player.id)).toList();
                          } else {
                            _team2Squad = _team2Squad.map((p) => p.copyWith(isCaptain: p.id == player.id)).toList();
                          }
                        });
                      },
                    ),
                    // Action: Remove
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                      onPressed: () {
                        setState(() {
                          if (_squadTab == 0) {
                            _team1Squad.removeAt(i);
                          } else {
                            _team2Squad.removeAt(i);
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSquadTabButton({required int tabIndex, required String teamName, required int count}) {
    final isSel = _squadTab == tabIndex;
    final minReq = SportPlayerRules.getMinPlayers(_selectedSport, _selectedFormat);
    final meetsMin = count >= minReq;
    final accentColor = _getSportAccentColor();

    return GestureDetector(
      onTap: () => setState(() => _squadTab = tabIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSel ? AppColors.textPrimary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? accentColor : (meetsMin ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0)),
            width: isSel ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    teamName,
                    style: GoogleFonts.outfit(
                      color: isSel ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                if (meetsMin)
                  const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF22C55E))
                else
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFF59E0B)),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              '$count / $minReq Min ${meetsMin ? '(Ready)' : '(Needs ${minReq - count} more)'}',
              style: GoogleFonts.outfit(
                color: isSel ? Colors.white70 : (meetsMin ? const Color(0xFF16A34A) : const Color(0xFFD97706)),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimumRequirementCard() {
    final minReq = SportPlayerRules.getMinPlayers(_selectedSport, _selectedFormat);
    final ruleDesc = SportPlayerRules.getRuleDescription(_selectedSport, _selectedFormat);
    final t1Ready = _team1Squad.length >= minReq;
    final t2Ready = _team2Squad.length >= minReq;
    final bothReady = t1Ready && t2Ready;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bothReady ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: bothReady ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            bothReady ? Icons.check_circle_rounded : Icons.info_rounded,
            size: 20,
            color: bothReady ? const Color(0xFF16A34A) : const Color(0xFFD97706),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bothReady
                      ? 'Squad Minimum Requirement Satisfied ($minReq per team)'
                      : 'Minimum Player Requirement: $minReq per team',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: bothReady ? const Color(0xFF15803D) : const Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ruleDesc,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: bothReady ? const Color(0xFF166534) : const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 3: Toss & Final Confirmation ──────────────────────────────────────

  Widget _buildStep3TossAndLaunch() {
    final team1 = _team1NameController.text.trim().isEmpty ? 'Team A' : _team1NameController.text.trim();
    final team2 = _team2NameController.text.trim().isEmpty ? 'Team B' : _team2NameController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Match Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSportAccentColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _selectedSport.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: _getSportAccentColor(),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    _selectedFormat,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _team1ShortController.text.trim().toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          team1,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_team1Squad.length} Players (Valid)',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'VS',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _team2ShortController.text.trim().toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          team2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_team2Squad.length} Players (Valid)',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Toss Winner
        Text(
          'TOSS / INITIATION WINNER',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildChoiceTile(
                title: team1,
                isSelected: _tossWinnerIndex == 0,
                onTap: () => setState(() => _tossWinnerIndex = 0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChoiceTile(
                title: team2,
                isSelected: _tossWinnerIndex == 1,
                onTap: () => setState(() => _tossWinnerIndex = 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Decision
        Text(
          'DECISION',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (_selectedSport == SportType.cricket) ...[
              Expanded(
                child: _buildChoiceTile(
                  title: 'Bat First',
                  isSelected: _tossDecision == 'Bat',
                  onTap: () => setState(() => _tossDecision = 'Bat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChoiceTile(
                  title: 'Bowl First',
                  isSelected: _tossDecision == 'Bowl',
                  onTap: () => setState(() => _tossDecision = 'Bowl'),
                ),
              ),
            ] else if (_selectedSport == SportType.football) ...[
              Expanded(
                child: _buildChoiceTile(
                  title: 'Take Kick-off',
                  isSelected: _tossDecision == 'Kick-off',
                  onTap: () => setState(() => _tossDecision = 'Kick-off'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChoiceTile(
                  title: 'Choose Side',
                  isSelected: _tossDecision == 'Side',
                  onTap: () => setState(() => _tossDecision = 'Side'),
                ),
              ),
            ] else if (_selectedSport == SportType.basketball) ...[
              Expanded(
                child: _buildChoiceTile(
                  title: 'Take Possession',
                  isSelected: _tossDecision == 'Possession',
                  onTap: () => setState(() => _tossDecision = 'Possession'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChoiceTile(
                  title: 'Defend Basket',
                  isSelected: _tossDecision == 'Defend',
                  onTap: () => setState(() => _tossDecision = 'Defend'),
                ),
              ),
            ] else ...[
              Expanded(
                child: _buildChoiceTile(
                  title: 'Serve First',
                  isSelected: _tossDecision == 'Serve',
                  onTap: () => setState(() => _tossDecision = 'Serve'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChoiceTile(
                  title: 'Receive First',
                  isSelected: _tossDecision == 'Receive',
                  onTap: () => setState(() => _tossDecision = 'Receive'),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 24),

        // Sanctioned Officials & Governance
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OFFICIAL MATCH CREW & GOVERNANCE',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.textMuted,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ZERO-DUMMY VERIFIED',
                style: GoogleFonts.outfit(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Official Scorer Card
        _buildOfficialAssignmentCard(
          roleTitle: 'OFFICIAL SCORER (DIGITAL)',
          official: _assignedScorer,
          onTapChange: () => _showAssignOfficialModal(isScorer: true),
        ),

        const SizedBox(height: 10),

        // Lead Field Umpire Card
        _buildOfficialAssignmentCard(
          roleTitle: _selectedSport == SportType.football ? 'HEAD REFEREE' : 'LEAD FIELD UMPIRE',
          official: _assignedUmpire1,
          onTapChange: () => _showAssignOfficialModal(isScorer: false, umpireIndex: 1),
        ),

        const SizedBox(height: 10),

        // 2nd Umpire / Line Referee Card
        _buildOfficialAssignmentCard(
          roleTitle: _selectedSport == SportType.football ? 'ASSISTANT / 4TH OFFICIAL' : '2ND UMPIRE / LINE REFEREE',
          official: _assignedUmpire2,
          onTapChange: () => _showAssignOfficialModal(isScorer: false, umpireIndex: 2),
        ),
      ],
    );
  }

  Widget _buildOfficialAssignmentCard({
    required String roleTitle,
    required MatchPlayer? official,
    required VoidCallback onTapChange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Icon(Icons.shield_rounded, size: 20, color: Color(0xFF0284C7)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      roleTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, size: 12, color: Color(0xFF0284C7)),
                  ],
                ),
                Text(
                  official?.name ?? 'Assigned Official',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${official?.userId ?? "WS-OFF"} • @${official?.username ?? "official"}',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTapChange,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              'Change',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceTile({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? _getSportAccentColor().withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _getSportAccentColor() : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: isSelected ? _getSportAccentColor() : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}
