import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../home/home_screen.dart';

// ─── Cinematic Motion Graphics Intro Screen (Pure Logo & Brand Name) ─────────

class SplashScreen extends StatefulWidget {
  final bool? forceFirstTime;
  const SplashScreen({super.key, this.forceFirstTime});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Motion graphics animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;

  late Animation<double> _auraScale;
  late Animation<double> _auraOpacity;

  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _letterSpacing;
  late Animation<double> _shimmerSweep;

  Timer? _navTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initMotionGraphics();
    _startFlow();
  }

  void _initMotionGraphics() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 1. Hero Logo: Spring bounce scale (starts small, punches in with elastic overshoot)
    _logoScale = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.04, 0.52, curve: Curves.easeOutBack),
      ),
    );

    // 2. Hero Logo: Dynamic 3D rotation damping (-12 deg to 0 deg)
    _logoRotation = Tween<double>(begin: -0.20, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.04, 0.48, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Hero Logo: Fade in
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );

    // 4. Ambient Energy Aura behind logo: Expands and breathes
    _auraScale = Tween<double>(begin: 0.3, end: 1.35).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.65, curve: Curves.easeOutQuad),
      ),
    );

    _auraOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.38), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.38, end: 0.10), weight: 65),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.90, curve: Curves.easeInOut),
      ),
    );

    // 5. Brand Typography: Staggered entrance glide up
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.45), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.60, curve: Curves.easeOut),
      ),
    );

    // 6. Letter Spacing: Dynamic tracking expanding then snapping into locked stance
    _letterSpacing = Tween<double>(begin: 6.0, end: 2.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 7. Shimmer Sweep: Golden light beam running across typography
    _shimmerSweep = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.95, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  void _startFlow() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext(delayMs: 0);
      }
    });
  }

  void _navigateNext({int delayMs = 0}) {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    void performNav() {
      if (!mounted) return;
      final appState = context.read<AppState>();

      if (appState.isLoggedIn) {
        // Direct to app shell if logged in
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (ctx, anim1, anim2) => const MainShell(),
            transitionsBuilder: (ctx, anim, secAnim, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      } else {
        // Direct to login screen if not logged in
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (ctx, anim1, anim2) => const LoginScreen(),
            transitionsBuilder: (ctx, anim, secAnim, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    }

    if (delayMs > 0) {
      _navTimer?.cancel();
      _navTimer = Timer(Duration(milliseconds: delayMs), performNav);
    } else {
      performNav();
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _navigateNext(delayMs: 0),
        child: SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient Dynamic Energy Aura (Soft bloom behind logo)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final auraOpacity = _auraOpacity.value;
                  final auraScale = _auraScale.value;
                  return Transform.scale(
                    scale: auraScale,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: auraOpacity),
                            const Color(0xFFFFB74D).withValues(alpha: auraOpacity * 0.45),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Motion Graphics: Logo & Brand Name ONLY
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hero Logo with elastic punch-in and rotation damping
                      Transform.rotate(
                        angle: _logoRotation.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: const AppLogo(
                              size: 116,
                              showContainer: false,
                              showShadow: true,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Brand Typography with glide-up, dynamic tracking and shimmer sweep
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (bounds) {
                              final sweep = _shimmerSweep.value;
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: const [
                                  Colors.white,
                                  Color(0xFFFFD54F),
                                  Colors.white,
                                ],
                                stops: [
                                  (sweep - 0.25).clamp(0.0, 1.0),
                                  sweep.clamp(0.0, 1.0),
                                  (sweep + 0.25).clamp(0.0, 1.0),
                                ],
                              ).createShader(bounds);
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'WORLD',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF0F172A),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: _letterSpacing.value,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'SPORTS',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.primary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: _letterSpacing.value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Professional Welcome Intro (Onboarding Screen) ─────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'tag': 'MULTI-SPORT ATHLETE PASSPORT',
      'title': 'One Verified Passport\nFor All Your Sports',
      'subtitle':
          'Whether you bowl in Cricket, strike in Football, hoop in Basketball, or smash in Tennis — track all career stats, honors & squad rankings in one verified hub.',
      'type': 'passport',
    },
    {
      'tag': 'REAL-TIME MATCH ENGINE',
      'title': 'Ball-by-Ball Scoring\n& Smart Telemetry',
      'subtitle':
          'Experience live digital scoreboards, wagon wheels, shot charts, momentum meters, and broadcast-grade summaries tailored for athletes and scouts.',
      'type': 'scoring',
    },
    {
      'tag': 'SANCTIONED LEAGUES & SCOUTING',
      'title': 'Compete in Sanctioned Cups\n& Climb Global Ranks',
      'subtitle':
          'Enter verified league brackets, assemble championship rosters, get scouted by licensed coaches, and engrave your name on the hall of fame.',
      'type': 'tournaments',
    },
  ];

  void _finishOnboarding() async {
    final nav = Navigator.of(context);
    await context.read<AppState>().setHasSeenOnboarding(true);
    if (!mounted) return;
    nav.pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (ctx, anim1, anim2) => const LoginScreen(),
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 36, showContainer: true),
                      const SizedBox(width: 10),
                      Text(
                        'WORLDSPORTS',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'Skip Intro',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Interactive Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Interactive Preview Graphic Card
                        _buildSlideVisual(s['type'] as String),
                        const SizedBox(height: 28),

                        // Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            s['tag'] as String,
                            style: GoogleFonts.outfit(
                              color: AppColors.primaryDark,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          s['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          s['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Actions & Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: Column(
                children: [
                  // Smooth Indicator Pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 30 : 8,
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: _currentPage == i ? AppColors.primaryGradient : null,
                          color: _currentPage == i ? null : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        InkWell(
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 50,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _slides.length - 1) {
                              _finishOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _slides.length - 1
                                    ? 'ENTER THE ARENA'
                                    : 'CONTINUE',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _slides.length - 1
                                    ? Icons.sports_score_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Direct Login Link
                  GestureDetector(
                    onTap: _finishOnboarding,
                    child: RichText(
                      text: TextSpan(
                        text: "Already registered athlete? ",
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In to Arena',
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSlideVisual(String type) {
    switch (type) {
      case 'passport':
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arjun Sharma',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'SANCTIONED ATHLETE • #829',
                          style: GoogleFonts.outfit(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.5,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'VERIFIED',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF10B981),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // 4 Sports Badges in 2 clean responsive rows
              Row(
                children: [
                  Expanded(child: _buildSportMiniStat('🏏 Cricket', '1,842 Runs')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSportMiniStat('⚽ Football', '34 Goals')),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: _buildSportMiniStat('🏀 Basketball', '18.4 PPG')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSportMiniStat('🎾 Tennis', '75% Win')),
                ],
              ),
            ],
          ),
        );

      case 'scoring':
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'LIVE MATCH DAY • FINAL OVER',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'T20 LEAGUE',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '168 / 3',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '18.4 OVERS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Need 14 off 8 balls',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CRR 8.94 • REQ 10.5',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'tournaments':
      default:
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  gradient: AppColors.championshipGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                'Premier Championship 2026',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 15.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '64 Sanctioned Teams • Gold Cup Finalist',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '120+ Verified Scouts Attending',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 11,
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
        );
    }
  }

  Widget _buildSportMiniStat(String label, String stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            stat,
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Professional Login Screen (Arena Access) ────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.player;
  final _emailController = TextEditingController(text: 'arjun@worldsports.com');
  final _passController = TextEditingController(text: 'password');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      switch (role) {
        case UserRole.player:
          _emailController.text = 'arjun@worldsports.com';
          break;
        case UserRole.coach:
          _emailController.text = 'priya@worldsports.com';
          break;
        case UserRole.organiser:
          _emailController.text = 'vikram@worldsports.com';
          break;
      }
    });
  }

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;

    final appState = context.read<AppState>();
    UserModel user;
    switch (_selectedRole) {
      case UserRole.player:
        user = MockData.demoPlayer;
        break;
      case UserRole.coach:
        user = MockData.demoCoach;
        break;
      case UserRole.organiser:
        user = MockData.demoOrganiser;
        break;
    }
    appState.login(user);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (ctx, anim1, anim2) => const MainShell(),
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // Top Brand Emblem Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogo(
                        size: 42,
                        showContainer: true,
                        showShadow: true,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WORLDSPORTS',
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'ATHLETIC WORLD',
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.lock_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Welcome Title
              Text(
                'Welcome Back, Athlete',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to access your athletic world, squads & live fixtures',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Segmented Athlete Profile Type Selector (Professional, Compact, Clean)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildSegmentTab(
                      role: UserRole.player,
                      label: 'Athlete',
                      icon: Icons.sports_kabaddi_rounded,
                    ),
                    _buildSegmentTab(
                      role: UserRole.coach,
                      label: 'Coach',
                      icon: Icons.sports_score_rounded,
                    ),
                    _buildSegmentTab(
                      role: UserRole.organiser,
                      label: 'Organiser',
                      icon: Icons.emoji_events_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Input Fields Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATHLETE CREDENTIALS',
                      style: GoogleFonts.outfit(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Athlete Email or Passport ID',
                        labelStyle: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.alternate_email_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password Field
                    TextField(
                      controller: _passController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Security Password',
                        labelStyle: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (v) => setState(() => _rememberMe = v ?? true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: GoogleFonts.outfit(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // SPECIFIC DECIDED LOADING AREA (Loading only shown in decided blank area)
                    if (_isLoading)
                      SpecificAreaLoader(
                        height: 100,
                        width: double.infinity,
                        ballSize: 20,
                        backgroundColor: const Color(0xFFF8FAFC),
                        showBorder: true,
                        title: 'AUTHENTICATING ATHLETIC WORLD',
                        subtitle: 'Synchronizing ${_getRoleTitle(_selectedRole)} with Arena...',
                      )
                    else
                      GradientButton(
                        label: 'ENTER THE ARENA',
                        width: double.infinity,
                        icon: Icons.login_rounded,
                        onTap: _login,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Social Sign-in Divider
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or fast connect with',
                      style: GoogleFonts.outfit(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Social Buttons
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      label: 'Google Athlete',
                      icon: Icons.g_mobiledata_rounded,
                      onTap: _login,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SocialButton(
                      label: 'Apple Sports ID',
                      icon: Icons.apple_rounded,
                      onTap: _login,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // New Athlete Registration
              Center(
                child: GestureDetector(
                  onTap: _login,
                  child: RichText(
                    text: TextSpan(
                      text: "New athlete? ",
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Claim Your Athlete Profile',
                          style: GoogleFonts.outfit(
                            color: AppColors.primary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Compliance Footer
              Center(
                child: Text(
                  '🔒 Sanctioned Multi-Sport Network • Official Arena Federation',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.player:
        return 'Athlete';
      case UserRole.coach:
        return 'Coach';
      case UserRole.organiser:
        return 'League Organiser';
    }
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
