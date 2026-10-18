import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/models/models.dart';
import '../core/state/app_state.dart';
import 'common_widgets.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/match/match_creation_screen.dart';
import '../screens/tournaments/tournaments_screen.dart';
import '../screens/teams/teams_screen.dart';
import '../core/services/search_service.dart';
import '../screens/search/search_screen.dart';

/// Professional, top-tier executive sidebar drawer.
/// Styled according to high-performance sports brand design psychology:
/// - Palette: Ground Green (AppColors.primary), Pure White, Deep Black & Slate Grey.
/// - Clean, monochrome vector icons without multi-colored box backgrounds.
/// - Direct, clear navigation titles without cluttered descriptions.
/// - Sport-specific colors reserved exclusively for sport tags/chips.
class ArenaDrawer extends StatelessWidget {
  const ArenaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width > 420
          ? 340
          : MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            // ─── Header: Sleek Brand Identity & Close ───────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogo(
                        size: 34,
                        showContainer: true,
                        showShadow: true,
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'WORLD',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            TextSpan(
                              text: 'SPORTS',
                              style: GoogleFonts.outfit(
                                color: AppColors.primary,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ─── Scrollable Menu ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Athlete Profile Row
                    _buildAthleteProfileCard(context, user),
                    const SizedBox(height: 18),

                    // SECTION 1: COMPETITION
                    _buildSectionHeader('COMPETITION'),
                    const SizedBox(height: 6),

                    // 1. START MATCH (Primary action with subtle ground green badge)
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.play_circle_outline_rounded,
                      title: 'Start Match',
                      isPrimary: true,
                      badgeText: 'LIVE',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateMatchScreen()),
                        );
                      },
                    ),

                    // 2. ADD A TOURNAMENT / SERIES
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.emoji_events_outlined,
                      title: 'Add a Tournament / Series',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showCreateTournamentModal(context);
                      },
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                    const SizedBox(height: 14),

                    // SECTION 2: NETWORK & GEAR
                    _buildSectionHeader('EXPLORE & NETWORK'),
                    const SizedBox(height: 6),

                    // 3. STORE
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.storefront_outlined,
                      title: 'Store',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showStoreModal(context);
                      },
                    ),

                    // 4. LEADERBOARD
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.leaderboard_outlined,
                      title: 'Leaderboard',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showLeaderboardModal(context);
                      },
                    ),

                    // 5. CLUBS
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.shield_outlined,
                      title: 'Clubs',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showClubsModal(context);
                      },
                    ),

                    // 6. ASSOCIATIONS
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.account_balance_outlined,
                      title: 'Associations',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showAssociationsModal(context);
                      },
                    ),

                    // 7. GROUNDS
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.stadium_outlined,
                      title: 'Grounds',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showGroundsModal(context);
                      },
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                    const SizedBox(height: 14),

                    // SECTION 3: SUPPORT & SHARE
                    _buildSectionHeader('SUPPORT & COMMUNITY'),
                    const SizedBox(height: 6),

                    // 8. HELP & SUPPORT
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showHelpModal(context);
                      },
                    ),

                    // 9. SHARE OPTIONS
                    _buildDrawerRow(
                      context: context,
                      icon: Icons.share_outlined,
                      title: 'Share Options',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showShareOptionsModal(context);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Testing Utilities (Monochrome, subtle)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QUICK DEMO LOADERS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF64748B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SplashScreen(forceFirstTime: true),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'First-Time Loader',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SplashScreen(forceFirstTime: false),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Revisit Loader',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Log Out Row
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _showLogoutConfirmDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
                            const SizedBox(width: 14),
                            Text(
                              'Log Out',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Footer Version Stamp
                    Center(
                      child: Text(
                        'WorldSports Platform • v2.4.0',
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthleteProfileCard(BuildContext context, UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          UserAvatar(
            name: user?.name ?? 'Athlete',
            radius: 18,
            showProRing: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user?.name ?? 'Athlete',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: AppColors.primary, size: 15),
                  ],
                ),
                Text(
                  '@${user?.username ?? 'athlete'} • Div 1 Pro',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          BouncingTap(
            onTap: () {
              Navigator.of(context).pop();
              context.read<AppState>().setBottomNavIndex(3);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'PROFILE',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF64748B),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  /// Clean, description-free, monochrome sidebar item.
  Widget _buildDrawerRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    bool isPrimary = false,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: const Color(0xFFF1F5F9),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isPrimary ? AppColors.primary : const Color(0xFF0F172A),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Log Out of WorldSports?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to log out? Your stats and match records remain safely saved.',
          style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
              context.read<AppState>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SplashScreen(forceFirstTime: false)),
              );
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODALS WITH GROUND GREEN + MONOCHROME BRANDING
  // ═══════════════════════════════════════════════════════════════════════════

  void _showCreateTournamentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateTournamentBottomSheet(),
    );
  }

  void _showStoreModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _WorldSportsStoreBottomSheet(),
    );
  }

  void _showLeaderboardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _LeaderboardBottomSheet(),
    );
  }

  void _showClubsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ClubsDirectoryBottomSheet(),
    );
  }

  void _showAssociationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AssociationsBottomSheet(),
    );
  }

  void _showGroundsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _GroundsDirectoryBottomSheet(),
    );
  }

  void _showHelpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _HelpSupportBottomSheet(),
    );
  }

  void _showShareOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ShareOptionsBottomSheet(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 2. CREATE TOURNAMENT (Ground Green Theme, Sport-Specific Chips)
// ═════════════════════════════════════════════════════════════════════════════

class _CreateTournamentBottomSheet extends StatefulWidget {
  @override
  State<_CreateTournamentBottomSheet> createState() => _CreateTournamentBottomSheetState();
}

class _CreateTournamentBottomSheetState extends State<_CreateTournamentBottomSheet> {
  final _nameCtrl = TextEditingController(text: 'Mumbai Premier Champions Trophy');
  final _venueCtrl = TextEditingController(text: 'Wankhede Arena, Mumbai');
  final _prizePoolCtrl = TextEditingController(text: '₹2,50,000');
  SportType _selectedSport = SportType.cricket;
  String _selectedFormat = 'Knockout';
  int _teamsCount = 8;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _venueCtrl.dispose();
    _prizePoolCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildSheetHeader(
            title: 'Add a Tournament / Series',
            subtitle: 'Host an official cup, bilateral series or league',
            icon: Icons.emoji_events_outlined,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sport Selection: SPORT-SPECIFIC COLORS APPLIED HERE
                  _buildFormLabel('SELECT SPORT'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSportOption(SportType.cricket, 'Cricket', Icons.sports_cricket_rounded, AppColors.cricket),
                      const SizedBox(width: 8),
                      _buildSportOption(SportType.football, 'Football', Icons.sports_soccer_rounded, AppColors.football),
                      const SizedBox(width: 8),
                      _buildSportOption(SportType.basketball, 'Basketball', Icons.sports_basketball_rounded, AppColors.basketball),
                      const SizedBox(width: 8),
                      _buildSportOption(SportType.tennis, 'Tennis', Icons.sports_tennis_rounded, AppColors.tennis),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Tournament Title
                  _buildFormLabel('TOURNAMENT / SERIES TITLE'),
                  const SizedBox(height: 8),
                  _buildInputField(_nameCtrl, 'e.g. Maharashtra Monsoon Cup 2026', Icons.emoji_events_outlined),
                  const SizedBox(height: 18),

                  // Format
                  _buildFormLabel('COMPETITION FORMAT'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFormatChip('Knockout'),
                      _buildFormatChip('League / Round Robin'),
                      _buildFormatChip('Groups + Playoffs'),
                      _buildFormatChip('Bilateral Series (3-5 Matches)'),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Teams Count
                  _buildFormLabel('NUMBER OF COMPETING TEAMS'),
                  const SizedBox(height: 8),
                  Row(
                    children: [4, 8, 12, 16, 32].map((count) {
                      final isSel = _teamsCount == count;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _teamsCount = count),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$count',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: isSel ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Prize Pool & Venue
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('PRIZE POOL'),
                            const SizedBox(height: 8),
                            _buildInputField(_prizePoolCtrl, '₹1,00,000', Icons.currency_rupee_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('HOST VENUE / CITY'),
                            const SizedBox(height: 8),
                            _buildInputField(_venueCtrl, 'City or Stadium', Icons.location_on_outlined),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Publish Button in Ground Green
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final newTourn = TournamentModel(
                          id: 'tr_${DateTime.now().millisecondsSinceEpoch}',
                          name: _nameCtrl.text.trim().isEmpty ? 'WorldSports Series' : _nameCtrl.text.trim(),
                          sport: _selectedSport,
                          organiserId: 'u001',
                          startDate: DateTime.now().add(const Duration(days: 3)),
                          endDate: DateTime.now().add(const Duration(days: 14)),
                          location: _venueCtrl.text.trim(),
                          teamsCount: _teamsCount,
                          format: _selectedFormat,
                          prizePool: _prizePoolCtrl.text.trim(),
                          status: MatchStatus.upcoming,
                        );

                        MockData.tournaments.insert(0, newTourn);

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Tournament "${newTourn.name}" created successfully!',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TournamentsScreen()),
                        );
                      },
                      child: Text(
                        'PUBLISH TOURNAMENT',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
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

  Widget _buildSportOption(SportType sport, String label, IconData icon, Color sportColor) {
    final isSel = _selectedSport == sport;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSport = sport),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? sportColor.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? sportColor : const Color(0xFFE2E8F0),
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? sportColor : const Color(0xFF64748B), size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
                  color: isSel ? sportColor : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatChip(String format) {
    final isSel = _selectedFormat == format;
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = format),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primary : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          format,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
            color: isSel ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 3. STORE (Clean Gear Cards, Ground Green Pricing)
// ═════════════════════════════════════════════════════════════════════════════

class _WorldSportsStoreBottomSheet extends StatefulWidget {
  const _WorldSportsStoreBottomSheet();

  @override
  State<_WorldSportsStoreBottomSheet> createState() => _WorldSportsStoreBottomSheetState();
}

class _WorldSportsStoreBottomSheetState extends State<_WorldSportsStoreBottomSheet> {
  int _cartCount = 0;
  String _selectedCategory = 'All Gear';

  final List<Map<String, dynamic>> _products = const [
    {
      'title': 'WorldSports Pro Match Cricket Balls (Box of 6)',
      'category': 'Equipment',
      'price': '₹2,499',
      'original': '₹3,200',
      'rating': '4.9',
      'sport': 'Cricket',
      'icon': Icons.sports_cricket_rounded,
    },
    {
      'title': 'English Willow Grade 1 Master Bat',
      'category': 'Equipment',
      'price': '₹14,999',
      'original': '₹18,500',
      'rating': '5.0',
      'sport': 'Cricket',
      'icon': Icons.sports_cricket_rounded,
    },
    {
      'title': 'AeroShield Athlete Compression Match Jersey',
      'category': 'Kits',
      'price': '₹1,899',
      'original': '₹2,499',
      'rating': '4.8',
      'sport': 'Football',
      'icon': Icons.checkroom_rounded,
    },
    {
      'title': 'SpeedGrip Hybrid Turf & Ground Studs',
      'category': 'Footwear',
      'price': '₹3,799',
      'original': '₹4,999',
      'rating': '4.9',
      'sport': 'Multi-Sport',
      'icon': Icons.directions_run_rounded,
    },
    {
      'title': 'Pro Tour Carbon Tennis Racket + Cover',
      'category': 'Equipment',
      'price': '₹8,999',
      'original': '₹11,000',
      'rating': '4.9',
      'sport': 'Tennis',
      'icon': Icons.sports_tennis_rounded,
    },
    {
      'title': 'Official Microfiber Match Basketball (Size 7)',
      'category': 'Equipment',
      'price': '₹1,799',
      'original': '₹2,299',
      'rating': '4.8',
      'sport': 'Basketball',
      'icon': Icons.sports_basketball_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All Gear'
        ? _products
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildSheetHeader(
            title: 'Store',
            subtitle: 'Official equipment, match kits & athlete gear',
            icon: Icons.storefront_outlined,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_cartCount ITEMS',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 10.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Category Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['All Gear', 'Equipment', 'Kits', 'Footwear'].map((cat) {
                final isSel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final item = filtered[idx];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Icon(item['icon'] as IconData, color: const Color(0xFF0F172A), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  item['price'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item['original'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    decoration: TextDecoration.lineThrough,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                                Text(
                                  ' ${item['rating']}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      BouncingTap(
                        onTap: () {
                          setState(() => _cartCount++);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                'Added "${item['title']}" to bag',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ADD',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 4. LEADERBOARD (Monochrome + Ground Green Accents)
// ═════════════════════════════════════════════════════════════════════════════

class _LeaderboardBottomSheet extends StatefulWidget {
  const _LeaderboardBottomSheet();

  @override
  State<_LeaderboardBottomSheet> createState() => _LeaderboardBottomSheetState();
}

class _LeaderboardBottomSheetState extends State<_LeaderboardBottomSheet> {
  String _scope = 'Division 1 Pro';

  final List<Map<String, dynamic>> _rankings = const [
    {
      'rank': 1,
      'name': 'Arjun Sharma',
      'team': 'Mumbai Mavericks',
      'points': 2840,
      'winRate': '78%',
      'sport': 'Cricket / Football',
    },
    {
      'rank': 2,
      'name': 'Rohit Verma',
      'team': 'Delhi Dynamos',
      'points': 2710,
      'winRate': '74%',
      'sport': 'Cricket',
    },
    {
      'rank': 3,
      'name': 'Kiran Mukherjee',
      'team': 'Bengaluru FC Stars',
      'points': 2650,
      'winRate': '71%',
      'sport': 'Football',
    },
    {
      'rank': 4,
      'name': 'Priya Menon',
      'team': 'Karnataka Aces',
      'points': 2520,
      'winRate': '69%',
      'sport': 'Tennis',
    },
    {
      'rank': 5,
      'name': 'Farhan Khan',
      'team': 'Hyderabad Hawks',
      'points': 2480,
      'winRate': '67%',
      'sport': 'Basketball',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildSheetHeader(
            title: 'Leaderboard',
            subtitle: 'Rankings, rating index & matchday standings',
            icon: Icons.leaderboard_outlined,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ['Division 1 Pro', 'National', 'Top Scorers'].map((s) {
                final isSel = _scope == s;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _scope = s),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Top 3 Podium
          _buildPodiumView(),
          const Divider(height: 16, indent: 20, endIndent: 20, color: Color(0xFFF1F5F9)),
          // Remaining List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: _rankings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, idx) {
                final p = _rankings[idx];
                final isUser = p['name'] == 'Arjun Sharma';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUser ? AppColors.primary : const Color(0xFFE2E8F0),
                      width: isUser ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${p['rank']}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      UserAvatar(name: p['name'], radius: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    p['name'],
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isUser) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'YOU',
                                      style: GoogleFonts.outfit(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '${p['team']} • ${p['sport']}',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${p['points']} pts',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${p['winRate']} win rate',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildPodiumColumn(
              rank: 2,
              name: 'Rohit V.',
              pts: '2,710',
              height: 60,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPodiumColumn(
              rank: 1,
              name: 'Arjun S.',
              pts: '2,840',
              height: 80,
              isFirst: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPodiumColumn(
              rank: 3,
              name: 'Kiran M.',
              pts: '2,650',
              height: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required int rank,
    required String name,
    required String pts,
    required double height,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        UserAvatar(name: name, radius: isFirst ? 18 : 15, showProRing: isFirst),
        const SizedBox(height: 4),
        Text(
          name,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: const Color(0xFF0F172A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          pts,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isFirst ? AppColors.primary.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(
              color: isFirst ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isFirst ? AppColors.primary : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 5. CLUBS (Clean Cards with Sport-Specific Badges)
// ═════════════════════════════════════════════════════════════════════════════

class _ClubsDirectoryBottomSheet extends StatelessWidget {
  const _ClubsDirectoryBottomSheet();

  @override
  Widget build(BuildContext context) {
    final clubs = MockData.clubs;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildSheetHeader(
            title: 'Clubs',
            subtitle: 'Sanctioned sports clubs, athletic academies & squads',
            icon: Icons.shield_outlined,
            trailing: BouncingTap(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(
                      initialCategory: SearchCategory.clubs,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.primary, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      'SEARCH',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              itemCount: clubs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final club = clubs[idx];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: const Icon(Icons.shield_outlined, color: Color(0xFF0F172A), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        club.name,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified_rounded, color: AppColors.primary, size: 15),
                                  ],
                                ),
                                Text(
                                  'Est. ${club.established} • ${club.location}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        club.description,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Sport-specific badges
                          Wrap(
                            spacing: 6,
                            children: club.sports.map((s) {
                              Color sColor;
                              switch (s) {
                                case SportType.cricket:
                                  sColor = AppColors.cricket;
                                  break;
                                case SportType.football:
                                  sColor = AppColors.football;
                                  break;
                                case SportType.basketball:
                                  sColor = AppColors.basketball;
                                  break;
                                case SportType.tennis:
                                  sColor = AppColors.tennis;
                                  break;
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: sColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  s.name.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: sColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const Spacer(),
                          BouncingTap(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TeamsScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'VIEW SQUAD',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 6. ASSOCIATIONS (Clean White Cards, Ground Green Accents)
// ═════════════════════════════════════════════════════════════════════════════

class _AssociationsBottomSheet extends StatelessWidget {
  const _AssociationsBottomSheet();

  final List<Map<String, dynamic>> _associations = const [
    {
      'name': 'Board of Premier Cricket Associations',
      'code': 'BPCA-SANCTIONED',
      'leagues': 24,
      'athletes': '1,400+ Athletes',
      'location': 'Mumbai & Western Division',
      'icon': Icons.sports_cricket_rounded,
    },
    {
      'name': 'National Football Federation Guild',
      'code': 'NFFG-CERTIFIED',
      'leagues': 18,
      'athletes': '980+ Footballers',
      'location': 'Bangalore & South Division',
      'icon': Icons.sports_soccer_rounded,
    },
    {
      'name': 'All India Youth Basketball Council',
      'code': 'AIYBC-DIVISION',
      'leagues': 14,
      'athletes': '650+ Athletes',
      'location': 'National Metropolitan Division',
      'icon': Icons.sports_basketball_rounded,
    },
    {
      'name': 'Lawn Tennis & Racket Sports Federation',
      'code': 'LTRSF-PRO',
      'leagues': 12,
      'athletes': '420+ Competitors',
      'location': 'Grand Prix Circuit Division',
      'icon': Icons.sports_tennis_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildSheetHeader(
            title: 'Associations',
            subtitle: 'Sanctioned governing councils, state federations & licenses',
            icon: Icons.account_balance_outlined,
            trailing: BouncingTap(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(
                      initialCategory: SearchCategory.associations,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.primary, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      'SEARCH',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              itemCount: _associations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final a = _associations[idx];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Icon(a['icon'] as IconData, color: const Color(0xFF0F172A), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a['name'],
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  a['location'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'OFFICIAL',
                              style: GoogleFonts.outfit(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${a['leagues']} Sanctioned Cups',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              a['athletes'],
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'Active Sanction',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            a['code'],
                            style: GoogleFonts.outfit(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    '${a['name']} bylaws handbook opened',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'VIEW BYLAWS',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 7. GROUNDS (Clean White Cards, Ground Green Rates)
// ═════════════════════════════════════════════════════════════════════════════

class _GroundsDirectoryBottomSheet extends StatelessWidget {
  const _GroundsDirectoryBottomSheet();

  final List<Map<String, dynamic>> _grounds = const [
    {
      'name': 'Wankhede Arena & Ground',
      'city': 'Marine Drive, Mumbai',
      'surface': 'Red Clay & Turf Pitch',
      'price': '₹2,500/hr',
      'rating': '4.9',
      'floodlights': true,
      'icon': Icons.sports_cricket_rounded,
    },
    {
      'name': 'Sree Kanteerava Multi-Sport Arena',
      'city': 'Kasturba Road, Bangalore',
      'surface': 'FIFA 2-Star AstroTurf',
      'price': '₹1,800/hr',
      'rating': '4.8',
      'floodlights': true,
      'icon': Icons.sports_soccer_rounded,
    },
    {
      'name': 'Shivaji Park Sports Enclave & Box Turf',
      'city': 'Dadar, Mumbai',
      'surface': 'Heavy Duty Rubber Infill Turf',
      'price': '₹1,200/hr',
      'rating': '4.7',
      'floodlights': true,
      'icon': Icons.stadium_outlined,
    },
    {
      'name': 'DLTA Tennis Arena Complex',
      'city': 'Africa Avenue, New Delhi',
      'surface': '6 Synthetic Hard Courts',
      'price': '₹1,500/hr',
      'rating': '4.9',
      'floodlights': true,
      'icon': Icons.sports_tennis_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildSheetHeader(
            title: 'Grounds',
            subtitle: 'Stadiums, turf pitches & arena slot booking',
            icon: Icons.stadium_outlined,
            trailing: BouncingTap(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(
                      initialCategory: SearchCategory.grounds,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.primary, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      'SEARCH',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              itemCount: _grounds.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final g = _grounds[idx];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Icon(g['icon'] as IconData, color: const Color(0xFF0F172A), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        g['name'],
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                                    Text(
                                      ' ${g['rating']}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  g['city'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              g['surface'],
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          if (g['floodlights'] == true) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'FLOODLIGHTS',
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            g['price'],
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          BouncingTap(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Slot booked at ${g['name']}!',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'BOOK SLOT',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 8. HELP & SUPPORT (Monochrome + Ground Green Accents)
// ═════════════════════════════════════════════════════════════════════════════

class _HelpSupportBottomSheet extends StatelessWidget {
  const _HelpSupportBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildSheetHeader(
            title: 'Help & Support',
            subtitle: 'Rulebooks, match scoring guidelines & dispute desk',
            icon: Icons.help_outline_rounded,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.headset_mic_outlined, color: AppColors.primary, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              'Live Support',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              'Instant chat desk',
                              style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              'Rulebooks',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              '4 Sports Standards',
                              style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'FREQUENTLY ASKED QUESTIONS',
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFaqTile(
                  question: 'How do I start and score a live match?',
                  answer:
                      'Tap "Start Match" in the sidebar, choose your sport, configure squads, overs, toss, and you enter the live scoring console.',
                ),
                _buildFaqTile(
                  question: 'Can I add custom players or international rosters?',
                  answer:
                      'Yes, you can choose from the built-in real athletes catalog or create squad members with custom jersey numbers and roles.',
                ),
                _buildFaqTile(
                  question: 'How do rain interruptions and reduced overs work?',
                  answer:
                      'Open Match Settings during a live game to adjust total overs or declare innings. Target calculations will automatically re-calibrate.',
                ),
                _buildFaqTile(
                  question: 'How do I register my club or host a sanctioned tournament?',
                  answer:
                      'Tap "Add a Tournament / Series" from the sidebar to publish a cup and invite teams, or browse "Clubs" to affiliate your roster.',
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Direct Athlete Helpline',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'support@worldsports.app • +91 1800-SPORTS',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
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
    );
  }

  static Widget _buildFaqTile({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              answer,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 9. SHARE OPTIONS (Clean, Monochrome Channels + Ground Green Copy)
// ═════════════════════════════════════════════════════════════════════════════

class _ShareOptionsBottomSheet extends StatelessWidget {
  const _ShareOptionsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              _buildSheetHeader(
                title: 'Share Options',
                subtitle: 'Invite teammates, clubs and competitors',
                icon: Icons.share_outlined,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareChannel(
                    context: context,
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                  ),
                  _buildShareChannel(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    label: 'Instagram',
                  ),
                  _buildShareChannel(
                    context: context,
                    icon: Icons.alternate_email_rounded,
                    label: 'Twitter / X',
                  ),
                  _buildShareChannel(
                    context: context,
                    icon: Icons.qr_code_2_rounded,
                    label: 'QR Code',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, color: Color(0xFF64748B), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'https://worldsports.app/invite/athlete_pro',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    BouncingTap(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Invite link copied to clipboard!',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'COPY',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildShareChannel({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return BouncingTap(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Shared WorldSports via $label!',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, color: const Color(0xFF0F172A), size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REUSABLE SHEET HELPERS (Strict Monochrome + Ground Green)
// ═════════════════════════════════════════════════════════════════════════════

Widget _buildDragHandle() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    width: 32,
    height: 4,
    decoration: BoxDecoration(
      color: const Color(0xFFCBD5E1),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

Widget _buildSheetHeader({
  required String title,
  required String subtitle,
  required IconData icon,
  Widget? trailing,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

Widget _buildFormLabel(String label) {
  return Text(
    label,
    style: GoogleFonts.outfit(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF64748B),
      letterSpacing: 0.8,
    ),
  );
}

Widget _buildInputField(TextEditingController ctrl, String hint, IconData icon) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: TextField(
      controller: ctrl,
      style: GoogleFonts.outfit(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  );
}
