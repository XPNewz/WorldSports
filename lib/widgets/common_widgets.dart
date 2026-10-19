import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
export 'app_logo.dart';
export 'sports_balls_loader.dart';

// ─── Playful Sport Icon Badge ─────────────────────────────────────────────────

class SportBadge extends StatelessWidget {
  final SportType sport;
  final bool showLabel;
  final double size;

  const SportBadge({
    super.key,
    required this.sport,
    this.showLabel = true,
    this.size = 32,
  });

  static IconData _icon(SportType s) {
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

  static String _label(SportType s) {
    switch (s) {
      case SportType.cricket:
        return 'Cricket';
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.tennis:
        return 'Tennis';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.sportColor(sport.name);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 10 : 7,
        vertical: showLabel ? 4.5 : 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(sport), color: Colors.white, size: size * 0.55),
          if (showLabel) ...[
            const SizedBox(width: 5),
            Text(
              _label(sport).toUpperCase(),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── High Performance Interactive Bouncing Tap Effect ────────────────────────

class BouncingTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const BouncingTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.96,
  });

  @override
  State<BouncingTap> createState() => _BouncingTapState();
}

class _BouncingTapState extends State<BouncingTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ─── Professional Live Indicator with RepaintBoundary ────────────────────────

class LiveIndicator extends StatefulWidget {
  final String label;
  const LiveIndicator({super.key, this.label = 'LIVE'});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.live.withValues(alpha: _animation.value),
                width: 1.2,
              ),
              
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.live,
                    shape: BoxShape.circle,
                    
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: GoogleFonts.outfit(
                    color: AppColors.live,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Playful Athletic Tag ─────────────────────────────────────────────────────

class AthleticTag extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool isFilled;

  const AthleticTag({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? c : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFilled ? c : AppColors.cardBorder,
          width: 1,
        ),
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: isFilled ? Colors.white : c, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              color: isFilled ? Colors.white : AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Playful Gradient Button ──────────────────────────────────────────────────

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? textColor;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient,
    this.width,
    this.height = 52,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? AppColors.primaryGradient;

    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.97,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: g,
          borderRadius: BorderRadius.circular(16),
          
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                color: textColor ?? Colors.white,
                fontSize: 15.5,
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

// ─── Playful User Avatar with Cheerful Ring ───────────────────────────────────

class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final Color? color;
  final bool showProRing;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
    this.color,
    this.showProRing = true,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final ringGrad = showProRing
        ? AppColors.multiColorGradient
        : const LinearGradient(colors: [Colors.transparent, Colors.transparent]);

    return Container(
      padding: EdgeInsets.all(showProRing ? 2.5 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: ringGrad,
        
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color ?? AppColors.primaryLight,
        child: Text(
          initials,
          style: GoogleFonts.outfit(
            color: color != null ? Colors.white : AppColors.primary,
            fontSize: radius * 0.65,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ─── Professional Section Header ──────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final Color? accentColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (accentColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor ?? AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (actionLabel != null)
          BouncingTap(
            onTap: onAction ?? () {},
            child: Row(
              children: [
                Text(
                  actionLabel!,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 10,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Playful Stat Card ────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;
  final String? trend;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.icon,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: c.withValues(alpha: 0.2),
          width: 1.2,
        ),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: c, size: 20),
                ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend!,
                    style: GoogleFonts.outfit(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Playful Sports Card (Crisp White + Soft Shadow) ──────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? borderColor;
  final LinearGradient? backgroundGradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 22,
    this.borderColor,
    this.backgroundGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundGradient == null ? Colors.white : null,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder,
          width: 1.2,
        ),
        
      ),
      child: child,
    );

    if (onTap != null) {
      return BouncingTap(onTap: onTap, scaleFactor: 0.98, child: content);
    }
    return content;
  }
}

// ─── Playful Team Crest Shield ────────────────────────────────────────────────

class TeamCrest extends StatelessWidget {
  final String shortName;
  final Color color;
  final double size;

  const TeamCrest({
    super.key,
    required this.shortName,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        shortName.take(3),
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

extension StringTake on String {
  String take(int n) => length <= n ? this : substring(0, n);
}

// ─── Playful Momentum Bar ─────────────────────────────────────────────────────

class MomentumBar extends StatelessWidget {
  final double team1Ratio;
  final Color team1Color;
  final Color team2Color;
  final String team1Label;
  final String team2Label;

  const MomentumBar({
    super.key,
    required this.team1Ratio,
    required this.team1Color,
    required this.team2Color,
    this.team1Label = '',
    this.team2Label = '',
  });

  @override
  Widget build(BuildContext context) {
    final t1Percent = (team1Ratio * 100).toInt();
    final t2Percent = 100 - t1Percent;

    return Column(
      children: [
        if (team1Label.isNotEmpty || team2Label.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$team1Label $t1Percent%',
                style: GoogleFonts.outfit(
                  color: team1Color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'MATCH CONTROL',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                '$t2Percent% $team2Label',
                style: GoogleFonts.outfit(
                  color: team2Color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 7,
            color: AppColors.surfaceLighter,
            child: Row(
              children: [
                Expanded(
                  flex: (team1Ratio * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: team1Color,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((1 - team1Ratio) * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: team2Color,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                    ),
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

// ─── Playful Role Card ────────────────────────────────────────────────────────

class RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  static IconData _icon(UserRole r) {
    switch (r) {
      case UserRole.player:
        return Icons.sports_kabaddi_rounded;
      case UserRole.coach:
        return Icons.sports_score_rounded;
      case UserRole.organiser:
        return Icons.emoji_events_rounded;
      case UserRole.umpire:
        return Icons.gavel_rounded;
    }
  }

  static String _title(UserRole r) {
    switch (r) {
      case UserRole.player:
        return 'Athlete / Player';
      case UserRole.coach:
        return 'Coach / Trainer';
      case UserRole.organiser:
        return 'League Organiser';
      case UserRole.umpire:
        return 'Umpire / Referee';
    }
  }

  static String _subtitle(UserRole r) {
    switch (r) {
      case UserRole.player:
        return 'Track live stats, join squads & compete globally';
      case UserRole.coach:
        return 'Build lineups, scout talent & direct match strategy';
      case UserRole.organiser:
        return 'Host leagues, create tournaments & distribute trophies';
      case UserRole.umpire:
        return 'Official adjudicator, scorecard verification & bylaw reviews';
    }
  }

  static Color _color(UserRole r) {
    switch (r) {
      case UserRole.player:
        return AppColors.primary;
      case UserRole.coach:
        return AppColors.secondary;
      case UserRole.organiser:
        return AppColors.gold;
      case UserRole.umpire:
        return const Color(0xFF0EA5E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(role);
    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 2 : 1.2,
          ),
          
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_icon(role), color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(role),
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _subtitle(role),
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
