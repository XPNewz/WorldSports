import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

/// The official WorldSports App Logo widget.
///
/// Renders the official multi-colored interlaced sports-globe emblem
/// (blue, green, and gold ribbons with central star) from assets, with
/// a high-fidelity vector fallback painter for seamless test and offline rendering.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showContainer;
  final bool showShadow;
  final double? borderRadius;
  final Color? backgroundColor;

  const AppLogo({
    super.key,
    this.size = 44.0,
    this.showContainer = true,
    this.showShadow = true,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? (size * 0.24);
    final pixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final cacheDim = (size * pixelRatio).round().clamp(64, 512);

    Widget imageContent = Image.asset(
      'assets/images/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      cacheWidth: cacheDim,
      cacheHeight: cacheDim,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to high-precision custom painter of the official logo
        return CustomPaint(
          size: Size(size, size),
          painter: _AppLogoVectorPainter(),
        );
      },
    );

    if (!showContainer) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: imageContent,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: size * 0.35,
                  spreadRadius: 1,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius * 0.8),
        child: imageContent,
      ),
    );
  }
}

/// Official brand header combining the App Logo and "WORLDSPORTS" typography.
class AppBrandHeader extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final bool isDark;
  final VoidCallback? onTap;

  const AppBrandHeader({
    super.key,
    this.logoSize = 34.0,
    this.fontSize = 17.0,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(
          size: logoSize,
          showContainer: true,
          showShadow: true,
        ),
        const SizedBox(width: 9),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'WORLD',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              TextSpan(
                text: 'SPORTS',
                style: GoogleFonts.outfit(
                  color: AppColors.primary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}

/// Vector fallback painter that recreates the official WorldSports ribbon globe emblem.
class _AppLogoVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.92;

    // Palette extracted from the official logo
    const blueColor = Color(0xFF1B558B);
    const greenColor = Color(0xFF1E824C);
    const goldColor = Color(0xFFF39C12);

    final strokeW = size.width * 0.085;

    final bluePaint = Paint()
      ..color = blueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final greenPaint = Paint()
      ..color = greenColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final goldPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    // Outer circle
    canvas.drawCircle(center, radius, bluePaint);

    // Oval loops (representing intertwining sports tracks/globe meridians)
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // 0 deg vertical green loop
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 0.75, height: radius * 2.0),
      greenPaint,
    );

    // 45 deg gold loop
    canvas.save();
    canvas.rotate(math.pi / 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 0.75, height: radius * 2.0),
      goldPaint,
    );
    canvas.restore();

    // -45 deg blue loop
    canvas.save();
    canvas.rotate(-math.pi / 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 0.75, height: radius * 2.0),
      bluePaint,
    );
    canvas.restore();

    // 90 deg horizontal green/gold loop
    canvas.save();
    canvas.rotate(math.pi / 2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 0.75, height: radius * 2.0),
      goldPaint,
    );
    canvas.restore();

    // Central 4-pointed star
    final starPath = Path();
    final starR = radius * 0.38;
    final innerR = radius * 0.14;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final r = i.isEven ? starR : innerR;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(starPath, starPaint);

    final starBorderPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 0.75;
    canvas.drawPath(starPath, starBorderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
