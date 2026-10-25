import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class DedicatedStatsScreen extends StatefulWidget {
  final SportType initialSport;
  final UserModel? user;

  const DedicatedStatsScreen({
    super.key,
    this.initialSport = SportType.cricket,
    this.user,
  });

  @override
  State<DedicatedStatsScreen> createState() => _DedicatedStatsScreenState();
}

class _DedicatedStatsScreenState extends State<DedicatedStatsScreen> {
  late SportType _selectedSport;
  String _selectedCricketFormat = 'overall';

  final List<Map<String, String>> _cricketFormats = const [
    {'key': 'overall', 'label': 'Overall'},
    {'key': 't20', 'label': 'T20 / T20I'},
    {'key': 'odi', 'label': 'ODI'},
    {'key': 'test', 'label': 'Test'},
    {'key': 'other', 'label': 'Other Formats'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSport = widget.initialSport;
  }

  Color get _sportColor => AppColors.sportColor(_selectedSport.name);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeUser = widget.user ?? appState.currentUser;
    final allMatches = appState.getUserPreviousMatches(activeUser);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ATHLETE STATS ARENA',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _sportColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'OFFICIAL',
                    style: GoogleFonts.outfit(
                      color: _sportColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            if (activeUser != null)
              Text(
                '${activeUser.name} • @${activeUser.username}',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surfaceLighter, height: 1),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── 1. Sport Selection Selector ───────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT SPORT',
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: SportType.values.map((sport) {
                      final isSel = sport == _selectedSport;
                      final sColor = AppColors.sportColor(sport.name);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: BouncingTap(
                            onTap: () {
                              setState(() {
                                _selectedSport = sport;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? sColor : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel ? sColor : AppColors.surfaceLighter,
                                  width: isSel ? 1.5 : 1,
                                ),
                                boxShadow: isSel ? const [AppColors.cellShadowSmall] : [],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SportBadge(sport: sport, showLabel: false, size: 22),
                                  const SizedBox(height: 4),
                                  Text(
                                    sport.name.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: isSel ? Colors.white : AppColors.textSecondary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ─── 2. Sport Specific Body ────────────────────────────────────────
          if (_selectedSport == SportType.cricket)
            ..._buildCricketContent(appState, activeUser, allMatches)
          else
            ..._buildOtherSportContent(appState, activeUser, allMatches, _selectedSport),

          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CRICKET CONTENT (FORMAT TABS + BATTING STATS + BOWLING STATS + MATCH LOG)
  // ═══════════════════════════════════════════════════════════════════════════

  List<Widget> _buildCricketContent(AppState appState, UserModel? user, List<PreviousMatchModel> allMatches) {
    final stats = appState.calculateCricketStats(
      user: user,
      matches: allMatches,
      format: _selectedCricketFormat,
    );

    final cricketMatches = allMatches.where((m) {
      if (m.sport != SportType.cricket) return false;
      if (_selectedCricketFormat == 'overall') return true;
      final rawFmt = m.format.isNotEmpty ? m.format : (m.rawScoreData?['format']?.toString() ?? '');
      final overs = (m.rawScoreData?['overs_limit'] as num?)?.toInt();
      var key = AppState.normalizeCricketFormatKey(rawFmt);
      if (key == 'other' && overs != null) {
        if (overs == 20) key = 't20';
        else if (overs == 50) key = 'odi';
      }
      return key == _selectedCricketFormat;
    }).toList();

    final formatLabel = _cricketFormats.firstWhere(
      (f) => f['key'] == _selectedCricketFormat,
      orElse: () => {'label': 'Overall'},
    )['label']!;

    return [
      // Format Filter Pills Bar
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FORMAT BREAKDOWN',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cricketFormats.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = _cricketFormats[i];
                    final isSel = item['key'] == _selectedCricketFormat;
                    return BouncingTap(
                      onTap: () {
                        setState(() {
                          _selectedCricketFormat = item['key']!;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.cricket : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? AppColors.cricket : AppColors.surfaceLighter,
                            width: isSel ? 1.5 : 1,
                          ),
                          boxShadow: isSel ? const [AppColors.cellShadowSmall] : [],
                        ),
                        child: Center(
                          child: Text(
                            item['label']!.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: isSel ? Colors.white : AppColors.textPrimary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Overview Header Banner
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cricket.withValues(alpha: 0.12),
                  AppColors.cricket.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cricket.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cricket.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sports_cricket_rounded, color: AppColors.cricket, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CRICKET • $formatLabel'.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: AppColors.cricket,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${stats.matches} Matches • ${stats.battingInnings} Inngs Batted • ${stats.bowlingInnings} Inngs Bowled',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ─── Batting Stats Section ─────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.sports_baseball_rounded, color: AppColors.cricket, size: 18),
              const SizedBox(width: 8),
              Text(
                'BATTING CAREER RECORD',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cricket.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formatLabel.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: AppColors.cricket,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Batting Cricbuzz/ESPN-style Data Table (Strictly tabular format, zero box cards)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: _buildBattingSummaryTable(appState, user, allMatches, stats, formatLabel),
        ),
      ),

      // ─── Bowling Stats Section ─────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.change_circle_rounded, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'BOWLING CAREER RECORD',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formatLabel.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bowling Cricbuzz/ESPN-style Data Table (Strictly tabular format, zero box cards)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          child: _buildBowlingSummaryTable(appState, user, allMatches, stats, formatLabel),
        ),
      ),

      // ─── Match Log in Format ───────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'RECORDED MATCHES ($formatLabel)',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Text(
                '${cricketMatches.length} PLAYED',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),

      if (cricketMatches.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLighter),
              ),
              child: Column(
                children: [
                  const Icon(Icons.sports_cricket_outlined, color: AppColors.textMuted, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    'No $formatLabel Matches Recorded Yet',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score or participate in $formatLabel matches to build your verified career record.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final match = cricketMatches[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildMatchHistoryCard(match),
                );
              },
              childCount: cricketMatches.length,
            ),
          ),
        ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OTHER SPORTS CONTENT (FOOTBALL, BASKETBALL, TENNIS)
  // ═══════════════════════════════════════════════════════════════════════════

  List<Widget> _buildOtherSportContent(
    AppState appState,
    UserModel? user,
    List<PreviousMatchModel> allMatches,
    SportType sport,
  ) {
    final sportMatches = allMatches.where((m) => m.sport == sport).toList();
    final sportColor = AppColors.sportColor(sport.name);
    final stats = user?.stats[sport] ?? PlayerStats(
      sport: sport,
      matchesPlayed: sportMatches.length,
      wins: sportMatches.where((m) => m.isWin).length,
      losses: sportMatches.where((m) => !m.isWin).length,
      rating: 7.0,
    );
    final s = stats.specificStats;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sportColor.withValues(alpha: 0.12),
                  sportColor.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sportColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                SportBadge(sport: sport, showLabel: false, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sport.name.toUpperCase()} CAREER ARENA',
                        style: GoogleFonts.outfit(
                          color: sportColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${stats.matchesPlayed} Matches Participated • ${stats.wins} Wins',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Performance Record Table (Strictly tabular format, zero box cards)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildOtherSportTable(sport, stats, s, sportColor),
        ),
      ),

      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'COMPLETED ${sport.name.toUpperCase()} MATCHES',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Text(
                '${sportMatches.length} PLAYED',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),

      if (sportMatches.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLighter),
              ),
              child: Column(
                children: [
                  SportBadge(sport: sport, showLabel: false, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    'No ${sport.name} Matches Recorded Yet',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Participate in ${sport.name} matches to record real verified career statistics.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final match = sportMatches[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildMatchHistoryCard(match),
                );
              },
              childCount: sportMatches.length,
            ),
          ),
        ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REUSABLE TABLES & CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBattingSummaryTable(
    AppState appState,
    UserModel? user,
    List<PreviousMatchModel> allMatches,
    CricketCareerStats currentStats,
    String formatLabel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Text(
                  'BATTING CAREER RECORD (TABULAR)',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'ESPN / CRICBUZZ STANDARD',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceLighter),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              horizontalMargin: 14,
              columnSpacing: 18,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('FORMAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('MATCHES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('INNINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RUNS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('BALL FACED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('AVG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('STRIKE RATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('50s', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('100s', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('HIGHEST SCORE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('NOT OUTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('4s', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('6s', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _cricketFormats.map((f) {
                final fKey = f['key']!;
                final fLabel = f['label']!;
                final isCurrent = fKey == _selectedCricketFormat;
                final fStats = isCurrent
                    ? currentStats
                    : appState.calculateCricketStats(user: user, matches: allMatches, format: fKey);

                return DataRow(
                  selected: isCurrent,
                  color: isCurrent
                      ? WidgetStateProperty.all(AppColors.cricket.withValues(alpha: 0.08))
                      : null,
                  onSelectChanged: (_) {
                    setState(() {
                      _selectedCricketFormat = fKey;
                    });
                  },
                  cells: [
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(color: AppColors.cricket, shape: BoxShape.circle),
                          ),
                        Text(
                          fLabel,
                          style: GoogleFonts.outfit(
                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                            color: isCurrent ? AppColors.cricket : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )),
                    DataCell(Text('${fStats.matches}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.battingInnings}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.runs}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.cricket, fontSize: 12.5))),
                    DataCell(Text('${fStats.ballsFaced}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text(fStats.battingAvgDisplay, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12))),
                    DataCell(Text(fStats.strikeRateDisplay, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12))),
                    DataCell(Text('${fStats.fifties}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.hundreds}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text(fStats.highestScoreDisplay, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.cricket, fontSize: 12))),
                    DataCell(Text('${fStats.notOuts}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.fours}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.sixes}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBowlingSummaryTable(
    AppState appState,
    UserModel? user,
    List<PreviousMatchModel> allMatches,
    CricketCareerStats currentStats,
    String formatLabel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Text(
                  'BOWLING CAREER RECORD (TABULAR)',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'ESPN / CRICBUZZ STANDARD',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceLighter),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              horizontalMargin: 14,
              columnSpacing: 18,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('FORMAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('MATCHES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('INNINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('BALL BOWLED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('OVERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RUN GIVEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('WICKETS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('BEST FIGURE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('AVG.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('ECONOMY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('STRIKE RATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('MAIDENS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _cricketFormats.map((f) {
                final fKey = f['key']!;
                final fLabel = f['label']!;
                final isCurrent = fKey == _selectedCricketFormat;
                final fStats = isCurrent
                    ? currentStats
                    : appState.calculateCricketStats(user: user, matches: allMatches, format: fKey);

                return DataRow(
                  selected: isCurrent,
                  color: isCurrent
                      ? WidgetStateProperty.all(AppColors.secondary.withValues(alpha: 0.08))
                      : null,
                  onSelectChanged: (_) {
                    setState(() {
                      _selectedCricketFormat = fKey;
                    });
                  },
                  cells: [
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                          ),
                        Text(
                          fLabel,
                          style: GoogleFonts.outfit(
                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                            color: isCurrent ? AppColors.secondary : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )),
                    DataCell(Text('${fStats.matches}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.bowlingInnings}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.ballsBowled}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text(fStats.oversDisplay, style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.runsConceded}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                    DataCell(Text('${fStats.wickets}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.secondary, fontSize: 12.5))),
                    DataCell(Text(fStats.bestFigure, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.gold, fontSize: 12))),
                    DataCell(Text(fStats.bowlingAvgDisplay, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12))),
                    DataCell(Text(fStats.economyDisplay, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.accent, fontSize: 12))),
                    DataCell(Text(fStats.bowlingStrikeRateDisplay, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12))),
                    DataCell(Text('${fStats.maidens}', style: GoogleFonts.outfit(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, fontSize: 12))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSportTable(SportType sport, PlayerStats stats, Map<String, dynamic> s, Color sportColor) {
    List<Map<String, String>> rows = [];
    if (sport == SportType.football) {
      rows = [
        {'stat': 'MATCHES', 'val': '${stats.matchesPlayed}', 'benchmark': 'Official Matches Participated'},
        {'stat': 'WINS', 'val': '${stats.wins}', 'benchmark': 'Matches Won'},
        {'stat': 'GOALS', 'val': '${s['goals'] ?? 0}', 'benchmark': 'Goals Scored In Open Play'},
        {'stat': 'ASSISTS', 'val': '${s['assists'] ?? 0}', 'benchmark': 'Decisive Key Assists'},
        {'stat': 'PASS ACCURACY', 'val': '${s['pass_accuracy'] ?? '0.0%'}', 'benchmark': 'Completed Pass Ratio'},
        {'stat': 'SHOTS ON TARGET', 'val': '${s['shots_on_target'] ?? 0}', 'benchmark': 'On Target Finishing'},
        {'stat': 'CLEAN SHEETS', 'val': '${s['clean_sheets'] ?? 0}', 'benchmark': 'Zero Conceded Games'},
        {'stat': 'YELLOW CARDS', 'val': '${s['yellow_cards'] ?? 0}', 'benchmark': 'Caution Disciplinary'},
        {'stat': 'RED CARDS', 'val': '${s['red_cards'] ?? 0}', 'benchmark': 'Dismissals Disciplinary'},
      ];
    } else if (sport == SportType.basketball) {
      rows = [
        {'stat': 'MATCHES', 'val': '${stats.matchesPlayed}', 'benchmark': 'Official Games Played'},
        {'stat': 'WINS', 'val': '${stats.wins}', 'benchmark': 'Games Won'},
        {'stat': 'POINTS', 'val': '${s['points'] ?? 0}', 'benchmark': 'Points Scored In Play'},
        {'stat': 'ASSISTS', 'val': '${s['assists'] ?? 0}', 'benchmark': 'Playmaking Assists'},
        {'stat': 'REBOUNDS', 'val': '${s['rebounds'] ?? 0}', 'benchmark': 'Offensive & Defensive Boards'},
        {'stat': 'STEALS', 'val': '${s['steals'] ?? 0}', 'benchmark': 'Turnovers Forced'},
        {'stat': 'BLOCKS', 'val': '${s['blocks'] ?? 0}', 'benchmark': 'Rim Protection Blocks'},
        {'stat': 'FIELD GOAL %', 'val': '${s['field_goal_pct'] ?? '0.0%'}', 'benchmark': 'Efficiency Inside Arc'},
        {'stat': '3-POINT %', 'val': '${s['three_point_pct'] ?? '0.0%'}', 'benchmark': 'Perimeter Accuracy'},
      ];
    } else {
      // Tennis
      rows = [
        {'stat': 'MATCHES', 'val': '${stats.matchesPlayed}', 'benchmark': 'Official Matches Played'},
        {'stat': 'WINS', 'val': '${stats.wins}', 'benchmark': 'Matches Won'},
        {'stat': 'LOSSES', 'val': '${stats.losses}', 'benchmark': 'Matches Conceded'},
        {'stat': 'WIN RATE', 'val': '${(stats.winRate * 100).toStringAsFixed(1)}%', 'benchmark': 'Match Victory Percentage'},
        {'stat': 'ACES', 'val': '${s['aces'] ?? 0}', 'benchmark': 'Unreturned First Serves'},
        {'stat': 'DOUBLE FAULTS', 'val': '${s['double_faults'] ?? 0}', 'benchmark': 'Service Errors'},
        {'stat': 'FIRST SERVE %', 'val': '${s['first_serve_pct'] ?? '0.0%'}', 'benchmark': 'First Serve In Play'},
        {'stat': 'BREAK PTS WON', 'val': '${s['break_points_won'] ?? 0}', 'benchmark': 'Return Game Conversions'},
        {'stat': 'RATING', 'val': '${stats.rating}', 'benchmark': 'Skill Competency Index'},
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Text(
                  '${sport.name.toUpperCase()} PERFORMANCE RECORD (TABULAR)',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'OFFICIAL RECORD',
                  style: GoogleFonts.outfit(
                    color: sportColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceLighter),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              horizontalMargin: 14,
              columnSpacing: 28,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('STATISTIC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('VALUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CATEGORY / BENCHMARK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: rows.map((r) {
                return DataRow(cells: [
                  DataCell(Text(r['stat']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary))),
                  DataCell(Text(r['val']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, color: sportColor))),
                  DataCell(Text(r['benchmark']!, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHistoryCard(PreviousMatchModel match) {
    final dateStr = DateFormat('d MMM yyyy').format(match.date);
    final isWin = match.isWin;
    final isAbandoned = match.resultText.toLowerCase().contains('abandon');

    final Color badgeColor = isAbandoned
        ? const Color(0xFFEF4444)
        : (isWin ? const Color(0xFF10B981) : const Color(0xFF6B7280));
    final String badgeText = isAbandoned ? 'NO RESULT' : (isWin ? 'WON' : 'LOST');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceLighter),
        boxShadow: const [AppColors.cellShadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportBadge(sport: match.sport, showLabel: false, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${match.team1Name} vs ${match.team2Name}',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.outfit(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$dateStr • ${match.format}',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${match.team1Short}: ${match.team1Score}  |  ${match.team2Short}: ${match.team2Score}',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceLighter),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'My Performance: ${match.myPerformance}',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (match.mvpPlayer != null && match.mvpPlayer!.isNotEmpty) ...[
                  const Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                  const SizedBox(width: 3),
                  Text(
                    'MVP: ${match.mvpPlayer}',
                    style: GoogleFonts.outfit(
                      color: AppColors.gold,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
