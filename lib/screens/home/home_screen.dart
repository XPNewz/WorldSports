import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/services/ad_service.dart';
import '../../widgets/common_widgets.dart';
import '../community/community_screen.dart';
import '../mysports/mysports_screen.dart';
import '../profile/profile_screen.dart';
import '../match/live_scoring_screen.dart';
import '../../widgets/arena_drawer.dart';
import '../search/search_screen.dart';

// ─── Main Shell with 4 Structural Tabs ─────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final screens = [
      HomeScreen(onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer()),
      const CommunityScreen(),
      const MySportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg,
      drawer: const ArenaDrawer(),
      body: IndexedStack(
        index: state.bottomNavIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth)),
          
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: _PlayfulNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    activeIndex: state.bottomNavIndex,
                    activeColor: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _PlayfulNavItem(
                    icon: Icons.forum_rounded,
                    label: 'Community',
                    index: 1,
                    activeIndex: state.bottomNavIndex,
                    badge: '4',
                    activeColor: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _PlayfulNavItem(
                    icon: Icons.emoji_events_rounded,
                    label: 'My Sports',
                    index: 2,
                    activeIndex: state.bottomNavIndex,
                    activeColor: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _PlayfulNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 3,
                    activeIndex: state.bottomNavIndex,
                    activeColor: AppColors.primary,
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

class _PlayfulNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int activeIndex;
  final String? badge;
  final Color activeColor;

  const _PlayfulNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.activeIndex,
    this.badge,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == activeIndex;
    return BouncingTap(
      onTap: () => context.read<AppState>().setBottomNavIndex(index),
      scaleFactor: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? activeColor : AppColors.textMuted,
                  size: 24,
                ),
                if (badge != null && !isActive)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.live,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge!,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? activeColor : AppColors.textMuted,
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Screen (Light & Playful Sports Vibe) ────────────────────────────────

class HomeScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;
  const HomeScreen({super.key, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final activeSport = appState.activeSportFilter;
    final liveMatches = appState.liveMatches;

    final filteredLive = activeSport == null
        ? liveMatches
        : liveMatches.where((m) => m.sport == activeSport).toList();

    final filteredUpcoming = activeSport == null
        ? MockData.upcomingMatches
        : MockData.upcomingMatches.where((m) => m.sport == activeSport).toList();

    return SafeArea(
      child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Top App Bar: Menubar + Logo (Left) & Search + Notification (Right) ─────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: AppColors.surfaceLighter)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Menubar + Logo
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BouncingTap(
                          onTap: () {
                            if (onOpenDrawer != null) {
                              onOpenDrawer!();
                            } else {
                              Scaffold.maybeOf(context)?.openDrawer();
                            }
                          },
                          child: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 28),
                        ),
                        const SizedBox(width: 10),
                        // Official Logo: AppLogo + "WORLDSPORTS"
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppLogo(
                              size: 32,
                              showContainer: true,
                              showShadow: true,
                            ),
                            const SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'WORLD',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'SPORTS',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.primary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Right: Search Button + Notification Button
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BouncingTap(
                          onTap: () => _showSearchModal(context),
                          child: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 26),
                        ),
                        const SizedBox(width: 8),
                        BouncingTap(
                          onTap: () => _showNotificationsModal(context),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 26),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.live,
                                    shape: BoxShape.circle,
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
            ),

            // Athlete Status Sub-bar (Responsive, zero mobile overflow)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    UserAvatar(
                      name: user?.name ?? 'U',
                      radius: 18,
                      showProRing: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${user?.name.split(' ').first ?? 'Athlete'}',
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Division 1 Pro • Matchday Active',
                            style: GoogleFonts.outfit(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Professional Sports Highlight Bubbles (Stories)
            

            // Professional Action Pods (Horizontally scrollable, prevents mobile overflow)
            

            // Professional Sport Filter Pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _BubblySportPill(
                        label: 'ALL SPORTS',
                        icon: Icons.sports_rounded,
                        isSelected: activeSport == null,
                        sportColor: AppColors.primary,
                        onTap: () => context.read<AppState>().setActiveSportFilter(null),
                      ),
                      const SizedBox(width: 8),
                      _BubblySportPill(
                        label: 'CRICKET',
                        icon: Icons.sports_cricket_rounded,
                        isSelected: activeSport == SportType.cricket,
                        sportColor: AppColors.cricket,
                        onTap: () => context.read<AppState>().setActiveSportFilter(
                            activeSport == SportType.cricket ? null : SportType.cricket),
                      ),
                      const SizedBox(width: 8),
                      _BubblySportPill(
                        label: 'FOOTBALL',
                        icon: Icons.sports_soccer_rounded,
                        isSelected: activeSport == SportType.football,
                        sportColor: AppColors.football,
                        onTap: () => context.read<AppState>().setActiveSportFilter(
                            activeSport == SportType.football ? null : SportType.football),
                      ),
                      const SizedBox(width: 8),
                      _BubblySportPill(
                        label: 'BASKETBALL',
                        icon: Icons.sports_basketball_rounded,
                        isSelected: activeSport == SportType.basketball,
                        sportColor: AppColors.basketball,
                        onTap: () => context.read<AppState>().setActiveSportFilter(
                            activeSport == SportType.basketball ? null : SportType.basketball),
                      ),
                      const SizedBox(width: 8),
                      _BubblySportPill(
                        label: 'TENNIS',
                        icon: Icons.sports_tennis_rounded,
                        isSelected: activeSport == SportType.tennis,
                        sportColor: AppColors.tennis,
                        onTap: () => context.read<AppState>().setActiveSportFilter(
                            activeSport == SportType.tennis ? null : SportType.tennis),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Featured Match of the Day (Spotlight Arena)
            if (liveMatches.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _FeaturedLightArenaCard(match: liveMatches.first),
                ),
              ),

            // Live Arena Matches Carousel
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                child: SectionHeader(
                  title: 'Live Arena Matches',
                  accentColor: AppColors.live,
                  icon: Icons.sensors_rounded,
                  actionLabel: 'See all (${filteredLive.length})',
                  onAction: () => context.read<AppState>().setBottomNavIndex(2),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 205,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredLive.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => _LiveLightMatchCard(match: filteredLive[i]),
                ),
              ),
            ),

            // Nearby Matches Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                child: SectionHeader(
                  title: 'Nearby Live Matches',
                  accentColor: AppColors.primary,
                  icon: Icons.near_me_rounded,
                  actionLabel: '${MockData.nearbyMatches.length} Grounds Active',
                  onAction: () {},
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 195,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: MockData.nearbyMatches.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => _NearbyMatchCard(match: MockData.nearbyMatches[i]),
                ),
              ),
            ),

            // Featured Arena & Equipment Sponsor Banner (Ads Placement)
            SliverToBoxAdapter(
              child: _ModernSportsBannerAd(
                ad: AdService.getBannerAd(sport: appState.selectedSport),
              ),
            ),

            // Sports Wire & Live Feed (Twitter / X Tweet Style)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: SectionHeader(
                  title: 'Sports Wire & Live Feed',
                  accentColor: AppColors.primary,
                  icon: Icons.dynamic_feed_rounded,
                  actionLabel: 'Latest Posts',
                  onAction: () {},
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final feedPosts = appState.feedPosts;
                  final promotedAds = AdService.getPromotedPosts(sport: appState.selectedSport);

                  // Interleave promoted ad at index 1 and index 4 (if available)
                  if (i == 1 && promotedAds.isNotEmpty) {
                    return _TwitterPromotedAdPost(ad: promotedAds[0]);
                  }
                  if (i == 4 && promotedAds.length > 1) {
                    return _TwitterPromotedAdPost(ad: promotedAds[1]);
                  }

                  // Calculate actual post index
                  int postIdx = i;
                  if (i > 4 && promotedAds.length > 1) {
                    postIdx -= 2;
                  } else if (i > 1 && promotedAds.isNotEmpty) {
                    postIdx -= 1;
                  }

                  if (postIdx >= 0 && postIdx < feedPosts.length) {
                    return _TwitterSportsTweetCard(post: feedPosts[postIdx]);
                  }
                  return const SizedBox.shrink();
                },
                childCount: appState.feedPosts.length +
                    (AdService.getPromotedPosts(sport: appState.selectedSport).isNotEmpty ? 1 : 0) +
                    (AdService.getPromotedPosts(sport: appState.selectedSport).length > 1 ? 1 : 0),
              ),
            ),

            // Upcoming Fixtures Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                child: SectionHeader(
                  title: 'Upcoming Fixtures',
                  accentColor: AppColors.primary,
                  icon: Icons.calendar_month_rounded,
                  actionLabel: 'See all (${filteredUpcoming.length})',
                  onAction: () => context.read<AppState>().setBottomNavIndex(2),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 205,
                child: filteredUpcoming.isEmpty
                    ? Center(
                        child: Text(
                          'No upcoming fixtures scheduled',
                          style: GoogleFonts.outfit(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredUpcoming.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (_, i) => _UpcomingLightMatchCard(match: filteredUpcoming[i]),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 85)),
          ],
        ),
      );
  }

  void _showSearchModal(BuildContext context, [String? initialQuery]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: initialQuery),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        child: SingleChildScrollView(
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.notifications_active_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Arena Notifications',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.live.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '3 NEW',
                      style: GoogleFonts.outfit(
                        color: AppColors.live,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _NotificationItem(
                title: 'Squad Selection Confirmed',
                subtitle: 'You are listed in playing XI for Mumbai Mavericks vs Delhi Dynamos.',
                time: '15m ago',
                icon: Icons.check_circle_rounded,
                color: AppColors.cricket,
              ),
              _NotificationItem(
                title: 'MCA Circular Published',
                subtitle: 'Quarterfinal bracket fixtures confirmed for Wankhede Stadium.',
                time: '2h ago',
                icon: Icons.shield_rounded,
                color: AppColors.primary,
              ),
              _NotificationItem(
                title: 'Scorecard Verified (+25 Elo)',
                subtitle: 'Your performance 74*(46) & 2/28 was verified by match referee.',
                time: '1d ago',
                icon: Icons.star_rounded,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 14),
              BouncingTap(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'DISMISS ALERTS',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
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

class _NotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
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

// ─── Story Highlight Bubble ───────────────────────────────────────────────────



// ─── Professional Action Pod ──────────────────────────────────────────────────



// ─── Professional Sport Pill ──────────────────────────────────────────────────

class _BubblySportPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color sportColor;
  final VoidCallback onTap;

  const _BubblySportPill({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.sportColor,
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
          color: isSelected ? sportColor : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? sportColor : AppColors.cardBorder,
            width: 1.2,
          ),
          
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Match Row Helper (Matches Column Score Style) ─────────────────────

class _MatchTeamRow extends StatelessWidget {
  final String name;
  final String shortName;
  final String score;
  final String? overs;
  final bool isActive;
  final SportType sport;
  final Color crestColor;
  final double fontSize;
  final double crestSize;
  const _MatchTeamRow({
    required this.name,
    required this.shortName,
    required this.score,
    this.overs,
    required this.isActive,
    required this.sport,
    required this.crestColor,
    this.fontSize = 14.5,
    this.crestSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TeamCrest(
          shortName: shortName,
          color: crestColor,
          size: crestSize,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.outfit(
              color: isActive ? AppColors.textPrimary : const Color(0xFF64748B),
              fontSize: fontSize,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
            children: [
              TextSpan(
                text: score,
                style: GoogleFonts.outfit(
                  color: isActive ? AppColors.textPrimary : const Color(0xFF64748B),
                  fontSize: fontSize + 2.0,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              if (overs != null && overs!.isNotEmpty) ...[
                const TextSpan(text: ' '),
                TextSpan(
                  text: '($overs)',
                  style: GoogleFonts.outfit(
                    color: isActive ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

String _getMatchTeamScore(dynamic scoreData, SportType sport, int teamNum) {
  if (scoreData is! Map) return '-';
  final key = teamNum == 1 ? 'team1_score' : 'team2_score';
  final val = scoreData[key];
  if (val == null) return '-';
  return val.toString();
}

String? _getMatchTeamOvers(dynamic scoreData, SportType sport, int teamNum) {
  if (scoreData is! Map) return null;
  if (sport == SportType.cricket) {
    final key = teamNum == 1 ? 'team1_overs' : 'team2_overs';
    final val = scoreData[key];
    if (val != null && val.toString().isNotEmpty) {
      return val.toString();
    }
  } else if (sport == SportType.tennis) {
    final key = teamNum == 1 ? 'team1_game' : 'team2_game';
    final val = scoreData[key];
    if (val != null && val.toString().isNotEmpty) {
      return val.toString();
    }
  }
  return null;
}

bool _isMatchTeamActive(dynamic scoreData, SportType sport, int teamNum) {
  if (scoreData is! Map) return teamNum == 1;
  if (sport == SportType.cricket) {
    final status = (scoreData['status_text'] ?? '').toString().toLowerCase();
    if (status.contains('need') || status.contains('chasing') || status.contains('trail')) {
      return teamNum == 1;
    }
    final t1Overs = scoreData['team1_overs']?.toString();
    final t2Overs = scoreData['team2_overs']?.toString();
    if (t1Overs != null && t2Overs == null) return teamNum == 1;
    if (t2Overs != null && t1Overs == null) return teamNum == 2;
    return teamNum == 1;
  }
  if (sport == SportType.football || sport == SportType.basketball) {
    final s1 = int.tryParse('${scoreData['team1_score']}') ?? 0;
    final s2 = int.tryParse('${scoreData['team2_score']}') ?? 0;
    if (s1 != s2) return teamNum == 1 ? s1 > s2 : s2 > s1;
    return teamNum == 1;
  }
  return teamNum == 1;
}

String _deriveShortName(String name) {
  final clean = name.trim();
  if (clean.isEmpty) return 'TM';
  final words = clean.split(RegExp(r'\s+'));
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  } else if (clean.length >= 3) {
    return clean.substring(0, 3).toUpperCase();
  }
  return clean.toUpperCase();
}

// ─── Featured Light Arena Card ────────────────────────────────────────────────

class _FeaturedLightArenaCard extends StatelessWidget {
  final MatchModel match;

  const _FeaturedLightArenaCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(match.sport.name);
    final gradient = AppColors.sportGradient(match.sport.name);
    final score = match.scoreData as Map<String, dynamic>?;

    final isTeam1Active = _isMatchTeamActive(score, match.sport, 1);
    final isTeam2Active = _isMatchTeamActive(score, match.sport, 2);
    final team1Score = _getMatchTeamScore(score, match.sport, 1);
    final team1Overs = _getMatchTeamOvers(score, match.sport, 1);
    final team2Score = _getMatchTeamScore(score, match.sport, 2);
    final team2Overs = _getMatchTeamOvers(score, match.sport, 2);

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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
          boxShadow: const [AppColors.cellShadow],
        ),
        child: Column(
          children: [
            // Ribbon Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'MATCH OF THE DAY • ${match.sport.name.toUpperCase()}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  const LiveIndicator(label: 'LIVE'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // Team 1 Row (Full Name + Score)
                  _MatchTeamRow(
                    name: match.team1Name,
                    shortName: match.team1Short,
                    score: team1Score,
                    overs: team1Overs,
                    isActive: isTeam1Active,
                    sport: match.sport,
                    crestColor: AppColors.primary,
                    fontSize: 15.5,
                    crestSize: 28,
                  ),
                  const SizedBox(height: 10),

                  // Team 2 Row (Full Name + Score)
                  _MatchTeamRow(
                    name: match.team2Name,
                    shortName: match.team2Short,
                    score: team2Score,
                    overs: team2Overs,
                    isActive: isTeam2Active,
                    sport: match.sport,
                    crestColor: AppColors.sportAccentColor(match.sport.name),
                    fontSize: 15.5,
                    crestSize: 28,
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.surfaceLighter, height: 1),
                  const SizedBox(height: 14),

                  // Momentum Bar
                  MomentumBar(
                    team1Ratio: 0.58,
                    team1Color: sportColor,
                    team2Color: AppColors.sportAccentColor(match.sport.name),
                    team1Label: match.team1Short,
                    team2Label: match.team2Short,
                  ),

                  const SizedBox(height: 12),

                  // Status Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            score?['status_text'] ?? 'Match in intense progress',
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

// ─── Live Light Match Card ────────────────────────────────────────────────────

class _LiveLightMatchCard extends StatelessWidget {
  final MatchModel match;

  const _LiveLightMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final score = match.scoreData as Map<String, dynamic>?;
    final isTeam1Active = _isMatchTeamActive(score, match.sport, 1);
    final isTeam2Active = _isMatchTeamActive(score, match.sport, 2);

    final team1Score = _getMatchTeamScore(score, match.sport, 1);
    final team1Overs = _getMatchTeamOvers(score, match.sport, 1);
    final team2Score = _getMatchTeamScore(score, match.sport, 2);
    final team2Overs = _getMatchTeamOvers(score, match.sport, 2);

    return BouncingTap(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LiveScoringScreen(match: match),
          ),
        );
      },
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
          boxShadow: const [AppColors.cellShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SportBadge(sport: match.sport, showLabel: true, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.venue.isNotEmpty ? match.venue : match.format,
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const LiveIndicator(),
              ],
            ),
            const SizedBox(height: 12),

            // Team 1 Row
            _MatchTeamRow(
              name: match.team1Name,
              shortName: match.team1Short,
              score: team1Score,
              overs: team1Overs,
              isActive: isTeam1Active,
              sport: match.sport,
              crestColor: AppColors.primary,
            ),
            const SizedBox(height: 8),

            // Team 2 Row
            _MatchTeamRow(
              name: match.team2Name,
              shortName: match.team2Short,
              score: team2Score,
              overs: team2Overs,
              isActive: isTeam2Active,
              sport: match.sport,
              crestColor: AppColors.sportAccentColor(match.sport.name),
            ),

            const Spacer(),

            if (score != null && score['status_text'] != null && score['status_text'].toString().isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.sportColor(match.sport.name),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        score['status_text'] ?? '',
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

// ─── Upcoming Light Match Card ────────────────────────────────────────────────

class _UpcomingLightMatchCard extends StatelessWidget {
  final MatchModel match;

  const _UpcomingLightMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppColors.sportColor(match.sport.name);
    final time =
        '${match.dateTime.hour.toString().padLeft(2, '0')}:${match.dateTime.minute.toString().padLeft(2, '0')}';

    return BouncingTap(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LiveScoringScreen(match: match),
          ),
        );
      },
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
          boxShadow: const [AppColors.cellShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SportBadge(sport: match.sport, showLabel: true, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.venue.isNotEmpty ? match.venue : match.format,
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded, size: 11, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        time,
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
            const SizedBox(height: 12),

            // Team 1 Row
            _MatchTeamRow(
              name: match.team1Name,
              shortName: match.team1Short,
              score: 'VS',
              isActive: false,
              sport: match.sport,
              crestColor: AppColors.primary,
            ),
            const SizedBox(height: 8),

            // Team 2 Row
            _MatchTeamRow(
              name: match.team2Name,
              shortName: match.team2Short,
              score: '',
              isActive: false,
              sport: match.sport,
              crestColor: AppColors.sportAccentColor(match.sport.name),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: sportColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Scheduled at $time • ${match.format}',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

// ─── Nearby Match Card ────────────────────────────────────────────────────────

class _NearbyMatchCard extends StatelessWidget {
  final NearbyMatchModel match;

  const _NearbyMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final team1Name = match.resolvedTeam1Name;
    final team2Name = match.resolvedTeam2Name;
    final team1Short = _deriveShortName(team1Name);
    final team2Short = _deriveShortName(team2Name);

    return BouncingTap(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            content: Text(
              'Opening Live Arena Feed: $team1Name vs $team2Name',
              style: GoogleFonts.outfit(color: AppColors.textPrimary),
            ),
          ),
        );
      },
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
          boxShadow: const [AppColors.cellShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Sport Badge + Match Title + Distance
            Row(
              children: [
                SportBadge(sport: match.sport, showLabel: false, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.matchTitle,
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 11),
                      const SizedBox(width: 3),
                      Text(
                        match.distance,
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Teams & Scores in Column Way (with full team names)
            _MatchTeamRow(
              name: team1Name,
              shortName: team1Short,
              score: match.team1Score.isNotEmpty ? match.team1Score : '-',
              overs: match.team1Overs,
              isActive: match.isTeam1Active,
              sport: match.sport,
              crestColor: AppColors.primary,
            ),
            const SizedBox(height: 7),

            _MatchTeamRow(
              name: team2Name.isNotEmpty ? team2Name : 'Opponent',
              shortName: team2Short,
              score: match.team2Score.isNotEmpty ? match.team2Score : '-',
              overs: match.team2Overs,
              isActive: !match.isTeam1Active,
              sport: match.sport,
              crestColor: AppColors.sportAccentColor(match.sport.name),
            ),

            const Spacer(),

            // Footer: Venue & Status Text
            Row(
              children: [
                const Icon(Icons.stadium_outlined, color: AppColors.textMuted, size: 13),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    match.venue,
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: match.isLive
                        ? AppColors.live.withValues(alpha: 0.1)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    match.statusText,
                    style: GoogleFonts.outfit(
                      color: match.isLive ? AppColors.live : AppColors.textSecondary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modern Sports Banner Ad ──────────────────────────────────────────────────

class _ModernSportsBannerAd extends StatelessWidget {
  final AdModel ad;

  const _ModernSportsBannerAd({required this.ad});

  @override
  Widget build(BuildContext context) {
    AdService.recordImpression(ad.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => AdService.showAdDetailsModal(context, ad),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'OFFICIAL ARENA PARTNER',
                            style: GoogleFonts.outfit(
                              color: Colors.amber,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (ad.discountTag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.fireGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ad.discountTag!,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ad.headline,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ad.bodyText,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${ad.rating}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${ad.reviewsCount}+ athletes)',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            ad.ctaText,
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Twitter / X Tweet Feed Card ─────────────────────────────────────────────

class _TwitterSportsTweetCard extends StatelessWidget {
  final FeedPost post;

  const _TwitterSportsTweetCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isLiked = post.isLiked;
    final isReposted = post.isReposted;
    final isBookmarked = post.isBookmarked;
    final sportColor = post.sport != null
        ? AppColors.sportColor(post.sport!.name)
        : AppColors.primary;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 1400),
                backgroundColor: Colors.white,
                content: Text(
                  'Viewing thread by ${post.authorName}',
                  style: GoogleFonts.outfit(color: AppColors.textPrimary),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Avatar Circle
                _buildAvatar(post, sportColor),
                const SizedBox(width: 12),

                // Tweet Body Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Author Name, Verified, @handle · timeAgo, sportTag
                      Row(
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    post.authorName,
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textPrimary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (post.isVerified) ...[
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFF1D9BF0),
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.authorHandle,
                            style: GoogleFonts.outfit(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '· ${post.timeAgo}',
                            style: GoogleFonts.outfit(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (post.sport != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: sportColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                post.sport!.name.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: sportColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Optional Headline / Title
                      if (post.title != null && post.title!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          post.title!,
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],

                      // Tweet Content with #hashtags and @mentions in Twitter Blue
                      const SizedBox(height: 5),
                      _buildTweetRichContent(post.content),

                      // Media Card Attachment Container
                      if (post.mediaHeadline != null || post.mediaSubtitle != null) ...[
                        const SizedBox(height: 10),
                        _buildMediaCard(post, sportColor),
                      ],

                      // Twitter Action Row (Reply, Repost, Like, Bookmark, Share)
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Reply
                          _TweetActionButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            activeIcon: Icons.chat_bubble_rounded,
                            count: post.comments,
                            isActive: false,
                            activeColor: const Color(0xFF1D9BF0),
                            onTap: () {
                              _showReplySheet(context, post);
                            },
                          ),

                          // Repost
                          _TweetActionButton(
                            icon: Icons.repeat_rounded,
                            activeIcon: Icons.repeat_rounded,
                            count: post.reposts,
                            isActive: isReposted,
                            activeColor: const Color(0xFF00BA7C), // Twitter Repost Green
                            onTap: () {
                              state.togglePostRepost(post.id);
                            },
                          ),

                          // Like
                          _TweetActionButton(
                            icon: Icons.favorite_border_rounded,
                            activeIcon: Icons.favorite_rounded,
                            count: post.likes,
                            isActive: isLiked,
                            activeColor: const Color(0xFFF91880), // Twitter Heart Red/Pink
                            onTap: () {
                              state.togglePostLike(post.id);
                            },
                          ),

                          // Bookmark
                          _TweetActionButton(
                            icon: Icons.bookmark_border_rounded,
                            activeIcon: Icons.bookmark_rounded,
                            isActive: isBookmarked,
                            activeColor: AppColors.primary,
                            onTap: () {
                              state.togglePostBookmark(post.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    isBookmarked ? 'Removed from Bookmarks' : 'Saved to Bookmarks',
                                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Share
                          _TweetActionButton(
                            icon: Icons.share_outlined,
                            activeIcon: Icons.share_rounded,
                            isActive: false,
                            activeColor: const Color(0xFF1D9BF0),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    'Copied tweet link: https://worldsports.app/x/${post.id}',
                                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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

  Widget _buildAvatar(FeedPost post, Color sportColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: sportColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: sportColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          post.authorName.isNotEmpty ? post.authorName[0] : 'S',
          style: GoogleFonts.outfit(
            color: sportColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildMediaCard(FeedPost post, Color sportColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cellBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sportColor.withValues(alpha: 0.85),
                  sportColor.withValues(alpha: 0.35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    Icons.sports_rounded,
                    size: 85,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, size: 11, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            'CIRCUIT BULLETIN',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.mediaHeadline != null)
                  Text(
                    post.mediaHeadline!,
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (post.mediaSubtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    post.mediaSubtitle!,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 11,
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

  void _showReplySheet(BuildContext context, FeedPost post) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Replying to ',
                    style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
                  ),
                  Text(
                    post.authorHandle,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF1D9BF0),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                autofocus: true,
                maxLines: 3,
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Post your reply...',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cellBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1D9BF0), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D9BF0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      context.read<AppState>().incrementPostComments(post.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white,
                          content: Text(
                            'Reply posted to ${post.authorHandle}',
                            style: GoogleFonts.outfit(color: AppColors.textPrimary),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Reply',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Twitter Promoted Ad Post ────────────────────────────────────────────────

class _TwitterPromotedAdPost extends StatelessWidget {
  final AdModel ad;

  const _TwitterPromotedAdPost({required this.ad});

  @override
  Widget build(BuildContext context) {
    AdService.recordImpression(ad.id);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AdService.showAdDetailsModal(context, ad),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Advertiser Avatar with Sponsored Star
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          ad.advertiserName.isNotEmpty ? ad.advertiserName[0] : 'A',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D9BF0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, size: 9, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Advertiser Name, Handle, Promoted Badge
                      Row(
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    ad.advertiserName,
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textPrimary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (ad.isVerified) ...[
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFF1D9BF0),
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ad.advertiserHandle,
                            style: GoogleFonts.outfit(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                          const Spacer(),
                          // Promoted Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.campaign_rounded, size: 10, color: AppColors.primary),
                                const SizedBox(width: 3),
                                Text(
                                  ad.badgeText.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: AppColors.primary,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Headline
                      const SizedBox(height: 6),
                      Text(
                        ad.headline,
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),

                      // Ad Body with hashtags
                      const SizedBox(height: 5),
                      _buildTweetRichContent(ad.bodyText),

                      // Deal Card Attachment
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cellBorderColor),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            if (ad.discountTag != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: AppColors.fireGradient,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ad.discountTag!,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (ad.promoCode != null)
                              Expanded(
                                child: Text(
                                  'Code: ${ad.promoCode}',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textPrimary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Text(
                                  'Partner Offer',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_outward_rounded, size: 11, color: Colors.white),
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
        ),
      ),
    );
  }
}

// ─── Tweet Action Button ──────────────────────────────────────────────────────

class _TweetActionButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int? count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _TweetActionButton({
    required this.icon,
    required this.activeIcon,
    this.count,
    this.isActive = false,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : AppColors.textMuted;

    return BouncingTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 16.5,
              color: color,
            ),
            if (count != null) ...[
              const SizedBox(width: 5),
              Text(
                '$count',
                style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Tweet Rich Content Builder (Hashtags and Mentions) ────────────────────────

Widget _buildTweetRichContent(String text) {
  final spans = <TextSpan>[];
  final regex = RegExp(r'(#\w+|@\w+|https?://\S+|[^\s#@]+|\s+)');
  final matches = regex.allMatches(text);

  for (final match in matches) {
    final str = match.group(0)!;
    if (str.startsWith('#') || str.startsWith('@')) {
      spans.add(
        TextSpan(
          text: str,
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D9BF0), // Twitter Blue
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: str,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 13,
            height: 1.38,
          ),
        ),
      );
    }
  }

  return RichText(
    text: TextSpan(children: spans),
  );
}
