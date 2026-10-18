import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../widgets/common_widgets.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ATHLETE ROSTERS & CLUBS',
                              style: GoogleFonts.outfit(
                                color: AppColors.secondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Teams & Clubs',
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
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceLight,
                          content: Text(
                            'Create Team Modal: Setup new squad & jersey colors',
                            style: GoogleFonts.outfit(color: AppColors.textPrimary),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'NEW SQUAD',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
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
                  Tab(text: 'MY SQUADS'),
                  Tab(text: 'CLUBS'),
                  Tab(text: 'DISCOVER'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MyTeamsTab(),
                  _ClubsTab(),
                  _DiscoverTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyTeamsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      children: [
        // Stadium Stats Banner (Multicolor Glow)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surfaceLight,
                AppColors.cardBg,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
            
          ),
          child: Row(
            children: [
              Expanded(
                child: _QuickStat(
                  label: 'ACTIVE SQUADS',
                  value: '${MockData.teams.length}',
                  color: AppColors.primary,
                  icon: Icons.shield_rounded,
                ),
              ),
              Container(width: 1, height: 48, color: AppColors.surfaceLighter),
              Expanded(
                child: _QuickStat(
                  label: 'CLUBS JOINED',
                  value: '${MockData.clubs.length}',
                  color: AppColors.secondary,
                  icon: Icons.groups_rounded,
                ),
              ),
              Container(width: 1, height: 48, color: AppColors.surfaceLighter),
              Expanded(
                child: _QuickStat(
                  label: 'MULTI-SPORTS',
                  value: '3',
                  color: AppColors.gold,
                  icon: Icons.sports_tennis_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SectionHeader(
          title: 'Squad Roster',
          accentColor: AppColors.secondary,
          actionLabel: 'Manage All',
          onAction: () {},
        ),
        const SizedBox(height: 12),

        ...MockData.teams.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TeamCard(team: t),
            )),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppColors.textMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamModel team;

  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(team.sport.name);
    final winRate = team.totalMatches > 0
        ? (team.wins / team.totalMatches * 100).toStringAsFixed(0)
        : '0';

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: sportColor.withValues(alpha: 0.35),
      child: Column(
        children: [
          Row(
            children: [
              TeamCrest(
                shortName: team.shortName,
                color: sportColor,
                size: 54,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            team.name,
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppColors.fireGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                '3 WIN STREAK',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SportBadge(sport: team.sport, showLabel: true, size: 24),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.textMuted, size: 13),
                        const SizedBox(width: 2),
                        Text(
                          team.location,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceLighter, height: 1),
          const SizedBox(height: 12),

          // Match Record Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MatchStat('WINS', '${team.wins}', AppColors.success),
              _MatchStat('DRAWS', '${team.draws}', AppColors.textSecondary),
              _MatchStat('LOSSES', '${team.losses}', AppColors.error),
              _MatchStat('MATCHES', '${team.totalMatches}', AppColors.textPrimary),
              _MatchStat('WIN RATE', '$winRate%', sportColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MatchStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Clubs Tab ────────────────────────────────────────────────────────────────

class _ClubsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: MockData.clubs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _ClubCard(club: MockData.clubs[i]),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final ClubModel club;

  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.textMuted, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          club.location,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Est. ${club.established}',
                          style: GoogleFonts.outfit(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: AppColors.multiColorGradient,
                  borderRadius: BorderRadius.circular(10),
                  
                ),
                child: Text(
                  'JOIN',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            club.description,
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: club.sports
                .map((s) => SportBadge(sport: s, showLabel: true, size: 26))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Discover Tab ─────────────────────────────────────────────────────────────

class _DiscoverTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      children: [
        SectionHeader(
          title: 'Federations & Councils',
          accentColor: AppColors.gold,
        ),
        const SizedBox(height: 12),
        const _AssociationCard(
          name: 'India Multi-Sports Federation',
          sports: [SportType.cricket, SportType.football, SportType.basketball, SportType.tennis],
          members: 48200,
          clubs: 312,
        ),
        const SizedBox(height: 10),
        const _AssociationCard(
          name: 'South Asia Sports Council',
          sports: [SportType.cricket, SportType.football],
          members: 22800,
          clubs: 148,
        ),
        const SizedBox(height: 10),
        const _AssociationCard(
          name: 'Pan-India Basketball Association',
          sports: [SportType.basketball],
          members: 8400,
          clubs: 64,
        ),
        const SizedBox(height: 24),

        SectionHeader(
          title: 'Top Local Athletes',
          accentColor: AppColors.primary,
        ),
        const SizedBox(height: 12),
        const _NearbyPlayerCard(
          name: 'Vikas Kumar',
          sports: [SportType.cricket, SportType.football],
          location: '2.1 km away',
          rating: 4.8,
        ),
        const SizedBox(height: 10),
        const _NearbyPlayerCard(
          name: 'Sneha Rao',
          sports: [SportType.tennis, SportType.basketball],
          location: '3.8 km away',
          rating: 4.6,
        ),
        const SizedBox(height: 10),
        const _NearbyPlayerCard(
          name: 'Aditya Bose',
          sports: [SportType.cricket],
          location: '5.0 km away',
          rating: 4.4,
        ),
      ],
    );
  }
}

class _AssociationCard extends StatelessWidget {
  final String name;
  final List<SportType> sports;
  final int members;
  final int clubs;

  const _AssociationCard({
    required this.name,
    required this.sports,
    required this.members,
    required this.clubs,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.gold.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.championshipGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${(members / 1000).toStringAsFixed(0)}K members',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$clubs clubs',
                      style: GoogleFonts.outfit(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: sports
                      .map((s) => SportBadge(sport: s, showLabel: false, size: 24))
                      .toList(),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _NearbyPlayerCard extends StatelessWidget {
  final String name;
  final List<SportType> sports;
  final String location;
  final double rating;

  const _NearbyPlayerCard({
    required this.name,
    required this.sports,
    required this.location,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.primary.withValues(alpha: 0.25),
      child: Row(
        children: [
          UserAvatar(name: name, radius: 22, showProRing: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textMuted, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      location,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: sports
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: SportBadge(sport: s, showLabel: false, size: 22),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                  const SizedBox(width: 3),
                  Text(
                    '$rating',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'CHALLENGE',
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
