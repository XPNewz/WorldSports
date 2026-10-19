import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/services/ad_service.dart';
import '../../widgets/common_widgets.dart';
import '../match/match_creation_screen.dart';
import '../match/live_scoring_screen.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['LIVE ARENA', 'UPCOMING', 'RESULTS'];
  SportType? _selectedSport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Arena Scores Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.live,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'GLOBAL MULTI-SPORT JUMBOTRON',
                              style: GoogleFonts.outfit(
                                color: AppColors.live,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Live Scores',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.fireGradient,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${context.watch<AppState>().liveMatches.length} ACTIVE',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  BouncingTap(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreateMatchScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'START MATCH',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Sport filter tabs (Multicolor Pills)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _SportFilterChip(
                    label: 'ALL SPORTS',
                    icon: Icons.sports_rounded,
                    isSelected: _selectedSport == null,
                    color: AppColors.primary,
                    onTap: () => setState(() => _selectedSport = null),
                  ),
                  const SizedBox(width: 8),
                  ...SportType.values.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _SportFilterChip(
                        label: s.name.toUpperCase(),
                        icon: _sportIcon(s),
                        isSelected: _selectedSport == s,
                        color: AppColors.sportColor(s.name),
                        onTap: () => setState(() => _selectedSport = s),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status Tabs (Live, Upcoming, Results)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceLighter),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _LiveTab(selectedSport: _selectedSport),
                  _UpcomingTab(selectedSport: _selectedSport),
                  _ResultsTab(selectedSport: _selectedSport),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _sportIcon(SportType s) {
    switch (s) {
      case SportType.cricket:
        return Icons.sports_cricket_rounded;
      case SportType.football:
        return Icons.sports_soccer_rounded;
      case SportType.basketball:
        return Icons.sports_basketball_rounded;
      case SportType.tennis:
        return Icons.sports_tennis_rounded;
    }
  }
}

class _SportFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SportFilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? color : AppColors.surfaceLighter,
            width: isSelected ? 1.5 : 1,
          ),
          
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Live Tab ─────────────────────────────────────────────────────────────────

class _LiveTab extends StatelessWidget {
  final SportType? selectedSport;

  const _LiveTab({this.selectedSport});

  @override
  Widget build(BuildContext context) {
    final live = context.watch<AppState>().liveMatches;
    final matches = selectedSport == null
        ? live
        : live.where((m) => m.sport == selectedSport).toList();

    final sponsorAd = AdService.getScoreboardSponsor(sport: selectedSport);

    if (matches.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
            child: _ScoreboardSponsorBanner(ad: sponsorAd),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sports_rounded, color: AppColors.textMuted, size: 54),
                  const SizedBox(height: 12),
                  Text(
                    'No live matches in this sport right now',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      itemCount: matches.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ScoreboardSponsorBanner(ad: sponsorAd),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _JumbotronMatchCard(match: matches[i - 1]),
        );
      },
    );
  }
}

// ─── Upcoming Tab ─────────────────────────────────────────────────────────────

class _UpcomingTab extends StatelessWidget {
  final SportType? selectedSport;

  const _UpcomingTab({this.selectedSport});

  @override
  Widget build(BuildContext context) {
    final matches = selectedSport == null
        ? MockData.upcomingMatches
        : MockData.upcomingMatches.where((m) => m.sport == selectedSport).toList();

    final bannerAd = AdService.getBannerAd(sport: selectedSport);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      itemCount: matches.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ScoreboardSponsorBanner(ad: bannerAd),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _JumbotronMatchCard(match: matches[i - 1]),
        );
      },
    );
  }
}

// ─── Results Tab ──────────────────────────────────────────────────────────────

class _ResultsTab extends StatelessWidget {
  final SportType? selectedSport;

  const _ResultsTab({this.selectedSport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceLighter),
            ),
            child: const Icon(Icons.history_edu_rounded,
                color: AppColors.gold, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'CHAMPIONSHIP ARCHIVES',
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Past match scores and trophy records will be synced here',
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Jumbotron Full Match Card ────────────────────────────────────────────────

class _JumbotronMatchCard extends StatelessWidget {
  final MatchModel match;

  const _JumbotronMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(match.sport.name);
    final isLive = match.status == MatchStatus.live;
    final score = match.scoreData as Map<String, dynamic>?;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: sportColor.withValues(alpha: isLive ? 0.45 : 0.25),
      child: Column(
        children: [
          // Header with League & Status
          Row(
            children: [
              SportBadge(sport: match.sport, showLabel: true, size: 28),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ARENA LEAGUE',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              if (isLive)
                const LiveIndicator(label: 'LIVE')
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.surfaceLighter),
                  ),
                  child: Text(
                    'UPCOMING',
                    style: GoogleFonts.outfit(
                      color: AppColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Teams & Scoreboard Jumbotron in Column Layout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLighter),
            ),
            child: Column(
              children: [
                // Team 1 Row
                Row(
                  children: [
                    TeamCrest(
                      shortName: match.team1Short,
                      color: sportColor,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.team1Name,
                            style: GoogleFonts.outfit(
                              color: isLive ? AppColors.textPrimary : const Color(0xFF64748B),
                              fontSize: 15.5,
                              fontWeight: isLive ? FontWeight.w900 : FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          _renderTeamForm(true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _getTeamScore(score, match.sport, 1),
                            style: GoogleFonts.outfit(
                              color: isLive ? AppColors.textPrimary : const Color(0xFF64748B),
                              fontSize: 18,
                              fontWeight: isLive ? FontWeight.w900 : FontWeight.w600,
                            ),
                          ),
                          if (_getTeamOvers(score, match.sport, 1) != null) ...[
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: '(${_getTeamOvers(score, match.sport, 1)})',
                              style: GoogleFonts.outfit(
                                color: isLive ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.surfaceLighter, height: 1),
                const SizedBox(height: 12),

                // Team 2 Row
                Row(
                  children: [
                    TeamCrest(
                      shortName: match.team2Short,
                      color: AppColors.sportAccentColor(match.sport.name),
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.team2Name,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF64748B),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          _renderTeamForm(false),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _getTeamScore(score, match.sport, 2),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF64748B),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_getTeamOvers(score, match.sport, 2) != null) ...[
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: '(${_getTeamOvers(score, match.sport, 2)})',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sport-specific details breakdown
          if (score != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLighter.withValues(alpha: 0.6)),
              ),
              child: _renderSportDetails(score, match.sport, sportColor),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(color: AppColors.surfaceLighter, height: 1),
          const SizedBox(height: 12),

          // Bottom Bar: Venue & Action Button
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  match.venue.isEmpty ? 'Arena Stadium' : match.venue,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BouncingTap(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LiveScoringScreen(match: match),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.sportGradient(match.sport.name),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'SCORECARD',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderTeamForm(bool isTeam1) {
    final form = isTeam1 ? ['W', 'W', 'L', 'W'] : ['L', 'W', 'W', 'L'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: form.map((res) {
        final isWin = res == 'W';
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isWin ? AppColors.success.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isWin ? AppColors.success : AppColors.error,
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            res,
            style: GoogleFonts.outfit(
              color: isWin ? AppColors.success : AppColors.error,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _renderSportDetails(
      Map<String, dynamic> score, SportType sport, Color sportColor) {
    if (sport == SportType.cricket) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overs: ${score['team1_overs'] ?? '-'}',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                score['status_text'] ?? '',
                style: GoogleFonts.outfit(
                  color: AppColors.secondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (score['current_batsmen'] != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.sports_cricket, color: AppColors.cricket, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Batting: ${(score['current_batsmen'] as List).join(', ')}',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    } else if (sport == SportType.football) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.football, size: 14),
              const SizedBox(width: 4),
              Text(
                '${score['minute'] ?? 67}\' MINUTE',
                style: GoogleFonts.outfit(
                  color: AppColors.football,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            score['status_text'] ?? 'Match in play',
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score['status_text'] ?? 'Game in progress',
            style: GoogleFonts.outfit(
              color: sportColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }
  }

  String _getTeamScore(Map<String, dynamic>? score, SportType sport, int teamNum) {
    if (score == null) return '-';
    final isTeam1 = teamNum == 1;
    if (sport == SportType.cricket) {
      return isTeam1 ? (score['team1_score'] ?? '-') : (score['team2_score'] ?? '-');
    }
    return isTeam1
        ? '${score['team1_score'] ?? '-'}'
        : '${score['team2_score'] ?? '-'}';
  }

  String? _getTeamOvers(Map<String, dynamic>? score, SportType sport, int teamNum) {
    if (score == null) return null;
    if (sport == SportType.cricket) {
      final key = teamNum == 1 ? 'team1_overs' : 'team2_overs';
      final val = score[key];
      if (val != null && val.toString().isNotEmpty) return val.toString();
    }
    return null;
  }
}

// ─── Scoreboard Sponsor Ad Banner ─────────────────────────────────────────────

class _ScoreboardSponsorBanner extends StatelessWidget {
  final AdModel ad;

  const _ScoreboardSponsorBanner({required this.ad});

  @override
  Widget build(BuildContext context) {
    AdService.recordImpression(ad.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: const [AppColors.cellShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => AdService.showAdDetailsModal(context, ad),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'MATCH DAY SPONSOR',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFD97706),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ad.promoCode != null ? 'CODE: ${ad.promoCode}' : 'OFFICIAL PERK',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFB45309),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ad.advertiserName} • ${ad.headline}',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ad.ctaText,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_outward_rounded, size: 11, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

