import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../core/services/search_service.dart';
import '../search/search_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    'Communities',
    'Direct Chat',
  ];

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
      backgroundColor: AppColors.bg, // Soft sky blue from theme
      body: SafeArea(
        child: Column(
          children: [
            // Sky-themed Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                // Subtle cloud-like drop shadow
                border: Border(bottom: BorderSide(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth)),
                boxShadow: [AppColors.cellShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Community Hub',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      BouncingTap(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SearchScreen(
                                initialCategory: SearchCategory.communities,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Sky-themed Tab Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
boxShadow: const [AppColors.cellShadowSmall],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      unselectedLabelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      onTap: (i) => setState(() {}),
                      tabs: _tabs.map((t) => Tab(text: t)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Communities Tab
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
                      _PremiumCommunityCard(
                        title: 'Mumbai Mavericks',
                        subtitle: 'Cricket Club • 1.2k Members',
                        icon: Icons.sports_cricket_rounded,
                        color: AppColors.primary,
                        imagePlaceholder: '🏏',
                      ),
                      const SizedBox(height: 12),
                      _PremiumCommunityCard(
                        title: 'Delhi Dynamos',
                        subtitle: 'Football Club • 850 Members',
                        icon: Icons.sports_soccer_rounded,
                        color: AppColors.primary,
                        imagePlaceholder: '⚽',
                      ),
                      const SizedBox(height: 12),
                      _PremiumCommunityCard(
                        title: 'Sunday Kickers',
                        subtitle: 'Casual Community • 120 Members',
                        icon: Icons.groups_rounded,
                        color: AppColors.secondary,
                        imagePlaceholder: '🏟️',
                      ),
                      const SizedBox(height: 12),
                      _PremiumCommunityCard(
                        title: 'Mumbai Cricket Association',
                        subtitle: 'Official Association • Verified',
                        icon: Icons.verified_rounded,
                        color: AppColors.gold,
                        imagePlaceholder: '🏆',
                        isVerified: true,
                      ),
                    ],
                  ),
                  
                  // Direct Chat Tab
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
                      _DirectChatCard(
                        name: 'Coach Sharma',
                        lastMessage: "Practice at 6 AM tomorrow. Don't be late!",
                        time: '10:42 AM',
                        unread: 2,
                        isOnline: true,
                        avatarLetter: 'S',
                      ),
                      const SizedBox(height: 12),
                      _DirectChatCard(
                        name: 'Rahul (Teammate)',
                        lastMessage: 'Are we wearing the away kit?',
                        time: 'Yesterday',
                        unread: 0,
                        isOnline: false,
                        avatarLetter: 'R',
                      ),
                      const SizedBox(height: 12),
                      _DirectChatCard(
                        name: 'Arena Support',
                        lastMessage: 'Your league registration is confirmed.',
                        time: 'Mon',
                        unread: 0,
                        isOnline: true,
                        avatarLetter: 'A',
                        isOfficial: true,
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

class _PremiumCommunityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String imagePlaceholder;
  final bool isVerified;

  const _PremiumCommunityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.imagePlaceholder,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
boxShadow: const [AppColors.cellShadow],
          // Soft cloud shadow
          
        ),
        child: Row(
          children: [
            // Avatar/Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                imagePlaceholder,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(icon, color: AppColors.textMuted, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
            // Action
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectChatCard extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;
  final String avatarLetter;
  final bool isOfficial;

  const _DirectChatCard({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isOnline,
    required this.avatarLetter,
    this.isOfficial = false,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
boxShadow: const [AppColors.cellShadowSmall],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: isOfficial ? AppColors.primaryGradient : null,
                    color: isOfficial ? null : AppColors.surfaceLighter,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatarLetter,
                    style: GoogleFonts.outfit(
                      color: isOfficial ? Colors.white : AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.secondary, // Green for online
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cellBorderColor, width: AppColors.cellBorderWidth),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Chat Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: unread > 0 ? FontWeight.w900 : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.outfit(
                          color: unread > 0 ? AppColors.primary : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: GoogleFonts.outfit(
                            color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                            fontSize: 13.5,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread.toString(),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
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
