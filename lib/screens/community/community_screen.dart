import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/follow_community_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/search_service.dart';
import '../../widgets/common_widgets.dart';
import '../search/search_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY SCREEN (3 tabs: Communities • Following • Suggestions)
// ─────────────────────────────────────────────────────────────────────────────

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── State ──────────────────────────────────────────────────────────────────
  List<CommunityModel> _myCommunities = [];
  List<CommunityModel> _allCommunities = [];
  List<FollowUser> _followSuggestions = [];
  List<FollowUser> _myFollowing = [];

  bool _loadingCommunities = true;
  bool _loadingFollow = true;

  String _selectedSport = 'all';
  final _searchController = TextEditingController();
  Timer? _debounce;

  final _sports = ['all', 'cricket', 'football', 'basketball', 'tennis'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) setState(() {});
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadCommunities(), _loadFollowData()]);
  }

  Future<void> _loadCommunities() async {
    setState(() => _loadingCommunities = true);
    final sport = _selectedSport == 'all' ? null : _selectedSport;
    final search = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();

    final results = await Future.wait([
      FollowCommunityService.getMyCommunities(),
      FollowCommunityService.getCommunities(sportFilter: sport, searchQuery: search),
    ]);
    if (!mounted) return;
    setState(() {
      _myCommunities = (results[0] as List).cast<CommunityModel>();
      _allCommunities = (results[1] as List).cast<CommunityModel>();
      _loadingCommunities = false;
    });
  }

  Future<void> _loadFollowData() async {
    setState(() => _loadingFollow = true);
    final me = SupabaseService.currentUser?.id ?? '';
    final results = await Future.wait([
      FollowCommunityService.getFollowSuggestions(limit: 20),
      if (me.isNotEmpty) FollowCommunityService.getFollowing(me, limit: 50),
    ]);
    if (!mounted) return;
    setState(() {
      _followSuggestions = (results[0] as List).cast<FollowUser>();
      _myFollowing = results.length > 1 ? (results[1] as List).cast<FollowUser>() : [];
      _loadingFollow = false;
    });
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _loadCommunities);
  }

  Future<void> _toggleFollow(FollowUser user) async {
    // Optimistic update
    setState(() => user.isFollowing = !user.isFollowing);
    final newState = await FollowCommunityService.toggleFollow(user.id);
    if (!mounted) return;
    setState(() => user.isFollowing = newState);
  }

  Future<void> _toggleCommunity(CommunityModel comm) async {
    if (comm.isMember) {
      // Leave
      final ok = await FollowCommunityService.leaveCommunity(comm.id);
      if (ok && mounted) setState(() => comm.memberStatus = '');
    } else if (comm.isPending) {
      // Cancel request
      final ok = await FollowCommunityService.leaveCommunity(comm.id);
      if (ok && mounted) setState(() => comm.memberStatus = '');
    } else {
      // Join
      final status = await FollowCommunityService.joinCommunity(comm.id, isPrivate: comm.isPrivate);
      if (mounted) setState(() => comm.memberStatus = status);
    }
    _loadCommunities();
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
                  _buildCommunitiesTab(),
                  _buildFollowingTab(),
                  _buildSuggestionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
        boxShadow: [AppColors.cellShadow],
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
                    'Community Hub',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Connect · Join · Grow',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              BouncingTap(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SearchScreen(initialCategory: SearchCategory.communities),
                )),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tab Bar
          TabBar(
            controller: _tabController,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColors.primary, width: 2.5),
              insets: EdgeInsets.symmetric(horizontal: 12),
            ),
            dividerColor: Colors.transparent,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13.5),
            tabs: const [
              Tab(text: 'Communities'),
              Tab(text: 'Following'),
              Tab(text: 'Discover'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Communities ─────────────────────────────────────────────────────
  Widget _buildCommunitiesTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadCommunities,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _SearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          // Sport Filter Chips
          SliverToBoxAdapter(
            child: _SportFilterRow(
              sports: _sports,
              selected: _selectedSport,
              onSelect: (s) {
                setState(() => _selectedSport = s);
                _loadCommunities();
              },
            ),
          ),
          if (_loadingCommunities)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else ...[
            // My Communities section
            if (_myCommunities.isNotEmpty) ...[
              _SectionHeader(title: 'My Communities', count: _myCommunities.length),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CommunityCard(
                        community: _myCommunities[i],
                        onToggle: () => _toggleCommunity(_myCommunities[i]),
                      ),
                    ),
                    childCount: _myCommunities.length,
                  ),
                ),
              ),
            ],
            // All Communities
            _SectionHeader(
              title: _myCommunities.isEmpty ? 'Explore Communities' : 'All Communities',
              count: _allCommunities.length,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: _allCommunities.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyState(message: 'No communities found'))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CommunityCard(
                            community: _allCommunities[i],
                            onToggle: () => _toggleCommunity(_allCommunities[i]),
                          ),
                        ),
                        childCount: _allCommunities.length,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tab 2: Following ───────────────────────────────────────────────────────
  Widget _buildFollowingTab() {
    if (_loadingFollow) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_myFollowing.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadFollowData,
        child: ListView(
          children: [
            const SizedBox(height: 60),
            const _EmptyState(
              message: 'You\'re not following anyone yet',
              icon: Icons.people_outline_rounded,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadFollowData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _myFollowing.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _FollowUserCard(
            user: _myFollowing[i],
            onToggle: () => _toggleFollow(_myFollowing[i]),
          ),
        ),
      ),
    );
  }

  // ── Tab 3: Discover / Suggestions ─────────────────────────────────────────
  Widget _buildSuggestionsTab() {
    if (_loadingFollow && _followSuggestions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          // Who to Follow section
          if (_followSuggestions.isNotEmpty) ...[
            _buildSectionTitle('People to Follow', Icons.person_add_rounded, AppColors.primary),
            const SizedBox(height: 10),
            ..._followSuggestions.map((u) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FollowUserCard(user: u, onToggle: () => _toggleFollow(u)),
                )),
            const SizedBox(height: 20),
          ],
          // Community Suggestions
          _buildSectionTitle('Communities You\'ll Love', Icons.groups_rounded, AppColors.brandPurple),
          const SizedBox(height: 10),
          if (_allCommunities.isEmpty)
            const _EmptyState(message: 'No community suggestions yet')
          else
            ..._allCommunities
                .where((c) => !c.isMember)
                .take(6)
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CommunityCard(
                        community: c,
                        onToggle: () => _toggleCommunity(c),
                        showJaccard: true,
                      ),
                    )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CommunityCard extends StatefulWidget {
  final CommunityModel community;
  final VoidCallback onToggle;
  final bool showJaccard;

  const _CommunityCard({
    required this.community,
    required this.onToggle,
    this.showJaccard = false,
  });

  @override
  State<_CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<_CommunityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    _pulse.reverse().then((_) => _pulse.forward());
    setState(() => _loading = true);
    await Future.microtask(widget.onToggle);
    if (mounted) setState(() => _loading = false);
  }

  Color get _sportColor {
    final sport = widget.community.sportTags.isNotEmpty ? widget.community.sportTags.first : 'cricket';
    return AppColors.sportColor(sport);
  }

  @override
  Widget build(BuildContext context) {
    final comm = widget.community;
    final isMember = comm.isMember;
    final isPending = comm.isPending;

    return ScaleTransition(
      scale: _pulse,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isMember ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFE5E5E5),
            width: isMember ? 1.5 : 1.0,
          ),
          boxShadow: const [AppColors.cellShadow],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _sportColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: comm.avatarUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(comm.avatarUrl, fit: BoxFit.cover, width: 52, height: 52),
                    )
                  : Text(
                      _sportEmoji(comm.sportTags.isNotEmpty ? comm.sportTags.first : 'cricket'),
                      style: const TextStyle(fontSize: 24),
                    ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comm.name,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (comm.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified_rounded, color: AppColors.primary, size: 15),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.people_rounded, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${_formatCount(comm.membersCount)} members',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      if (comm.sportTags.isNotEmpty) ...[
                        const Text(' · ', style: TextStyle(color: Color(0xFFCBD5E1))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _sportColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            comm.sportTags.first,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _sportColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.showJaccard && comm.jaccardScore > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'Match score: ${(comm.jaccardScore * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Join/Leave button
            BouncingTap(
              onTap: _onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isMember
                      ? null
                      : (isPending ? null : AppColors.primaryGradient),
                  color: isMember
                      ? const Color(0xFFF1F5F9)
                      : (isPending ? AppColors.primaryLight : null),
                  borderRadius: BorderRadius.circular(30),
                  border: isMember ? Border.all(color: const Color(0xFFE2E8F0)) : null,
                ),
                child: _loading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: isMember ? AppColors.textMuted : Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isMember ? 'Joined' : (isPending ? 'Pending' : (comm.isPrivate ? 'Request' : 'Join')),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isMember ? AppColors.textSecondary : (isPending ? AppColors.primary : Colors.white),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sportEmoji(String sport) {
    switch (sport) {
      case 'football': return '⚽';
      case 'basketball': return '🏀';
      case 'tennis': return '🎾';
      default: return '🏏';
    }
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOLLOW USER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _FollowUserCard extends StatefulWidget {
  final FollowUser user;
  final VoidCallback onToggle;

  const _FollowUserCard({required this.user, required this.onToggle});

  @override
  State<_FollowUserCard> createState() => _FollowUserCardState();
}

class _FollowUserCardState extends State<_FollowUserCard> {
  bool _loading = false;

  Future<void> _onTap() async {
    setState(() => _loading = true);
    await Future.microtask(widget.onToggle);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final sportColor = AppColors.sportColor(u.primarySport);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: const [AppColors.cellShadow],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: u.avatarUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(u.avatarUrl, width: 48, height: 48, fit: BoxFit.cover),
                      )
                    : Text(
                        u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              // Sport badge dot
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: sportColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.fullName,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '@${u.username}',
                  style: GoogleFonts.outfit(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
                if (u.followersCount > 0 || u.mutualCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        if (u.followersCount > 0)
                          Text(
                            '${_fmt(u.followersCount)} followers',
                            style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                        if (u.mutualCount > 0) ...[
                          if (u.followersCount > 0)
                            const Text(' · ', style: TextStyle(color: Color(0xFFCBD5E1))),
                          Text(
                            '${u.mutualCount} mutual',
                            style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Follow/Unfollow button
          BouncingTap(
            onTap: _onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: u.isFollowing ? null : AppColors.primaryGradient,
                color: u.isFollowing ? const Color(0xFFF1F5F9) : null,
                borderRadius: BorderRadius.circular(30),
                border: u.isFollowing ? Border.all(color: const Color(0xFFE2E8F0)) : null,
              ),
              child: _loading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: u.isFollowing ? AppColors.textMuted : Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          u.isFollowing ? Icons.check_rounded : Icons.person_add_rounded,
                          size: 14,
                          color: u.isFollowing ? AppColors.textSecondary : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          u.isFollowing ? 'Following' : 'Follow',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: u.isFollowing ? AppColors.textSecondary : Colors.white,
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

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search communities…',
          hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _SportFilterRow extends StatelessWidget {
  final List<String> sports;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SportFilterRow({required this.sports, required this.selected, required this.onSelect});

  static const _labels = {
    'all': 'All',
    'cricket': '🏏 Cricket',
    'football': '⚽ Football',
    'basketball': '🏀 Basketball',
    'tennis': '🎾 Tennis',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: sports.length,
        separatorBuilder: (ctx2, i2) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final s = sports[i];
          final isSelected = s == selected;
          return BouncingTap(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE5E5E5),
                ),
              ),
              child: Text(
                _labels[s] ?? s,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({
    required this.message,
    this.icon = Icons.search_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
