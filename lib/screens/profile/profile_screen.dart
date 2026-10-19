import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../../core/services/supabase_service.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SportType? _selectedSkillSport; // null = all sports skills

  List<SportSkillModel> get _filteredSkills {
    if (_selectedSkillSport == null) return MockData.athleteSkills;
    return MockData.athleteSkills
        .where((s) => s.sport == _selectedSkillSport)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser ?? MockData.demoPlayer;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── 1. Athlete Pro Passport Header ────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.surfaceLighter,
                    width: 1,
                  ),
                ),
                
              ),
              child: Column(
                children: [
                  // IN-APP NOTIFICATION BANNER (When profile incomplete)
                  if (!user.hasCompletedProfile && user.role != UserRole.umpire)
                    _buildInAppNotificationBanner(context, user),

                  // Top Title & Settings Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ATHLETE PASSPORT',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          BouncingTap(
                            onTap: () => _showSpecializationSheet(context, user),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.tune_rounded, color: AppColors.primary, size: 12),
                                  const SizedBox(width: 3),
                                  Text(
                                    'SPECS',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  '88 OVR • ELITE',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          BouncingTap(
                            onTap: () => _showHelpSupportModal(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
boxShadow: const [AppColors.cellShadowSmall],
                              ),
                              child: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BouncingTap(
                            onTap: () => _showSettingsModal(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
boxShadow: const [AppColors.cellShadowSmall],
                              ),
                              child: const Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Avatar & Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          UserAvatar(
                            name: user.name,
                            radius: 38,
                            showProRing: true,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                gradient: AppColors.fireGradient,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.bg, width: 2),
                              ),
                              child: const Icon(Icons.bolt_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name,
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.verified_rounded,
                                    color: AppColors.primary, size: 20),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${user.username}',
                              style: GoogleFonts.outfit(
                                color: AppColors.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _RoleBadge(role: user.role),
                                const SizedBox(width: 8),
                                const Icon(Icons.location_on_outlined,
                                    color: AppColors.textMuted, size: 13),
                                const SizedBox(width: 2),
                                Text(
                                  user.location,
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (user.role == UserRole.player || user.role == UserRole.coach) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.surfaceLighter),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      user.primarySport == SportType.cricket
                                          ? Icons.sports_cricket_rounded
                                          : user.primarySport == SportType.football
                                              ? Icons.sports_soccer_rounded
                                              : user.primarySport == SportType.basketball
                                                  ? Icons.sports_basketball_rounded
                                                  : Icons.sports_tennis_rounded,
                                      size: 13,
                                      color: AppColors.sportColor(user.primarySport.name),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        user.cricketSpecs != null && user.primarySport == SportType.cricket
                                            ? user.cricketSpecs!.summary
                                            : user.footballSpecs != null && user.primarySport == SportType.football
                                                ? user.footballSpecs!.summary
                                                : user.primaryRole,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Text(
                    user.bio,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Athlete Stats 4-Grid
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceLighter),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _FollowStat(_formatNum(user.followers), 'FOLLOWERS', AppColors.primary),
                        Container(width: 1, height: 32, color: AppColors.surfaceLighter),
                        _FollowStat(_formatNum(user.following), 'FOLLOWING', AppColors.secondary),
                        Container(width: 1, height: 32, color: AppColors.surfaceLighter),
                        _FollowStat('${MockData.previousMatches.length + 42}', 'MATCHES', AppColors.gold),
                        Container(width: 1, height: 32, color: AppColors.surfaceLighter),
                        _FollowStat('${user.sports.length}', 'SPORTS', AppColors.accent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Active sports chips
                  Row(
                    children: user.sports
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SportBadge(sport: s, showLabel: true, size: 26),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // ─── 2. Played Sports Basic Stats & Roles ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: SectionHeader(
                title: 'Played Sports & Performance',
                accentColor: AppColors.primary,
                icon: Icons.sports_score_rounded,
              ),
            ),
          ),

          // Basic Stats Cards for all Played Sports
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = user.stats.entries.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SportProfileCard(
                      sport: entry.key,
                      stats: entry.value,
                      onOpenMore: () => _showDedicatedSportWindow(context, entry.key, entry.value),
                    ),
                  );
                },
                childCount: user.stats.length,
              ),
            ),
          ),

          // ─── 3. Your Skills Across All Sports ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
              child: SectionHeader(
                title: 'Athletic Skills Across All Sports',
                accentColor: AppColors.primary,
                icon: Icons.bolt_rounded,
              ),
            ),
          ),

          // Sport Filter Pills for Skills (Two-tone rule: White unclicked, Sport color clicked)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _SkillSportPill(
                    label: 'ALL SKILLS',
                    isSelected: _selectedSkillSport == null,
                    activeColor: AppColors.primary,
                    icon: Icons.stars_rounded,
                    onTap: () => setState(() => _selectedSkillSport = null),
                  ),
                  const SizedBox(width: 8),
                  _SkillSportPill(
                    label: 'CRICKET',
                    isSelected: _selectedSkillSport == SportType.cricket,
                    activeColor: AppColors.cricket,
                    icon: Icons.sports_cricket_rounded,
                    onTap: () => setState(() => _selectedSkillSport =
                        _selectedSkillSport == SportType.cricket ? null : SportType.cricket),
                  ),
                  const SizedBox(width: 8),
                  _SkillSportPill(
                    label: 'FOOTBALL',
                    isSelected: _selectedSkillSport == SportType.football,
                    activeColor: AppColors.football,
                    icon: Icons.sports_soccer_rounded,
                    onTap: () => setState(() => _selectedSkillSport =
                        _selectedSkillSport == SportType.football ? null : SportType.football),
                  ),
                  const SizedBox(width: 8),
                  _SkillSportPill(
                    label: 'BASKETBALL',
                    isSelected: _selectedSkillSport == SportType.basketball,
                    activeColor: AppColors.basketball,
                    icon: Icons.sports_basketball_rounded,
                    onTap: () => setState(() => _selectedSkillSport =
                        _selectedSkillSport == SportType.basketball ? null : SportType.basketball),
                  ),
                  const SizedBox(width: 8),
                  _SkillSportPill(
                    label: 'TENNIS',
                    isSelected: _selectedSkillSport == SportType.tennis,
                    activeColor: AppColors.tennis,
                    icon: Icons.sports_tennis_rounded,
                    onTap: () => setState(() => _selectedSkillSport =
                        _selectedSkillSport == SportType.tennis ? null : SportType.tennis),
                  ),
                ],
              ),
            ),
          ),

          // Skill Progress Cards Grid / List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final skill = _filteredSkills[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SkillProgressCard(skill: skill),
                  );
                },
                childCount: _filteredSkills.length,
              ),
            ),
          ),

          // ─── 4. Achievements and Awards Showcase ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              child: SectionHeader(
                title: 'Achievements & Awards',
                accentColor: AppColors.gold,
                icon: Icons.workspace_premium_rounded,
              ),
            ),
          ),

          // Certified Honors Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ach = MockData.achievements[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AchievementHonorCard(achievement: ach),
                  );
                },
                childCount: MockData.achievements.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ],
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLighter,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Athlete Preferences & Settings',
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Control account security, sync and sports configuration',
                      style: GoogleFonts.outfit(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingModalRow('Dark / Light System Theme', 'Follows Device Setting', Icons.brightness_6_rounded),
            _buildSettingModalRow('Primary Sport Focus', 'Cricket & Football', Icons.sports_rounded),
            _buildSettingModalRow('Verified GPS Location', 'Mumbai Central, MH', Icons.gps_fixed_rounded),
            _buildSettingModalRow('Automated Scorecard Sync', 'Enabled (Official Clubs)', Icons.cloud_sync_rounded),
            const SizedBox(height: 20),
                        const SizedBox(height: 14),
            BouncingTap(
              onTap: () {
                context.read<AppState>().logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'SIGN OUT OF ARENA',
                      style: GoogleFonts.outfit(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            BouncingTap(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CLOSE SETTINGS',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDedicatedSportWindow(BuildContext context, SportType sport, PlayerStats stats) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _DedicatedSportWindowSheet(sport: sport, stats: stats),
    );
  }

  Widget _buildInAppNotificationBanner(BuildContext context, UserModel user) {
    final percent = user.profileCompletionPercent;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFBEB),
            const Color(0xFFFEF3C7).withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IN-APP ALERT • ATHLETE PROFILE INCOMPLETE ($percent%)',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF92400E),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Set batting/bowling styles or pitch position to qualify for match squads',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFB45309),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFFDE68A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BouncingTap(
                onTap: () => _showSpecializationSheet(context, user),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'COMPLETE SPECS NOW',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
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

  void _showSpecializationSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SpecializationModalSheet(user: user),
    );
  }

  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLighter,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Help & Arena Support',
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '24/7 Official sports officiating & platform guidelines',
                      style: GoogleFonts.outfit(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSupportRow(
              icon: Icons.gavel_rounded,
              title: 'Official Rulebooks & Guidelines',
              description: 'Tournament bylaws for MCA Cricket, Football Turf & Slam Tennis',
            ),
            _buildSupportRow(
              icon: Icons.report_problem_outlined,
              title: 'Scorecard Dispute & Correction',
              description: 'Submit referee verification request for inaccurate match stats',
            ),
            _buildSupportRow(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Live Arena Official Chat',
              description: 'Direct channel with licensed sports commissioners',
            ),
            _buildSupportRow(
              icon: Icons.security_update_good_rounded,
              title: 'Anti-Doping & Fair Play Code',
              description: 'Safety guidelines and player code of conduct',
            ),
            const SizedBox(height: 20),
            BouncingTap(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.white,
                    content: Text(
                      'Connecting to Arena Official Support Desk...',
                      style: GoogleFonts.outfit(color: AppColors.textPrimary),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CONTACT ARENA OFFICIAL',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingModalRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

// ─── Skill Sport Filter Pill (Theme default unclicked, sport color clicked) ───

class _SkillSportPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final IconData icon;
  final VoidCallback onTap;

  const _SkillSportPill({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.icon,
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

// ─── Athletic Skill Progress Card ─────────────────────────────────────────────

class _SkillProgressCard extends StatelessWidget {
  final SportSkillModel skill;

  const _SkillProgressCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(skill.sport.name);
    final pct = skill.score / 100.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
boxShadow: const [AppColors.cellShadowSmall],
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportBadge(sport: skill.sport, showLabel: false, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  skill.skillName,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: sportColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sportColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  skill.tier.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: sportColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${skill.score}',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '/100',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 7,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLighter,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct.clamp(0.0, 1.0),
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: sportColor,
                    borderRadius: BorderRadius.circular(4),
                    
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORY: ${skill.category.toUpperCase()}',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                skill.sport.name.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: sportColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Achievement Honor Card ───────────────────────────────────────────────────

class _AchievementHonorCard extends StatelessWidget {
  final AchievementModel achievement;

  const _AchievementHonorCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(achievement.sport.name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.2),
                  AppColors.gold.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Icon(achievement.icon, color: AppColors.gold, size: 24),
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
                        achievement.title,
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        achievement.year,
                        style: GoogleFonts.outfit(
                          color: AppColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: sportColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${achievement.sport.name.toUpperCase()} CERTIFIED AWARD',
                      style: GoogleFonts.outfit(
                        color: sportColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.description,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers: Role Badge & Follow Stat ─────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final UserRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final Map<UserRole, Map<String, dynamic>> data = {
      UserRole.player: {'label': 'ATHLETE', 'color': AppColors.primary},
      UserRole.coach: {'label': 'COACH', 'color': AppColors.secondary},
      UserRole.organiser: {'label': 'ORGANISER', 'color': AppColors.gold},
      UserRole.umpire: {'label': 'UMPIRE / REFEREE', 'color': const Color(0xFF0EA5E9)},
    };
    final d = data[role] ?? {'label': 'ATHLETE', 'color': AppColors.primary};
    final color = d['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        d['label'] as String,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FollowStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _FollowStat(this.value, this.label, this.color);

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
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Played Sport Basic Profile Card ──────────────────────────────────────────

class _SportProfileCard extends StatelessWidget {
  final SportType sport;
  final PlayerStats stats;
  final VoidCallback onOpenMore;

  const _SportProfileCard({
    required this.sport,
    required this.stats,
    required this.onOpenMore,
  });

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(sport.name);
    final isIndividual = stats.isIndividualSport;
    final primaryRole = stats.primaryRole;
    final roles = stats.rolesData;
    final otherRoleNames = roles.keys
        .where((r) => !primaryRole.toLowerCase().contains(r.toLowerCase()))
        .toList();

    final primaryStats = _resolvePrimaryHighlights(sport, stats);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: sportColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: const [AppColors.cellShadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Sport Badge, Name, Classification & Win Record (only for individual sport)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                SportBadge(sport: sport, showLabel: false, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        isIndividual
                            ? 'Individual Sport • Personal Record'
                            : 'Team Sport • Individual Athlete Stats',
                        style: GoogleFonts.outfit(
                          color: isIndividual ? AppColors.tennis : AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Only individual sports display match wins and win rate!
                // Team sports display athlete matches participated and exclude team win rates.
                if (isIndividual)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tennis.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.tennis.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: AppColors.tennis, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.wins}W - ${stats.losses}L (${(stats.winRate * 100).toStringAsFixed(0)}%)',
                          style: GoogleFonts.outfit(
                            color: AppColors.tennis,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sportColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sportColor.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      '${stats.matchesPlayed} MATCHES',
                      style: GoogleFonts.outfit(
                        color: sportColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Primary Role Banner (Highlighting the main role on profile screen)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceLighter),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: sportColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'MAIN ROLE: ',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          primaryRole.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: sportColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '★ PRIMARY',
                    style: GoogleFonts.outfit(
                      color: sportColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Primary Role Stats 4-Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: primaryStats.map((stat) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceLighter),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stat['value'] ?? '-',
                          style: GoogleFonts.outfit(
                            color: stat['color'] as Color? ?? AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat['label'] ?? '',
                          style: GoogleFonts.outfit(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.surfaceLighter),

          // Bottom Bar: Other Roles Hint & "More Details" Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                if (otherRoleNames.isNotEmpty) ...[
                  const Icon(Icons.layers_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Other Roles: ${otherRoleNames.join(", ")}',
                      style: GoogleFonts.outfit(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                BouncingTap(
                  onTap: onOpenMore,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sportColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sportColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'More Details',
                          style: GoogleFonts.outfit(
                            color: sportColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.north_east_rounded, color: sportColor, size: 13),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Primary Stats Resolver ───────────────────────────────────────────────────

List<Map<String, dynamic>> _resolvePrimaryHighlights(SportType sport, PlayerStats stats) {
  final s = stats.specificStats;
  if (stats.isIndividualSport) {
    return [
      {'label': 'MATCHES', 'value': '${stats.matchesPlayed}', 'color': AppColors.textPrimary},
      {'label': 'WINS', 'value': '${stats.wins}', 'color': AppColors.tennis},
      {'label': 'WIN RATE', 'value': '${(stats.winRate * 100).toStringAsFixed(0)}%', 'color': AppColors.tennis},
      {'label': 'ACES', 'value': '${s['aces'] ?? 142}', 'color': AppColors.secondary},
    ];
  }

  switch (sport) {
    case SportType.cricket:
      return [
        {'label': 'CAREER RUNS', 'value': '${s['runs'] ?? '1,842'}', 'color': AppColors.cricket},
        {'label': 'BATTING AVG', 'value': '${s['batting_avg'] ?? '41.2'}', 'color': AppColors.cricket},
        {'label': 'STRIKE RATE', 'value': '${s['strike_rate'] ?? '138.4'}', 'color': AppColors.primary},
        {'label': '100s / 50s', 'value': '${s['hundreds'] ?? 3}/${s['fifties'] ?? 12}', 'color': AppColors.gold},
      ];
    case SportType.football:
      return [
        {'label': 'ASSISTS', 'value': '${s['assists'] ?? 24}', 'color': AppColors.secondary},
        {'label': 'GOALS', 'value': '${s['goals'] ?? 18}', 'color': AppColors.football},
        {'label': 'PASS ACC', 'value': '${s['pass_accuracy'] ?? '87.4%'}', 'color': AppColors.primary},
        {'label': 'MATCHES', 'value': '${stats.matchesPlayed}', 'color': AppColors.textPrimary},
      ];
    case SportType.basketball:
      return [
        {'label': 'ASSISTS', 'value': '${s['assists'] ?? 63}', 'color': AppColors.primary},
        {'label': 'POINTS', 'value': '${s['points'] ?? 312}', 'color': AppColors.basketball},
        {'label': 'REBOUNDS', 'value': '${s['rebounds'] ?? 87}', 'color': AppColors.secondary},
        {'label': 'STEALS', 'value': '${s['steals'] ?? 28}', 'color': AppColors.accent},
      ];
    case SportType.tennis:
      return [
        {'label': 'MATCHES', 'value': '${stats.matchesPlayed}', 'color': AppColors.textPrimary},
        {'label': 'WINS', 'value': '${stats.wins}', 'color': AppColors.tennis},
        {'label': 'WIN RATE', 'value': '${(stats.winRate * 100).toStringAsFixed(0)}%', 'color': AppColors.tennis},
        {'label': 'ACES', 'value': '${s['aces'] ?? 142}', 'color': AppColors.secondary},
      ];
  }
}

// ─── Dedicated Sport Window Modal Sheet ───────────────────────────────────────

class _DedicatedSportWindowSheet extends StatefulWidget {
  final SportType sport;
  final PlayerStats stats;

  const _DedicatedSportWindowSheet({
    required this.sport,
    required this.stats,
  });

  @override
  State<_DedicatedSportWindowSheet> createState() => _DedicatedSportWindowSheetState();
}

class _DedicatedSportWindowSheetState extends State<_DedicatedSportWindowSheet> {
  late String _selectedRole;
  late List<String> _roleKeys;

  @override
  void initState() {
    super.initState();
    final roles = widget.stats.rolesData;
    _roleKeys = roles.keys.toList();
    if (_roleKeys.isEmpty) {
      _selectedRole = widget.stats.primaryRole;
      _roleKeys = [_selectedRole];
    } else {
      final primary = widget.stats.primaryRole.toLowerCase();
      final match = _roleKeys.firstWhere(
        (r) => primary.contains(r.toLowerCase()) || r.toLowerCase().contains(primary),
        orElse: () => _roleKeys.first,
      );
      _selectedRole = match;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sport = widget.sport;
    final stats = widget.stats;
    final sportColor = AppColors.sportColor(sport.name);
    final isIndividual = stats.isIndividualSport;
    final currentRoleStats = stats.rolesData[_selectedRole] ?? {};

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Modal Top Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 16, 12),
            child: Row(
              children: [
                SportBadge(sport: sport, showLabel: false, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${sport.name.toUpperCase()} ARENA WINDOW',
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sportColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DEDICATED',
                              style: GoogleFonts.outfit(
                                color: sportColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isIndividual
                            ? 'Individual Tournament & Match Records'
                            : 'Athlete Role Specialization & Performance',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                BouncingTap(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceLighter),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceLighter),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Card
                  Container(
                    width: double.infinity,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: sportColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isIndividual ? 'INDIVIDUAL SPORT' : 'TEAM SPORT ATHLETE',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                                const SizedBox(width: 3),
                                Text(
                                  '${stats.rating} / 5.0 RATING',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (isIndividual) ...[
                          Text(
                            '${stats.wins} WINS  •  ${stats.losses} LOSSES',
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Individual Match Win Rate: ${(stats.winRate * 100).toStringAsFixed(1)}% across ${stats.matchesPlayed} competitive fixtures.',
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '${stats.matchesPlayed} Matches Participated',
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Individual athlete performance data. Team win/loss match records are team accomplishments and excluded from personal athlete stats.',
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Role Switcher Header & Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ATHLETE ROLES IN ${sport.name.toUpperCase()}',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Select role to inspect stats',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Role Switcher Pills
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _roleKeys.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final role = _roleKeys[i];
                        final isSelected = role == _selectedRole;
                        final isPrimary = widget.stats.primaryRole.toLowerCase().contains(role.toLowerCase()) ||
                            role.toLowerCase().contains(widget.stats.primaryRole.toLowerCase());

                        return BouncingTap(
                          onTap: () => setState(() => _selectedRole = role),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? sportColor : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? sportColor : AppColors.surfaceLighter,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected ? [AppColors.cellShadowSmall] : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isPrimary) ...[
                                  Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: isSelected ? Colors.white : AppColors.gold,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  isPrimary ? '${role.toUpperCase()} (MAIN)' : role.toUpperCase(),
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
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Current Role Header
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: sportColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_selectedRole In-Depth Performance Stats',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Role Stats Grid
                  if (currentRoleStats.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Text(
                        'No detailed records available for this role.',
                        style: GoogleFonts.outfit(color: AppColors.textMuted),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: currentRoleStats.entries.map((e) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 50) / 2,
                          child: _RoleMetricTile(
                            label: e.key.toUpperCase(),
                            value: '${e.value}',
                            accentColor: sportColor,
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // Official Verification Badge
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceLighter),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Official Arena Scorecard Verified',
                                style: GoogleFonts.outfit(
                                  color: AppColors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'All role metrics are aggregated directly from certified match referee scorecards.',
                                style: GoogleFonts.outfit(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Close button
                  BouncingTap(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLighter,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'CLOSE DEDICATED WINDOW',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Role Metric Tile ─────────────────────────────────────────────────────────

class _RoleMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _RoleMetricTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
        boxShadow: const [AppColors.cellShadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Athletic Specialization Customization Sheet ─────────────────────────────

class _SpecializationModalSheet extends StatefulWidget {
  final UserModel user;
  const _SpecializationModalSheet({required this.user});

  @override
  State<_SpecializationModalSheet> createState() => _SpecializationModalSheetState();
}

class _SpecializationModalSheetState extends State<_SpecializationModalSheet> {
  late SportType _selectedSport;

  // Cricket
  late String _battingHand;
  late String _bowlingArm;
  late String _bowlingCategory;
  late String _bowlingVariation;
  late bool _isWicketKeeper;

  // Football
  late String _footballPosition;
  late String _footballFoot;

  // Basketball
  late String _basketballPosition;

  // Tennis
  late String _tennisHand;
  late String _tennisBackhand;
  late String _tennisPlaystyle;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedSport = widget.user.primarySport;

    final c = widget.user.cricketSpecs ?? const CricketSpecs();
    _battingHand = c.battingHand;
    _bowlingArm = c.bowlingArm;
    _bowlingCategory = c.bowlingCategory;
    _bowlingVariation = c.bowlingVariation;
    _isWicketKeeper = c.isWicketKeeper;

    final f = widget.user.footballSpecs ?? const FootballSpecs();
    _footballPosition = f.position;
    _footballFoot = f.preferredFoot;

    final b = widget.user.basketballSpecs ?? const BasketballSpecs();
    _basketballPosition = b.position;

    final t = widget.user.tennisSpecs ?? const TennisSpecs();
    _tennisHand = t.hand;
    _tennisBackhand = t.backhand;
    _tennisPlaystyle = t.playstyle;
  }

  void _saveSpecialization() async {
    setState(() => _isSaving = true);
    final appState = context.read<AppState>();
    Map<String, dynamic> specsMap = {};

    if (_selectedSport == SportType.cricket) {
      final specs = CricketSpecs(
        battingHand: _battingHand,
        bowlingArm: _bowlingArm,
        bowlingCategory: _bowlingCategory,
        bowlingVariation: _bowlingVariation,
        isWicketKeeper: _isWicketKeeper,
      );
      appState.updateCricketSpecs(specs);
      specsMap = specs.toMap();
    } else if (_selectedSport == SportType.football) {
      final specs = FootballSpecs(
        position: _footballPosition,
        preferredFoot: _footballFoot,
      );
      appState.updateFootballSpecs(specs);
      specsMap = specs.toMap();
    } else if (_selectedSport == SportType.basketball) {
      final specs = BasketballSpecs(position: _basketballPosition);
      appState.updateBasketballSpecs(specs);
      specsMap = specs.toMap();
    } else if (_selectedSport == SportType.tennis) {
      final specs = TennisSpecs(
        hand: _tennisHand,
        backhand: _tennisBackhand,
        playstyle: _tennisPlaystyle,
      );
      appState.updateTennisSpecs(specs);
      specsMap = specs.toMap();
    }

    try {
      await SupabaseService.updateAthleteSpecs(
        userId: widget.user.id,
        sport: _selectedSport.name,
        specs: specsMap,
      );
    } catch (_) {}

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Athlete Specs Saved & Verified for ${_selectedSport.name.toUpperCase()}!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(_selectedSport.name);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: sportColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.tune_rounded, color: sportColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ATHLETE SPECIALIZATION',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Define your playing roles to qualify for sanctioned match squads',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                BouncingTap(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceLighter),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceLighter),

          // Sport Selector Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              children: SportType.values.map((sport) {
                final isSel = _selectedSport == sport;
                final col = AppColors.sportColor(sport.name);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSport = sport),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? col.withValues(alpha: 0.15) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? col : AppColors.surfaceLighter,
                          width: isSel ? 1.6 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          SportBadge(sport: sport, size: 22, showLabel: false),
                          const SizedBox(height: 3),
                          Text(
                            sport.name.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
                              color: isSel ? col : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Scrollable Specs Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedSport == SportType.cricket)
                    _buildCricketSpecsForm(sportColor)
                  else if (_selectedSport == SportType.football)
                    _buildFootballSpecsForm(sportColor)
                  else if (_selectedSport == SportType.basketball)
                    _buildBasketballSpecsForm(sportColor)
                  else if (_selectedSport == SportType.tennis)
                    _buildTennisSpecsForm(sportColor),

                  const SizedBox(height: 24),

                  // Save Button
                  if (_isSaving)
                    const Center(child: CircularProgressIndicator())
                  else
                    GradientButton(
                      label: 'SAVE & VERIFY ATHLETE PASSPORT',
                      width: double.infinity,
                      icon: Icons.verified_rounded,
                      onTap: _saveSpecialization,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cricket Specs Form ───────────────────────────────────────────────────

  Widget _buildCricketSpecsForm(Color accentColor) {
    final fastVariations = ['Fast', 'Fast-Medium', 'Medium-Fast', 'Medium'];
    final spinVariations = [
      'Off-Spinner',
      'Leg-Spinner',
      'Slow Left-Arm Orthodox',
      'Left-Arm Unorthodox (Chinaman)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Batting Hand
        _buildSectionTitle('1. BATTING STYLE', Icons.sports_cricket_rounded, accentColor),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoicePill(
                label: 'Right-hand bat',
                icon: Icons.front_hand_rounded,
                isSelected: _battingHand == 'Right-hand bat',
                onTap: () => setState(() => _battingHand = 'Right-hand bat'),
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChoicePill(
                label: 'Left-hand bat',
                icon: Icons.back_hand_rounded,
                isSelected: _battingHand == 'Left-hand bat',
                onTap: () => setState(() => _battingHand = 'Left-hand bat'),
                accentColor: accentColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 2. Bowling Arm
        _buildSectionTitle('2. BOWLING ARM', Icons.pan_tool_rounded, accentColor),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoicePill(
                label: 'Right-arm',
                icon: Icons.arrow_circle_right_outlined,
                isSelected: _bowlingArm == 'Right-arm',
                onTap: () => setState(() => _bowlingArm = 'Right-arm'),
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChoicePill(
                label: 'Left-arm',
                icon: Icons.arrow_circle_left_outlined,
                isSelected: _bowlingArm == 'Left-arm',
                onTap: () => setState(() => _bowlingArm = 'Left-arm'),
                accentColor: accentColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 3. Bowling Category (Pace vs Spin)
        _buildSectionTitle('3. BOWLING CATEGORY', Icons.speed_rounded, accentColor),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoicePill(
                label: 'Fast / Pace',
                icon: Icons.flash_on_rounded,
                isSelected: _bowlingCategory == 'Fast / Pace',
                onTap: () {
                  setState(() {
                    _bowlingCategory = 'Fast / Pace';
                    _bowlingVariation = 'Fast-Medium';
                  });
                },
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChoicePill(
                label: 'Spin',
                icon: Icons.rotate_right_rounded,
                isSelected: _bowlingCategory == 'Spin',
                onTap: () {
                  setState(() {
                    _bowlingCategory = 'Spin';
                    _bowlingVariation = _bowlingArm == 'Left-arm'
                        ? 'Slow Left-Arm Orthodox'
                        : 'Off-Spinner';
                  });
                },
                accentColor: accentColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 4. Bowling Variation (Sub-choices)
        Text(
          _bowlingCategory == 'Fast / Pace'
              ? 'SPECIFIC PACE VARIATION'
              : 'SPECIFIC SPIN VARIATION',
          style: GoogleFonts.outfit(
            color: AppColors.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (_bowlingCategory == 'Fast / Pace' ? fastVariations : spinVariations)
              .map(
                (v) => _buildOptionChip(
                  label: v,
                  isSelected: _bowlingVariation == v,
                  onTap: () => setState(() => _bowlingVariation = v),
                  accentColor: accentColor,
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 18),

        // 5. Wicketkeeping Toggle
        _buildSectionTitle('4. WICKETKEEPER CAPABILITY', Icons.sports_kabaddi_rounded, accentColor),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoicePill(
                label: 'Wicketkeeper: Yes',
                icon: Icons.check_circle_rounded,
                isSelected: _isWicketKeeper,
                onTap: () => setState(() => _isWicketKeeper = true),
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChoicePill(
                label: 'Wicketkeeper: No',
                icon: Icons.cancel_outlined,
                isSelected: !_isWicketKeeper,
                onTap: () => setState(() => _isWicketKeeper = false),
                accentColor: accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Football Specs Form ──────────────────────────────────────────────────

  Widget _buildFootballSpecsForm(Color accentColor) {
    final positions = ['Goalkeeper', 'Defender', 'Midfielder', 'Striker / Forward'];
    final feet = ['Right Foot', 'Left Foot', 'Both Feet'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. PRIMARY PITCH POSITION', Icons.sports_soccer_rounded, accentColor),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: positions
              .map(
                (pos) => _buildOptionChip(
                  label: pos,
                  isSelected: _footballPosition == pos,
                  onTap: () => setState(() => _footballPosition = pos),
                  accentColor: accentColor,
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 18),

        _buildSectionTitle('2. PREFERRED STRIKING FOOT', Icons.directions_walk_rounded, accentColor),
        const SizedBox(height: 8),
        Row(
          children: feet.map((ft) {
            final isSel = _footballFoot == ft;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _buildChoicePill(
                  label: ft,
                  icon: Icons.sports_score_rounded,
                  isSelected: isSel,
                  onTap: () => setState(() => _footballFoot = ft),
                  accentColor: accentColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Basketball Specs Form ────────────────────────────────────────────────

  Widget _buildBasketballSpecsForm(Color accentColor) {
    final positions = [
      'Point Guard (PG)',
      'Shooting Guard (SG)',
      'Small Forward (SF)',
      'Power Forward (PF)',
      'Center (C)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('PRIMARY COURT ROLE', Icons.sports_basketball_rounded, accentColor),
        const SizedBox(height: 8),
        ...positions.map((pos) {
          final isSel = _basketballPosition == pos;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildChoicePill(
              label: pos,
              icon: Icons.sports_basketball_outlined,
              isSelected: isSel,
              onTap: () => setState(() => _basketballPosition = pos),
              accentColor: accentColor,
            ),
          );
        }),
      ],
    );
  }

  // ─── Tennis Specs Form ────────────────────────────────────────────────────

  Widget _buildTennisSpecsForm(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. PLAYING HAND', Icons.sports_tennis_rounded, accentColor),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoicePill(
                label: 'Right-handed',
                icon: Icons.front_hand_rounded,
                isSelected: _tennisHand == 'Right-handed',
                onTap: () => setState(() => _tennisHand = 'Right-handed'),
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChoicePill(
                label: 'Left-handed',
                icon: Icons.back_hand_rounded,
                isSelected: _tennisHand == 'Left-handed',
                onTap: () => setState(() => _tennisHand = 'Left-handed'),
                accentColor: accentColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _buildSectionTitle('2. BACKHAND TYPE', Icons.sports_score_rounded, accentColor),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoicePill(
                label: 'Two-handed',
                icon: Icons.pan_tool_rounded,
                isSelected: _tennisBackhand == 'Two-handed',
                onTap: () => setState(() => _tennisBackhand = 'Two-handed'),
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChoicePill(
                label: 'One-handed',
                icon: Icons.back_hand_rounded,
                isSelected: _tennisBackhand == 'One-handed',
                onTap: () => setState(() => _tennisBackhand = 'One-handed'),
                accentColor: accentColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _buildSectionTitle('3. STRATEGICAL PLAYSTYLE', Icons.style_rounded, accentColor),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All-Court', 'Baseliner', 'Serve & Volley']
              .map(
                (ps) => _buildOptionChip(
                  label: ps,
                  isSelected: _tennisPlaystyle == ps,
                  onTap: () => setState(() => _tennisPlaystyle = ps),
                  accentColor: accentColor,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ─── UI Helpers ───────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon, Color accentColor) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildChoicePill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.12) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.surfaceLighter,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? accentColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? accentColor : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.surfaceLighter,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


