import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../match/live_scoring_screen.dart';

class MySportsScreen extends StatefulWidget {
  const MySportsScreen({super.key});

  @override
  State<MySportsScreen> createState() => _MySportsScreenState();
}

class _MySportsScreenState extends State<MySportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SportType? _selectedSportFilter; // null = ALL

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().syncMatchesFromSupabase().catchError((_) {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PreviousMatchModel> _getFilteredPreviousMatches(List<PreviousMatchModel> matches) {
    if (_selectedSportFilter == null) return matches;
    return matches.where((m) => m.sport == _selectedSportFilter).toList();
  }

  List<MatchModel> _getFilteredUpcomingMatches(List<MatchModel> upcoming) {
    if (_selectedSportFilter == null) return upcoming;
    return upcoming.where((m) => m.sport == _selectedSportFilter).toList();
  }

  List<MatchModel> _getFilteredLiveMatches(List<MatchModel> liveMatches) {
    if (_selectedSportFilter == null) return liveMatches;
    return liveMatches
        .where((m) => m.sport == _selectedSportFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    // Only show matches where the real user is added as a player or participant
    final allLive = appState.liveMatches;
    final userLive = allLive.where((m) => appState.isUserInMatch(m, user)).toList();
    final filteredLive = _getFilteredLiveMatches(userLive);

    final userPrevious = appState.getUserPreviousMatches(user);
    final filteredPrevious = _getFilteredPreviousMatches(userPrevious);

    final allUpcoming = appState.upcomingMatches;
    final userUpcoming = allUpcoming.where((m) => appState.isUserInMatch(m, user)).toList();
    final filteredUpcoming = _getFilteredUpcomingMatches(userUpcoming);

    int statsPlayed = 0;
    int statsWins = 0;
    if (user != null) {
      for (final s in user.stats.values) {
        statsPlayed += s.matchesPlayed;
        statsWins += s.wins;
      }
    }
    final totalPlayed = math.max(statsPlayed, userPrevious.length);
    final totalWins = math.max(statsWins, userPrevious.where((m) => m.isWin).length);
    final totalUpcoming = userUpcoming.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top My Sports Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'My Sports',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Performance Overview Metric Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
                  
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MetricItem(
                      label: 'PLAYED',
                      value: '$totalPlayed',
                      color: AppColors.primary,
                      icon: Icons.history_rounded,
                    ),
                    Container(width: 1, height: 28, color: AppColors.surfaceLighter),
                    _MetricItem(
                      label: 'WINS',
                      value: '$totalWins',
                      color: AppColors.cricket,
                      icon: Icons.emoji_events_outlined,
                    ),
                    Container(width: 1, height: 28, color: AppColors.surfaceLighter),
                    _MetricItem(
                      label: 'UPCOMING',
                      value: '$totalUpcoming',
                      color: AppColors.secondary,
                      icon: Icons.event_available_rounded,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sport Filter Pills (Base White/Theme unclicked, dynamic sport color clicked!)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _SportFilterPill(
                    label: 'ALL SPORTS',
                    isSelected: _selectedSportFilter == null,
                    icon: Icons.dashboard_outlined,
                    activeColor: AppColors.primary,
                    onTap: () {
                      setState(() {
                        _selectedSportFilter = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _SportFilterPill(
                    label: 'CRICKET',
                    isSelected: _selectedSportFilter == SportType.cricket,
                    icon: Icons.sports_cricket_rounded,
                    activeColor: AppColors.cricket,
                    onTap: () {
                      setState(() {
                        _selectedSportFilter = _selectedSportFilter == SportType.cricket
                            ? null
                            : SportType.cricket;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _SportFilterPill(
                    label: 'FOOTBALL',
                    isSelected: _selectedSportFilter == SportType.football,
                    icon: Icons.sports_soccer_rounded,
                    activeColor: AppColors.football,
                    onTap: () {
                      setState(() {
                        _selectedSportFilter = _selectedSportFilter == SportType.football
                            ? null
                            : SportType.football;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _SportFilterPill(
                    label: 'BASKETBALL',
                    isSelected: _selectedSportFilter == SportType.basketball,
                    icon: Icons.sports_basketball_rounded,
                    activeColor: AppColors.basketball,
                    onTap: () {
                      setState(() {
                        _selectedSportFilter = _selectedSportFilter == SportType.basketball
                            ? null
                            : SportType.basketball;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _SportFilterPill(
                    label: 'TENNIS',
                    isSelected: _selectedSportFilter == SportType.tennis,
                    icon: Icons.sports_tennis_rounded,
                    activeColor: AppColors.tennis,
                    onTap: () {
                      setState(() {
                        _selectedSportFilter = _selectedSportFilter == SportType.tennis
                            ? null
                            : SportType.tennis;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3 Match Segments Tab Bar (Compact height: 32px - less than half of original)
            Container(
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelPadding: EdgeInsets.zero,
                labelStyle: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(
                    text: 'UPCOMING (${filteredUpcoming.length})',
                  ),
                  Tab(
                    text: 'PREVIOUS (${filteredPrevious.length})',
                  ),
                  Tab(
                    text: 'LIVE (${filteredLive.length})',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Tab Views: Upcoming, Previous, Live
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<AppState>().syncMatchesFromSupabase().catchError((_) {});
                },
                color: AppColors.primary,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Upcoming Matches
                    _UpcomingMatchesView(
                      matches: filteredUpcoming,
                      onClearFilter: () => setState(() => _selectedSportFilter = null),
                    ),

                    // Tab 2: Previous Matches
                    _PreviousMatchesView(
                      matches: filteredPrevious,
                      onClearFilter: () => setState(() => _selectedSportFilter = null),
                    ),

                    // Tab 3: Live Arena
                    _LiveMatchesView(
                      matches: filteredLive,
                      onClearFilter: () => setState(() => _selectedSportFilter = null),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Metric Item ──────────────────────────────────────────────────────────────

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppColors.textMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ─── Sport Filter Pill (White theme unclicked, Sport color clicked) ───────────

class _SportFilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final Color activeColor;
  final VoidCallback onTap;

  const _SportFilterPill({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Upcoming Matches View ─────────────────────────────────────────────

class _UpcomingMatchesView extends StatelessWidget {
  final List<MatchModel> matches;
  final VoidCallback onClearFilter;

  const _UpcomingMatchesView({
    required this.matches,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return _EmptyMatchesState(
        title: 'No Upcoming Matches',
        message: 'No upcoming scheduled fixtures for the selected sport filter.',
        onReset: onClearFilter,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _UpcomingMatchFixtureCard(match: matches[index]),
        );
      },
    );
  }
}

class _UpcomingMatchFixtureCard extends StatelessWidget {
  final MatchModel match;

  const _UpcomingMatchFixtureCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(match.sport.name);
    final formattedDate = DateFormat('EEE, d MMM • HH:mm').format(match.dateTime);

    return BouncingTap(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            content: Text(
              'Fixture: ${match.team1Name} vs ${match.team2Name} at ${match.venue}',
              style: GoogleFonts.outfit(color: AppColors.textPrimary),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          
        ),
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                border: Border(bottom: BorderSide(color: AppColors.surfaceLighter)),
              ),
              child: Row(
                children: [
                  SportBadge(sport: match.sport, showLabel: true, size: 20),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: GoogleFonts.outfit(
                            color: AppColors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Teams Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Team 1
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: sportColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(color: sportColor.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                match.team1Short,
                                style: GoogleFonts.outfit(
                                  color: sportColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              match.team1Name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // VS Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLighter,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'VS',
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      // Team 2
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                match.team2Short,
                                style: GoogleFonts.outfit(
                                  color: AppColors.secondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              match.team2Name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Venue & Squad Check-in
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 14),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            match.venue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cricket.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.cricket, size: 11),
                              const SizedBox(width: 3),
                              Text(
                                'IN SQUAD',
                                style: GoogleFonts.outfit(
                                  color: AppColors.cricket,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 2: Previous Matches View ─────────────────────────────────────────────

class _PreviousMatchesView extends StatelessWidget {
  final List<PreviousMatchModel> matches;
  final VoidCallback onClearFilter;

  const _PreviousMatchesView({
    required this.matches,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return _EmptyMatchesState(
        title: 'No Completed Matches',
        message: 'No match history found under this sports filter.',
        onReset: onClearFilter,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _PreviousMatchCard(match: matches[index]),
        );
      },
    );
  }
}

class _PreviousMatchCard extends StatelessWidget {
  final PreviousMatchModel match;

  const _PreviousMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMM yyyy').format(match.date);
    final winColor = match.isWin ? AppColors.cricket : AppColors.error;

    return BouncingTap(
      onTap: () {
        final appState = context.read<AppState>();
        MatchModel? matchModel;
        try {
          matchModel = appState.allMatches.firstWhere((m) => m.id == match.id);
        } catch (_) {}

        if (matchModel != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LiveScoringScreen(match: matchModel!),
            ),
          );
        } else {
          final tempMatch = MatchModel(
            id: match.id,
            sport: match.sport,
            team1Id: 't1',
            team2Id: 't2',
            team1Name: match.team1Name,
            team2Name: match.team2Name,
            team1Short: match.team1Short,
            team2Short: match.team2Short,
            dateTime: match.date,
            venue: match.venue,
            status: MatchStatus.completed,
            resultText: match.resultText,
            scoreData: match.rawScoreData ?? {
              'team1_score': match.team1Score,
              'team2_score': match.team2Score,
              'status_text': match.resultText,
              'mvp_player': match.mvpPlayer,
            },
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LiveScoringScreen(match: tempMatch),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: match.isWin ? AppColors.cricket.withValues(alpha: 0.25) : AppColors.cardBorder,
            width: match.isWin ? 1.3 : 1.0,
          ),
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Banner Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: winColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                border: Border(bottom: BorderSide(color: winColor.withValues(alpha: 0.15))),
              ),
              child: Row(
                children: [
                  SportBadge(sport: match.sport, showLabel: true, size: 20),
                  const Spacer(),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: winColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            match.isWin ? Icons.emoji_events_rounded : Icons.flag_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              match.resultText.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            ),

            // Match Scoreboard
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Scores in Column Way
                  Row(
                    children: [
                      TeamCrest(
                        shortName: match.team1Short,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.team1Name,
                          style: GoogleFonts.outfit(
                            color: match.isWin ? AppColors.textPrimary : const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: match.isWin ? FontWeight.w900 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        match.team1Score,
                        style: GoogleFonts.outfit(
                          color: match.isWin ? AppColors.textPrimary : const Color(0xFF64748B),
                          fontSize: 16.5,
                          fontWeight: match.isWin ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TeamCrest(
                        shortName: match.team2Short,
                        color: AppColors.sportAccentColor(match.sport.name),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.team2Name,
                          style: GoogleFonts.outfit(
                            color: !match.isWin ? AppColors.textPrimary : const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: !match.isWin ? FontWeight.w900 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        match.team2Score,
                        style: GoogleFonts.outfit(
                          color: !match.isWin ? AppColors.textPrimary : const Color(0xFF64748B),
                          fontSize: 16.5,
                          fontWeight: !match.isWin ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Athlete Performance Spotlight Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOUR PERFORMANCE',
                                style: GoogleFonts.outfit(
                                  color: AppColors.primary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Text(
                                match.myPerformance,
                                style: GoogleFonts.outfit(
                                  color: AppColors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (match.mvpPlayer != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  'MVP',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.gold,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Date and Venue footer
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 12),
                      const SizedBox(width: 3),
                      Expanded(
                        flex: 0,
                        child: Text(
                          match.venue,
                          style: GoogleFonts.outfit(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 3: Live Matches Arena View ───────────────────────────────────────────

class _LiveMatchesView extends StatelessWidget {
  final List<MatchModel> matches;
  final VoidCallback onClearFilter;

  const _LiveMatchesView({
    required this.matches,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return _EmptyMatchesState(
        title: 'No Live Matches Active',
        message: 'There are no live games in progress for the selected filter right now.',
        onReset: onClearFilter,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _LiveMatchArenaCard(match: matches[index]),
        );
      },
    );
  }
}

class _LiveMatchArenaCard extends StatelessWidget {
  final MatchModel match;

  const _LiveMatchArenaCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final score1 = (match.scoreData is Map ? (match.scoreData as Map)['team1_score'] : null)?.toString() ?? '0';
    final score2 = (match.scoreData is Map ? (match.scoreData as Map)['team2_score'] : null)?.toString() ?? '0';
    final statusDetail = (match.scoreData is Map ? (match.scoreData as Map)['status_text'] : null)?.toString() ?? 'In Play';

    return BouncingTap(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LiveScoringScreen(match: match),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.live.withValues(alpha: 0.3), width: 1.5),
          
        ),
        child: Column(
          children: [
            // Live Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.live.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  SportBadge(sport: match.sport, showLabel: true, size: 20),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.live,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE ARENA',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Live Score Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Team 1 Row
                  Row(
                    children: [
                      TeamCrest(
                        shortName: match.team1Short,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.team1Name,
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        score1,
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Team 2 Row
                  Row(
                    children: [
                      TeamCrest(
                        shortName: match.team2Short,
                        color: AppColors.sportAccentColor(match.sport.name),
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.team2Name,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF64748B),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        score2,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Live Broadcast Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sensors_rounded, color: AppColors.live, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${match.venue} • $statusDetail',
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.textMuted, size: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty Matches State ──────────────────────────────────────────────────────

class _EmptyMatchesState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onReset;

  const _EmptyMatchesState({
    required this.title,
    required this.message,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textMuted,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 18),
            BouncingTap(
              onTap: onReset,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLighter,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'SHOW ALL SPORTS',
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
