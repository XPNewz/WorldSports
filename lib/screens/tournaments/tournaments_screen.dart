import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../widgets/common_widgets.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CHAMPIONSHIP ARENA & PRIZE POOLS',
                              style: GoogleFonts.outfit(
                                color: AppColors.gold,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tournaments',
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.championshipGradient,
                      borderRadius: BorderRadius.circular(12),
                      
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Colors.black, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'HOST CUP',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Bar
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
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'LIVE & ONGOING'),
                  Tab(text: 'UPCOMING CUPS'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TournamentList(
                    tournaments: MockData.tournaments
                        .where((t) => t.status == MatchStatus.live)
                        .toList(),
                  ),
                  _TournamentList(
                    tournaments: MockData.tournaments
                        .where((t) => t.status == MatchStatus.upcoming)
                        .toList(),
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

class _TournamentList extends StatelessWidget {
  final List<TournamentModel> tournaments;

  const _TournamentList({required this.tournaments});

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_outlined,
                color: AppColors.textMuted, size: 56),
            const SizedBox(height: 12),
            Text(
              'No active cups right now',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: tournaments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) => TournamentCard(tournament: tournaments[i]),
    );
  }
}

class TournamentCard extends StatelessWidget {
  final TournamentModel tournament;

  const TournamentCard({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.sportGradient(tournament.sport.name);
    final sportColor = AppColors.sportColor(tournament.sport.name);
    final dateFormat = DateFormat('dd MMM');
    final isLive = tournament.status == MatchStatus.live;

    return GestureDetector(
      onTap: () => _showTournamentDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: sportColor.withValues(alpha: isLive ? 0.45 : 0.25),
            width: 1.2,
          ),
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Top with Stadium Gradient
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SportBadge(sport: tournament.sport, showLabel: true, size: 24),
                            const SizedBox(width: 8),
                            if (tournament.prizePool.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.emoji_events_rounded,
                                        color: AppColors.gold, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      tournament.prizePool,
                                      style: GoogleFonts.outfit(
                                        color: AppColors.gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tournament.name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isLive)
                    const LiveIndicator(label: 'LIVE CUP')
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Text(
                        'UPCOMING',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info Row
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        tournament.location,
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_month_outlined,
                          color: AppColors.textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(tournament.startDate)} - ${dateFormat.format(tournament.endDate)}',
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Slots Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SQUAD SLOTS: ${tournament.teamsCount} REGISTERED',
                            style: GoogleFonts.outfit(
                              color: AppColors.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'FORMAT: ${tournament.format.toUpperCase()}',
                            style: GoogleFonts.outfit(
                              color: sportColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 6,
                          color: AppColors.surfaceLighter,
                          child: FractionallySizedBox(
                            widthFactor: isLive ? 1.0 : 0.75,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: gradient,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.surfaceLighter, height: 1),
                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Text(
                        isLive ? 'Knockout Stages Live' : 'Open Registration',
                        style: GoogleFonts.outfit(
                          color: isLive ? AppColors.live : AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(10),
                          
                        ),
                        child: Row(
                          children: [
                            Text(
                              isLive ? 'VIEW BRACKET' : 'REGISTER NOW',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
                          ],
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

  void _showTournamentDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TournamentDetailSheet(tournament: tournament),
    );
  }
}

// ─── Tournament Detail Bottom Sheet ──────────────────────────────────────────

class TournamentDetailSheet extends StatelessWidget {
  final TournamentModel tournament;

  const TournamentDetailSheet({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.sportGradient(tournament.sport.name);
    final sportColor = AppColors.sportColor(tournament.sport.name);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SportBadge(sport: tournament.sport, showLabel: true, size: 28),
                    if (tournament.prizePool.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Text(
                          tournament.prizePool,
                          style: GoogleFonts.outfit(
                            color: AppColors.gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tournament.name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      tournament.location,
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              StatCard(
                label: 'Squads',
                value: '${tournament.teamsCount}',
                icon: Icons.groups_rounded,
                color: sportColor,
              ),
              StatCard(
                label: 'Format',
                value: tournament.format,
                icon: Icons.format_list_bulleted_rounded,
                color: AppColors.secondary,
              ),
              StatCard(
                label: 'Prize Pool',
                value: tournament.prizePool.isNotEmpty
                    ? tournament.prizePool
                    : 'TBD',
                icon: Icons.emoji_events_rounded,
                color: AppColors.gold,
              ),
              StatCard(
                label: 'Status',
                value: tournament.status == MatchStatus.live ? 'LIVE' : 'Open',
                icon: Icons.flash_on_rounded,
                color: tournament.status == MatchStatus.live
                    ? AppColors.live
                    : AppColors.secondary,
              ),
            ],
          ),

          const SizedBox(height: 20),

          SectionHeader(
            title: 'Bracket Matchups',
            accentColor: sportColor,
          ),
          const SizedBox(height: 12),

          ...MockData.liveMatches
              .where((m) => m.sport == tournament.sport)
              .map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      borderColor: sportColor.withValues(alpha: 0.3),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              TeamCrest(shortName: m.team1Short, color: sportColor, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  m.team1Name,
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                m.scoreData != null ? '${(m.scoreData as Map)['team1_score'] ?? '-'}' : '-',
                                style: GoogleFonts.outfit(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              TeamCrest(shortName: m.team2Short, color: AppColors.sportAccentColor(m.sport.name), size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  m.team2Name,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                m.scoreData != null ? '${(m.scoreData as Map)['team2_score'] ?? '-'}' : '-',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),

          const SizedBox(height: 24),

          GradientButton(
            label: 'Register Squad Roster',
            gradient: gradient,
            width: double.infinity,
            icon: Icons.app_registration_rounded,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.surfaceLight,
                  content: Text(
                    'Squad roster submitted for ${tournament.name}!',
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
