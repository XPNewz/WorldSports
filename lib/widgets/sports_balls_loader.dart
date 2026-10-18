import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'app_logo.dart';

enum SportBallType {
  cricket,
  football,
  tennis,
  basketball,
}

/// A standalone, high-precision rendered sports ball widget.
///
/// Features authentic materials, gradients, and seam patterns for:
/// - [SportBallType.cricket]: Crimson leather ball with raised white stitched seam.
/// - [SportBallType.football]: Classic black and white pentagon/hexagon match ball.
/// - [SportBallType.tennis]: Electric volt-yellow felt ball with curved white rubber seam.
/// - [SportBallType.basketball]: Textured warm orange basketball with curved black ribs.
class SportsBallWidget extends StatelessWidget {
  final SportBallType type;
  final double size;
  final double rotation;
  final bool showShadow;

  const SportsBallWidget({
    super.key,
    required this.type,
    this.size = 54.0,
    this.rotation = 0.0,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget ballPainter;
    switch (type) {
      case SportBallType.cricket:
        ballPainter = CustomPaint(
          size: Size(size, size),
          painter: _CricketLeatherBallPainter(),
        );
        break;
      case SportBallType.football:
        ballPainter = CustomPaint(
          size: Size(size, size),
          painter: _FootballSoccerBallPainter(),
        );
        break;
      case SportBallType.tennis:
        ballPainter = CustomPaint(
          size: Size(size, size),
          painter: _TennisBallPainter(),
        );
        break;
      case SportBallType.basketball:
        ballPainter = CustomPaint(
          size: Size(size, size),
          painter: _BasketballPainter(),
        );
        break;
    }

    if (rotation != 0.0) {
      ballPainter = Transform.rotate(
        angle: rotation,
        child: ballPainter,
      );
    }

    if (!showShadow) {
      return SizedBox(
        width: size,
        height: size,
        child: ballPainter,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(type).withValues(alpha: 0.28),
            blurRadius: size * 0.22,
            spreadRadius: 1,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: ballPainter,
    );
  }

  Color _getShadowColor(SportBallType t) {
    switch (t) {
      case SportBallType.cricket:
        return const Color(0xFF8B0000);
      case SportBallType.football:
        return const Color(0xFF1E293B);
      case SportBallType.tennis:
        return const Color(0xFF9E9D24);
      case SportBallType.basketball:
        return const Color(0xFFE65100);
    }
  }
}

// ─── Individual Sports Ball Painters ──────────────────────────────────────────

/// 1. Cricket Leather Ball: Rich crimson red leather with white stitched seam & shine.
class _CricketLeatherBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 3D Spherical Radial Gradient for polished leather
    final baseGradient = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.85,
      colors: const [
        Color(0xFFFF5252), // Highlights
        Color(0xFFD32F2F), // Bright red
        Color(0xFF8B0000), // Deep crimson
        Color(0xFF3E0000), // Deep shadow edge
      ],
      stops: const [0.0, 0.4, 0.82, 1.0],
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    // Subtle leather sheen overlay
    final sheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
        width: radius * 0.55,
        height: radius * 0.35,
      ),
      sheenPaint,
    );

    // Stitched Central Seam
    final seamPath = Path();
    seamPath.moveTo(center.dx, center.dy - radius);
    seamPath.cubicTo(
      center.dx + radius * 0.35,
      center.dy - radius * 0.45,
      center.dx + radius * 0.35,
      center.dy + radius * 0.45,
      center.dx,
      center.dy + radius,
    );

    // Clip to ball boundary
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Seam band
    final seamBandPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(seamPath, seamBandPaint);

    // Center seam groove
    final seamGroovePaint = Paint()
      ..color = const Color(0xFF6A0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.018;
    canvas.drawPath(seamPath, seamGroovePaint);

    // Seam Stitches (cross-stitch tick marks)
    final stitchPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.024
      ..strokeCap = StrokeCap.round;

    final metrics = seamPath.computeMetrics();
    for (final metric in metrics) {
      final length = metric.length;
      const stitchCount = 14;
      for (int i = 1; i < stitchCount; i++) {
        final dist = (length / stitchCount) * i;
        final tangent = metric.getTangentForOffset(dist);
        if (tangent != null) {
          final pos = tangent.position;
          final normal = Offset(-tangent.vector.dy, tangent.vector.dx) * (size.width * 0.045);
          canvas.drawLine(pos - normal, pos + normal, stitchPaint);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. Football (Soccer Ball): Classic black pentagon & white hexagon pattern.
class _FootballSoccerBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base spherical shading for white leather
    final baseGradient = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.9,
      colors: const [
        Color(0xFFFFFFFF),
        Color(0xFFF1F5F9),
        Color(0xFFCBD5E1),
        Color(0xFF64748B),
      ],
      stops: const [0.0, 0.45, 0.82, 1.0],
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    // Clip to ball boundary
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    final blackPatchPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final seamPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.026
      ..strokeCap = StrokeCap.round;

    // Center Pentagon
    final pentagonR = radius * 0.36;
    final centerVertices = <Offset>[];
    final centerPath = Path();

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final pt = Offset(
        center.dx + pentagonR * math.cos(angle),
        center.dy + pentagonR * math.sin(angle),
      );
      centerVertices.add(pt);
      if (i == 0) {
        centerPath.moveTo(pt.dx, pt.dy);
      } else {
        centerPath.lineTo(pt.dx, pt.dy);
      }
    }
    centerPath.close();
    canvas.drawPath(centerPath, blackPatchPaint);
    canvas.drawPath(centerPath, seamPaint);

    // Radiating seams and perimeter black patches
    for (int i = 0; i < 5; i++) {
      final v = centerVertices[i];
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final outerPt = Offset(
        center.dx + radius * 1.05 * math.cos(angle),
        center.dy + radius * 1.05 * math.sin(angle),
      );
      canvas.drawLine(v, outerPt, seamPaint);

      // Perimeter partial pentagon
      final patchPath = Path();
      final patchCenter = Offset(
        center.dx + radius * 0.9 * math.cos(angle),
        center.dy + radius * 0.9 * math.sin(angle),
      );
      patchPath.addOval(
        Rect.fromCircle(center: patchCenter, radius: radius * 0.28),
      );
      canvas.drawPath(patchPath, blackPatchPaint);
      canvas.drawPath(patchPath, seamPaint);
    }

    // Connect perimeter seams
    for (int i = 0; i < 5; i++) {
      final v1 = centerVertices[i];
      final v2 = centerVertices[(i + 1) % 5];
      final midAngle = ((i + 0.5) * 2 * math.pi / 5) - math.pi / 2;
      final outerMid = Offset(
        center.dx + radius * 0.85 * math.cos(midAngle),
        center.dy + radius * 0.85 * math.sin(midAngle),
      );
      canvas.drawLine(v1, outerMid, seamPaint);
      canvas.drawLine(v2, outerMid, seamPaint);
    }

    // Subtle specular shine
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.32, center.dy - radius * 0.32),
        width: radius * 0.5,
        height: radius * 0.3,
      ),
      shinePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. Tennis Ball: Electric volt-yellow felt with characteristic curved white rubber seam.
class _TennisBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Vibrant volt-green / tennis yellow felt radial gradient
    final baseGradient = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.85,
      colors: const [
        Color(0xFFEEFF41), // Electric chartreuse highlight
        Color(0xFFD4E157), // Mid felt
        Color(0xFF9E9D24), // Shadow felt
        Color(0xFF556B2F), // Edge shadow
      ],
      stops: const [0.0, 0.4, 0.8, 1.0],
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Classic Tennis Ball Double-Curve Seams
    final seamPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round;

    final seamShadowPaint = Paint()
      ..color = const Color(0xFF6B7280).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round;

    // Left curved seam arc
    final leftSeam = Path();
    leftSeam.moveTo(center.dx - radius * 0.3, center.dy - radius * 0.95);
    leftSeam.cubicTo(
      center.dx + radius * 0.2,
      center.dy - radius * 0.35,
      center.dx + radius * 0.2,
      center.dy + radius * 0.35,
      center.dx - radius * 0.3,
      center.dy + radius * 0.95,
    );
    canvas.drawPath(leftSeam, seamShadowPaint);
    canvas.drawPath(leftSeam, seamPaint);

    // Right curved seam arc
    final rightSeam = Path();
    rightSeam.moveTo(center.dx + radius * 0.6, center.dy - radius * 0.8);
    rightSeam.cubicTo(
      center.dx - radius * 0.1,
      center.dy - radius * 0.3,
      center.dx - radius * 0.1,
      center.dy + radius * 0.3,
      center.dx + radius * 0.6,
      center.dy + radius * 0.8,
    );
    canvas.drawPath(rightSeam, seamShadowPaint);
    canvas.drawPath(rightSeam, seamPaint);

    // Soft felt texture highlight
    final feltHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
        width: radius * 0.5,
        height: radius * 0.35,
      ),
      feltHighlight,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4. Basketball: Rich textured warm orange with black ribbed seams.
class _BasketballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Deep Basketball Orange Spherical Gradient
    final baseGradient = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.85,
      colors: const [
        Color(0xFFFF8A65), // Highlight orange
        Color(0xFFFF5722), // Vibrant orange
        Color(0xFFD84315), // Deep shadow orange
        Color(0xFF4E1500), // Edge rim shadow
      ],
      stops: const [0.0, 0.42, 0.8, 1.0],
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Black Ribbed Seams
    final ribPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.046
      ..strokeCap = StrokeCap.round;

    // 1. Vertical Meridian Line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      ribPaint,
    );

    // 2. Horizontal Equator Line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      ribPaint,
    );

    // 3. Left Parabolic Arc Seam
    final leftArc = Path();
    leftArc.moveTo(center.dx - radius * 0.72, center.dy - radius * 0.72);
    leftArc.cubicTo(
      center.dx + radius * 0.15,
      center.dy - radius * 0.4,
      center.dx + radius * 0.15,
      center.dy + radius * 0.4,
      center.dx - radius * 0.72,
      center.dy + radius * 0.72,
    );
    canvas.drawPath(leftArc, ribPaint);

    // 4. Right Parabolic Arc Seam
    final rightArc = Path();
    rightArc.moveTo(center.dx + radius * 0.72, center.dy - radius * 0.72);
    rightArc.cubicTo(
      center.dx - radius * 0.15,
      center.dy - radius * 0.4,
      center.dx - radius * 0.15,
      center.dy + radius * 0.4,
      center.dx + radius * 0.72,
      center.dy + radius * 0.72,
    );
    canvas.drawPath(rightArc, ribPaint);

    // Specular shine on basketball surface
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.32, center.dy - radius * 0.32),
        width: radius * 0.45,
        height: radius * 0.28,
      ),
      shinePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── The Complete Animated Multi-Ball Loading Chamber ─────────────────────────

/// Animated loading widget that prominently displays multiple sports balls:
/// Cricket Leather Ball, Football, Tennis Ball, and Basketball in the middle
/// of the screen, with fluid 3D-perspective orbital motion and contact shadows.
class SportsBallsLoader extends StatefulWidget {
  final double size;
  final bool showCentralLogo;
  final bool showStageTicker;
  final String? customLoadingText;

  const SportsBallsLoader({
    super.key,
    this.size = 220.0,
    this.showCentralLogo = true,
    this.showStageTicker = true,
    this.customLoadingText,
  });

  @override
  State<SportsBallsLoader> createState() => _SportsBallsLoaderState();
}

class _SportsBallsLoaderState extends State<SportsBallsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<Map<String, dynamic>> _ballsConfig = [
    {
      'type': SportBallType.cricket,
      'label': 'CRICKET LEATHER BALL',
      'icon': '🏏',
      'accent': Color(0xFFD32F2F),
    },
    {
      'type': SportBallType.football,
      'label': 'FOOTBALL MATCH BALL',
      'icon': '⚽',
      'accent': Color(0xFF10B981),
    },
    {
      'type': SportBallType.tennis,
      'label': 'TENNIS FELT BALL',
      'icon': '🎾',
      'accent': Color(0xFFEAB308),
    },
    {
      'type': SportBallType.basketball,
      'label': 'BASKETBALL HARDWOOD',
      'icon': '🏀',
      'accent': Color(0xFFFF5722),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double chamberSize = widget.size;
    final double ballSize = chamberSize * 0.23;
    final double orbitRadiusX = chamberSize * 0.38;
    final double orbitRadiusY = chamberSize * 0.16;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;

        // Current active sport index based on rotation phase
        final int activeIndex = ((t * _ballsConfig.length) % _ballsConfig.length).floor();
        final activeConfig = _ballsConfig[activeIndex];

        // Prepare ball positions in 3D orbit
        final List<Widget> ballWidgets = [];

        // Sort items by Y offset (depth) so front balls paint over back balls
        final sortedIndices = List.generate(_ballsConfig.length, (i) => i);
        sortedIndices.sort((a, b) {
          final angleA = (2 * math.pi * t) + (a * 2 * math.pi / _ballsConfig.length);
          final angleB = (2 * math.pi * t) + (b * 2 * math.pi / _ballsConfig.length);
          return math.sin(angleA).compareTo(math.sin(angleB));
        });

        for (final index in sortedIndices) {
          final config = _ballsConfig[index];
          final type = config['type'] as SportBallType;
          final baseAngle = (2 * math.pi * t) + (index * 2 * math.pi / _ballsConfig.length);

          // 3D Elliptical coordinates
          final double x = orbitRadiusX * math.cos(baseAngle);
          final double y = orbitRadiusY * math.sin(baseAngle);

          // Depth scaling: front (sin > 0) is larger, back (sin < 0) is smaller
          final double depth = (math.sin(baseAngle) + 1.0) / 2.0; // 0.0 to 1.0
          final double scale = 0.82 + (0.34 * depth);
          final double opacity = 0.80 + (0.20 * depth);

          // Individual self-spin rotation
          final double ballSpin = (t * 2 * math.pi) * (index.isEven ? 1.2 : -1.0);

          ballWidgets.add(
            Transform.translate(
              offset: Offset(x, y),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SportsBallWidget(
                        type: type,
                        size: ballSize,
                        rotation: ballSpin,
                        showShadow: true,
                      ),
                      // Soft ground contact shadow
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: ballSize * 0.7 * scale,
                        height: 5 * scale,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12 * depth),
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(ballSize * 0.7, 5),
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Multi-Ball Orbit Chamber
            SizedBox(
              width: chamberSize,
              height: chamberSize * 0.82,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle glowing orbital turf ring
                  Container(
                    width: orbitRadiusX * 2.1,
                    height: orbitRadiusY * 2.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (activeConfig['accent'] as Color).withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // Central App Logo (WorldSports Globe Emblem)
                  if (widget.showCentralLogo)
                    AppLogo(
                      size: chamberSize * 0.28,
                      showContainer: true,
                      showShadow: true,
                    ),

                  // The 4 Sports Balls Revolving
                  ...ballWidgets,
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Animated Sport Ticker Label (Reflects balls currently loaded)
            if (widget.showStageTicker) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey<int>(activeIndex),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: (activeConfig['accent'] as Color).withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (activeConfig['accent'] as Color).withValues(alpha: 0.28),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${activeConfig['icon']}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activeConfig['label'] as String,
                        style: GoogleFonts.outfit(
                          color: activeConfig['accent'] as Color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (widget.customLoadingText != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.customLoadingText!,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// A compact row of multiple bouncing sports balls (Cricket, Football, Tennis, Basketball)
/// suitable for in-app micro-loaders, dialogs, and refreshers.
class CompactSportsBallsLoader extends StatefulWidget {
  final double ballSize;
  const CompactSportsBallsLoader({
    super.key,
    this.ballSize = 28.0,
  });

  @override
  State<CompactSportsBallsLoader> createState() => _CompactSportsBallsLoaderState();
}

class _CompactSportsBallsLoaderState extends State<CompactSportsBallsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  static const List<SportBallType> _balls = [
    SportBallType.cricket,
    SportBallType.football,
    SportBallType.tennis,
    SportBallType.basketball,
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_balls.length, (i) {
            final phase = (_bounceController.value * 2 * math.pi) + (i * math.pi / 2);
            final bounceY = -math.sin(phase).abs() * 12.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, bounceY),
                child: SportsBallWidget(
                  type: _balls[i],
                  size: widget.ballSize,
                  rotation: phase * 0.5,
                  showShadow: true,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// A professional, high-precision loading area widget designed specifically
/// to be displayed within designated blank areas (e.g. content placeholders,
/// splash loading chambers, card authenticators, or empty state loaders).
/// Ensures that loading animations never bleed unconstrained across the screen,
/// but remain firmly anchored in their decided, bounded athletic area.
class SpecificAreaLoader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final double? width;
  final double? height;
  final double ballSize;
  final bool useChangingBall;
  final bool useOrbitChamber;
  final double orbitChamberSize;
  final double? progress;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showBorder;
  final Widget? trailing;

  const SpecificAreaLoader({
    super.key,
    this.title,
    this.subtitle,
    this.width,
    this.height,
    this.ballSize = 24.0,
    this.useChangingBall = true,
    this.useOrbitChamber = false,
    this.orbitChamberSize = 180.0,
    this.progress,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    this.backgroundColor,
    this.showBorder = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (useOrbitChamber)
          SportsBallsLoader(
            size: orbitChamberSize,
            showCentralLogo: true,
            showStageTicker: true,
          )
        else if (useChangingBall)
          SportsBallChangingLoader(
            size: ballSize,
            showSpeedRing: true,
            showSportLabel: false,
          )
        else
          CompactSportsBallsLoader(ballSize: ballSize),
        if (title != null) ...[
          const SizedBox(height: 10),
          Text(
            title!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (progress != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 150,
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
        if (trailing != null) ...[
          const SizedBox(height: 10),
          trailing!,
        ],
      ],
    );

    if (height != null) {
      content = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: content,
      );
    }

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: showBorder
            ? Border.all(color: const Color(0xFFE2E8F0), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: content),
    );
  }
}

// ─── Sports Balls Changing With Time Loader (Replaces Circular Roll) ──────────

/// A high-performance loader designed specifically for loading screens, slow internet,
/// and delay states. Instead of a generic circular progress roll, it seamlessly cycles
/// through authentic sports balls (Cricket -> Football -> Tennis -> Basketball) over time.
class SportsBallChangingLoader extends StatefulWidget {
  final double size;
  final bool showSpeedRing;
  final bool showSportLabel;
  final Duration switchDuration;

  const SportsBallChangingLoader({
    super.key,
    this.size = 54.0,
    this.showSpeedRing = true,
    this.showSportLabel = false,
    this.switchDuration = const Duration(milliseconds: 700),
  });

  @override
  State<SportsBallChangingLoader> createState() => _SportsBallChangingLoaderState();
}

class _SportsBallChangingLoaderState extends State<SportsBallChangingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  static const List<Map<String, dynamic>> _sports = [
    {
      'type': SportBallType.cricket,
      'label': 'CRICKET',
      'color': Color(0xFFD32F2F),
    },
    {
      'type': SportBallType.football,
      'label': 'FOOTBALL',
      'color': Color(0xFF10B981),
    },
    {
      'type': SportBallType.tennis,
      'label': 'TENNIS',
      'color': Color(0xFFEAB308),
    },
    {
      'type': SportBallType.basketball,
      'label': 'BASKETBALL',
      'color': Color(0xFFFF5722),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.switchDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % _sports.length;
            });
            _controller.forward(from: 0.0);
          }
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSport = _sports[_currentIndex];
    final activeColor = activeSport['color'] as Color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size * 1.35,
          height: widget.size * 1.35,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dynamic athletic speed ring around the changing ball
              if (widget.showSpeedRing)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: Container(
                        width: widget.size * 1.25,
                        height: widget.size * 1.25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: activeColor.withValues(alpha: 0.28),
                            width: 2.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Animated changing sports ball with dynamic pop-bounce and rotation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final bounce = math.sin(_controller.value * math.pi) * 5.0;
                  final spin = _controller.value * math.pi * 0.7;

                  return Transform.translate(
                    offset: Offset(0, -bounce),
                    child: Transform.rotate(
                      angle: spin,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutBack,
                          ),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: SportsBallWidget(
                          key: ValueKey<int>(_currentIndex),
                          type: activeSport['type'] as SportBallType,
                          size: widget.size,
                          showShadow: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        if (widget.showSportLabel) ...[
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              activeSport['label'] as String,
              key: ValueKey<int>(_currentIndex),
              style: GoogleFonts.outfit(
                color: activeColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A dedicated delay/loading screen for slow internet or asynchronous data delays.
/// Replaces generic circular loading spinners with authentic changing sports balls.
class SportsDelayLoadingScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const SportsDelayLoadingScreen({
    super.key,
    this.title = 'Loading Arena Experience',
    this.subtitle = 'Synchronizing sports network data...',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SportsBallChangingLoader(
              size: 64,
              showSpeedRing: true,
              showSportLabel: true,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('RETRY SYNC'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


