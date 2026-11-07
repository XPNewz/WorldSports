import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/search_service.dart';
import '../../widgets/common_widgets.dart';
import '../search/search_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY & CHAT SCREEN (Zero Dummy Data • Coming Soon Experience)
// ─────────────────────────────────────────────────────────────────────────────

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildComingSoonTab(
                    icon: Icons.chat_bubble_outline_rounded,
                    tag: 'In Active Development • Q1 2027',
                    title: 'Live Dugout & Match Chat',
                    description:
                        'Encrypted real-time messaging connecting athletes, team captains, scorers, and match officials directly on the field. Instant tactical sync with zero dummy bots.',
                    highlights: [
                      {
                        'icon': Icons.sports_cricket_rounded,
                        'title': 'Live In-Match Channels',
                        'subtitle':
                            'Automatic game chat rooms linked to active tournament fixtures and live scorecards.',
                      },
                      {
                        'icon': Icons.shield_outlined,
                        'title': 'Private Squad & Captain Dugout',
                        'subtitle':
                            'Tactical boards, lineup announcements, and batting order updates for verified teammates.',
                      },
                      {
                        'icon': Icons.campaign_rounded,
                        'title': 'Official Referee Broadcasts',
                        'subtitle':
                            'Instant dispute resolution, rain delay announcements, and pitch inspection alerts.',
                      },
                      {
                        'icon': Icons.lock_outline_rounded,
                        'title': 'Athlete-Verified Security',
                        'subtitle':
                            'No anonymous spam — every channel participant has a verified athlete passport.',
                      },
                    ],
                  ),
                  _buildComingSoonTab(
                    icon: Icons.groups_rounded,
                    tag: 'Coming Soon • Social Hub',
                    title: 'Athlete Communities & Clubs',
                    description:
                        'Join verified sporting networks, academy groups, and regional sport circles across your city. Network with real players and challenge rival squads.',
                    highlights: [
                      {
                        'icon': Icons.location_on_outlined,
                        'title': 'City & Regional Turf Hubs',
                        'subtitle':
                            'Discover local players, organize weekend pick-up matches, and reserve shared grounds.',
                      },
                      {
                        'icon': Icons.verified_user_rounded,
                        'title': 'Sanctioned Academy Spaces',
                        'subtitle':
                            'Official community boards for registered clubs, university leagues, and coaching camps.',
                      },
                      {
                        'icon': Icons.emoji_events_outlined,
                        'title': 'Milestone Showcase',
                        'subtitle':
                            'Celebrate match centuries, hat-tricks, clean sheets, and MVP trophies with your network.',
                      },
                    ],
                  ),
                  _buildComingSoonTab(
                    icon: Icons.newspaper_rounded,
                    tag: 'Coming Soon • League Desk',
                    title: 'Tournament Notice Board',
                    description:
                        'Official announcements, rulebook amendments, and schedule updates published directly by licensed tournament directors and sports federations.',
                    highlights: [
                      {
                        'icon': Icons.calendar_today_rounded,
                        'title': 'Fixture Schedules & Rescheduling',
                        'subtitle':
                            'Instant notifications when match times or stadium locations are officially adjusted.',
                      },
                      {
                        'icon': Icons.gavel_rounded,
                        'title': 'Official Bylaws & Fair Play Code',
                        'subtitle':
                            'Tournament guidelines, ball weight specifications, and referee jurisdiction notices.',
                      },
                      {
                        'icon': Icons.military_tech_rounded,
                        'title': 'Prize Pool & Trophy Distribution',
                        'subtitle':
                            'Direct transparency on tournament winnings, awards ceremonies, and sponsorship payouts.',
                      },
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community & Chat',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Live Channels · Squads · Official Announcements',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              BouncingTap(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(
                      initialCategory: SearchCategory.players,
                    ),
                  ),
                ),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: const Color(0xFF64748B),
            labelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            unselectedLabelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Dugout Chat'),
              Tab(text: 'Communities'),
              Tab(text: 'Notice Board'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab({
    required IconData icon,
    required String tag,
    required String title,
    required String description,
    required List<Map<String, dynamic>> highlights,
  }) {
    return _CommunityComingSoonTabBody(
      icon: icon,
      tag: tag,
      title: title,
      description: description,
      highlights: highlights,
    );
  }
}

class _CommunityComingSoonTabBody extends StatefulWidget {
  final IconData icon;
  final String tag;
  final String title;
  final String description;
  final List<Map<String, dynamic>> highlights;

  const _CommunityComingSoonTabBody({
    required this.icon,
    required this.tag,
    required this.title,
    required this.description,
    required this.highlights,
  });

  @override
  State<_CommunityComingSoonTabBody> createState() =>
      _CommunityComingSoonTabBodyState();
}

class _CommunityComingSoonTabBodyState
    extends State<_CommunityComingSoonTabBody> {
  bool _isRegistered = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Hero Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.tag.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          widget.description,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'WHAT TO EXPECT',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        ...widget.highlights.map((h) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    h['icon'] as IconData,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h['title'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        h['subtitle'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        BouncingTap(
          onTap: () {
            setState(() => _isRegistered = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primary,
                content: Text(
                  'Registered for early launch access to ${widget.title}!',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color:
                  _isRegistered ? const Color(0xFF059669) : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRegistered
                      ? Icons.check_circle_rounded
                      : Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _isRegistered
                      ? 'REGISTERED FOR EARLY LAUNCH'
                      : 'NOTIFY ME WHEN LIVE',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
