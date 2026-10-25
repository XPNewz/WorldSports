import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

/// Data class representing a recorded cricket shot
class CricketShotResult {
  final int runs;
  final String sector;
  final String shotType;
  final double angle; // in radians from top (-PI to PI)
  final double distance; // 0.0 (pitch) to 1.0 (boundary)
  final bool isBoundary;
  final bool isRightHandBat;

  const CricketShotResult({
    required this.runs,
    required this.sector,
    required this.shotType,
    required this.angle,
    required this.distance,
    this.isBoundary = false,
    this.isRightHandBat = true,
  });

  Map<String, dynamic> toMap() => {
    'runs': runs,
    'sector': sector,
    'shot_type': shotType,
    'angle': angle,
    'distance': distance,
    'is_boundary': isBoundary,
    'is_right_hand_bat': isRightHandBat,
  };

  factory CricketShotResult.fromMap(Map<String, dynamic> map) {
    return CricketShotResult(
      runs: (map['runs'] as num?)?.toInt() ?? 0,
      sector: map['sector']?.toString() ?? '',
      shotType: map['shot_type']?.toString() ?? '',
      angle: (map['angle'] as num?)?.toDouble() ?? 0.0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      isBoundary: map['is_boundary'] == true,
      isRightHandBat: map['is_right_hand_bat'] != false,
    );
  }
}

/// Sector definition for cricket field
class _FieldSectorDef {
  final String name;
  final String shortName;
  final double startAngle; // in radians
  final double endAngle; // in radians
  final bool isOffSide; // for RHB

  const _FieldSectorDef({
    required this.name,
    required this.shortName,
    required this.startAngle,
    required this.endAngle,
    required this.isOffSide,
  });
}

/// CricHeroes & Stumps style interactive Cricket Field Shot Direction Selector Modal
class CricketFieldSelectorSheet extends StatefulWidget {
  final int runs;
  final bool isBoundary;
  final String batsmanName;
  final int batsmanJersey;
  final bool initialIsRightHand;

  const CricketFieldSelectorSheet({
    super.key,
    required this.runs,
    this.isBoundary = false,
    required this.batsmanName,
    this.batsmanJersey = 18,
    this.initialIsRightHand = true,
  });

  /// Static helper to display the sheet
  static Future<CricketShotResult?> show({
    required BuildContext context,
    required int runs,
    bool isBoundary = false,
    required String batsmanName,
    int batsmanJersey = 18,
    bool initialIsRightHand = true,
  }) {
    return showModalBottomSheet<CricketShotResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CricketFieldSelectorSheet(
        runs: runs,
        isBoundary: isBoundary,
        batsmanName: batsmanName,
        batsmanJersey: batsmanJersey,
        initialIsRightHand: initialIsRightHand,
      ),
    );
  }

  @override
  State<CricketFieldSelectorSheet> createState() => _CricketFieldSelectorSheetState();
}

class _CricketFieldSelectorSheetState extends State<CricketFieldSelectorSheet> {
  late bool _isRightHand;
  late double _selectedAngle;
  late double _selectedDistance;
  late String _selectedSector;
  late String _selectedShotType;

  // 8 standard cricket field sectors for Right-Hand Batter
  // 0 rad = 12 o'clock (Straight down ground)
  // Positive angles = Clockwise (Leg side for RHB)
  // Negative angles = Counter-Clockwise (Off side for RHB)
  static final List<_FieldSectorDef> _rhbSectors = [
    const _FieldSectorDef(
      name: 'Long Off',
      shortName: 'Long Off',
      startAngle: -math.pi * 0.125, // -22.5 deg
      endAngle: 0.0, // 0 deg
      isOffSide: true,
    ),
    const _FieldSectorDef(
      name: 'Extra Cover',
      shortName: 'Ex. Cover',
      startAngle: -math.pi * 0.375, // -67.5 deg
      endAngle: -math.pi * 0.125, // -22.5 deg
      isOffSide: true,
    ),
    const _FieldSectorDef(
      name: 'Cover / Point',
      shortName: 'Point',
      startAngle: -math.pi * 0.625, // -112.5 deg
      endAngle: -math.pi * 0.375, // -67.5 deg
      isOffSide: true,
    ),
    const _FieldSectorDef(
      name: 'Third Man / Gully',
      shortName: 'Third Man',
      startAngle: -math.pi * 0.875, // -157.5 deg
      endAngle: -math.pi * 0.625, // -112.5 deg
      isOffSide: true,
    ),
    const _FieldSectorDef(
      name: 'Fine Leg / Behind',
      shortName: 'Fine Leg',
      startAngle: math.pi * 0.875, // 157.5 deg
      endAngle: math.pi, // 180 deg
      isOffSide: false,
    ),
    const _FieldSectorDef(
      name: 'Square Leg',
      shortName: 'Sq. Leg',
      startAngle: math.pi * 0.625, // 112.5 deg
      endAngle: math.pi * 0.875, // 157.5 deg
      isOffSide: false,
    ),
    const _FieldSectorDef(
      name: 'Mid Wicket / Cow Corner',
      shortName: 'Mid Wkt',
      startAngle: math.pi * 0.25, // 45 deg
      endAngle: math.pi * 0.625, // 112.5 deg
      isOffSide: false,
    ),
    const _FieldSectorDef(
      name: 'Long On',
      shortName: 'Long On',
      startAngle: 0.0, // 0 deg
      endAngle: math.pi * 0.25, // 45 deg
      isOffSide: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isRightHand = widget.initialIsRightHand;

    // Default selection: Cover / Extra Cover for 4, Long On for 6, etc.
    if (widget.runs == 6) {
      _selectedAngle = math.pi * 0.45; // Mid wicket / Long on
      _selectedDistance = 0.95;
    } else if (widget.runs == 4) {
      _selectedAngle = -math.pi * 0.25; // Extra cover
      _selectedDistance = 0.92;
    } else if (widget.runs == 0) {
      _selectedAngle = -math.pi * 0.15; // Straight defense
      _selectedDistance = 0.35;
    } else {
      _selectedAngle = math.pi * 0.3; // Mid-wicket push
      _selectedDistance = 0.65;
    }

    _updateSectorAndShotType();
  }

  void _onFieldTapped(Offset localPos, Size fieldSize) {
    final center = Offset(fieldSize.width / 2, fieldSize.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    // Radius from center to boundary
    final maxRadius = math.min(fieldSize.width, fieldSize.height) * 0.46;
    final touchDist = math.sqrt(dx * dx + dy * dy);
    final clampedDist = (touchDist / maxRadius).clamp(0.15, 1.0);

    // Angle: 0 is straight UP (dy negative)
    // atan2(dx, -dy) gives angle where 0 is up, positive is clockwise, negative is counter-clockwise
    double angle = math.atan2(dx, -dy);

    setState(() {
      _selectedAngle = angle;
      _selectedDistance = clampedDist;
      _updateSectorAndShotType();
    });
  }

  void _selectSectorByName(String sectorName) {
    for (final sec in _rhbSectors) {
      if (sec.name == sectorName || sec.shortName == sectorName) {
        final midAngle = (sec.startAngle + sec.endAngle) / 2;
        setState(() {
          _selectedAngle = _isRightHand ? midAngle : -midAngle;
          _selectedDistance = widget.runs == 6 || widget.runs == 4 ? 0.92 : 0.65;
          _updateSectorAndShotType();
        });
        break;
      }
    }
  }

  void _updateSectorAndShotType() {
    // Effective angle for RHB coordinates
    double effAngle = _isRightHand ? _selectedAngle : -_selectedAngle;

    // Normalize to -pi .. pi
    while (effAngle > math.pi) {
      effAngle -= 2 * math.pi;
    }
    while (effAngle < -math.pi) {
      effAngle += 2 * math.pi;
    }

    // Determine sector
    String matchedSector = 'Cover / Extra Cover';
    for (final sec in _rhbSectors) {
      if (sec.startAngle < sec.endAngle) {
        if (effAngle >= sec.startAngle && effAngle <= sec.endAngle) {
          matchedSector = sec.name;
          break;
        }
      } else {
        // Wrap around at pi / -pi (Fine Leg area)
        if (effAngle >= sec.startAngle || effAngle <= sec.endAngle) {
          matchedSector = sec.name;
          break;
        }
      }
    }

    _selectedSector = matchedSector;
    _selectedShotType = _getShotTypeName(matchedSector, widget.runs);
  }

  String _getShotTypeName(String sector, int runs) {
    if (runs == 0) {
      if (sector.contains('Cover') || sector.contains('Point')) return 'Defended to Cover';
      if (sector.contains('Long Off') || sector.contains('Long On')) return 'Pushed to Mid Off / On';
      if (sector.contains('Leg')) return 'Worked softly to Leg Slip';
      return 'Dot Ball / Block';
    } else if (runs == 4) {
      if (sector.contains('Cover')) return 'Classic Cover Drive';
      if (sector.contains('Point')) return 'Square Cut through Point';
      if (sector.contains('Third Man')) return 'Delicate Late Cut';
      if (sector.contains('Long Off')) return 'Straight Lofted Four';
      if (sector.contains('Long On')) return 'Driven Down Long-On';
      if (sector.contains('Mid Wicket')) return 'Crunching Pull Shot';
      if (sector.contains('Square Leg')) return 'Sweep to Deep Square Leg';
      if (sector.contains('Fine Leg')) return 'Paddle Scoop / Fine Glance';
      return 'Crisp Boundary Four';
    } else if (runs == 6) {
      if (sector.contains('Mid Wicket') || sector.contains('Long On')) return 'Towering Slog Sweep / Maximum';
      if (sector.contains('Long Off')) return 'Lofted Straight Over Long-Off';
      if (sector.contains('Cover')) return 'Inside-Out Loft over Extra Cover';
      if (sector.contains('Point') || sector.contains('Third Man')) return 'Upper Cut over Third Man Rope';
      if (sector.contains('Fine Leg')) return 'Ramp Shot for Six';
      return 'Massive Six into the Crowd';
    } else {
      if (sector.contains('Cover')) return 'Guided through Cover Gap';
      if (sector.contains('Point')) return 'Steered to Backward Point';
      if (sector.contains('Third Man')) return 'Third Man dab';
      if (sector.contains('Long')) return 'Pushed firmly down ground';
      if (sector.contains('Mid Wicket')) return 'Flicked towards Mid-Wicket';
      if (sector.contains('Leg')) return 'Nudged softly to Fine Leg';
      return 'Worked into the outfield';
    }
  }

  void _confirmSelection() {
    Navigator.of(context).pop(
      CricketShotResult(
        runs: widget.runs,
        sector: _selectedSector,
        shotType: _selectedShotType,
        angle: _selectedAngle,
        distance: _selectedDistance,
        isBoundary: widget.isBoundary || widget.runs == 4 || widget.runs == 6,
        isRightHandBat: _isRightHand,
      ),
    );
  }

  void _skipSelection() {
    Navigator.of(context).pop(
      CricketShotResult(
        runs: widget.runs,
        sector: 'Outfield',
        shotType: widget.runs == 4 ? 'Boundary Four' : (widget.runs == 6 ? 'Maximum Six' : '${widget.runs} Runs'),
        angle: 0.0,
        distance: 0.7,
        isBoundary: widget.isBoundary || widget.runs == 4 || widget.runs == 6,
        isRightHandBat: _isRightHand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final runsColor = widget.runs == 6
        ? const Color(0xFF8B5CF6) // Purple
        : (widget.runs == 4
            ? const Color(0xFF059669) // Emerald
            : (widget.runs == 0
                ? const Color(0xFF64748B) // Slate
                : const Color(0xFF2563EB))); // Sapphire Blue

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B1329), // CricHeroes/Stumps dark athletic stadium surface
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header: Batter + Run Badge + Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Batter info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sports_cricket_rounded, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.batsmanName,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '#${widget.batsmanJersey} • Strike',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Runs Highlight Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: runsColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: runsColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.runs == 0 ? 'DOT BALL' : '+${widget.runs} RUNS',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: runsColor == const Color(0xFF64748B) ? Colors.white : runsColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Skip Button
                  TextButton.icon(
                    onPressed: _skipSelection,
                    icon: const Icon(Icons.fast_forward_rounded, size: 14, color: Color(0xFF94A3B8)),
                    label: Text(
                      'Skip Direction',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Stance Switcher: RHB vs LHB
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'TAP FIELD TO SELECT SHOT DIRECTION',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isRightHand = !_isRightHand;
                        _updateSectorAndShotType();
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                            color: _isRightHand ? const Color(0xFF38BDF8) : const Color(0xFFF472B6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isRightHand ? 'RHB (Right-Hand)' : 'LHB (Left-Hand)',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _isRightHand ? const Color(0xFF38BDF8) : const Color(0xFFF472B6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Interactive Cricket Ground Canvas
              LayoutBuilder(
                builder: (context, constraints) {
                  final fieldWidth = math.min(constraints.maxWidth, 330.0);
                  final fieldHeight = fieldWidth * 0.94;

                  return GestureDetector(
                    onTapDown: (details) => _onFieldTapped(details.localPosition, Size(fieldWidth, fieldHeight)),
                    onPanUpdate: (details) => _onFieldTapped(details.localPosition, Size(fieldWidth, fieldHeight)),
                    child: Container(
                      width: fieldWidth,
                      height: fieldHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF052e16).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomPaint(
                          size: Size(fieldWidth, fieldHeight),
                          painter: _CricketGroundPainter(
                            selectedAngle: _selectedAngle,
                            selectedDistance: _selectedDistance,
                            selectedSector: _selectedSector,
                            runs: widget.runs,
                            isRightHand: _isRightHand,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Selected Shot & Sector Display Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: runsColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.navigation_rounded, size: 18, color: runsColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedSector.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                '${(_selectedDistance * 75).toStringAsFixed(0)}m distance',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedShotType,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Quick Sector Chips row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSectorChip('Third Man'),
                    _buildSectorChip('Point'),
                    _buildSectorChip('Cover'),
                    _buildSectorChip('Extra Cover'),
                    _buildSectorChip('Long Off'),
                    _buildSectorChip('Long On'),
                    _buildSectorChip('Mid Wicket'),
                    _buildSectorChip('Square Leg'),
                    _buildSectorChip('Fine Leg'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Big Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _confirmSelection,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    widget.runs == 0
                        ? 'Confirm Dot Ball (${_selectedSector.split(' ').first})'
                        : 'Confirm +${widget.runs} Runs • $_selectedShotType',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: runsColor == const Color(0xFF64748B) ? AppColors.primary : runsColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shadowColor: runsColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectorChip(String label) {
    final isSelected = _selectedSector.contains(label) || label.contains(_selectedSector);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => _selectSectorByName(label),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFFCBD5E1),
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter rendering realistic Cricket Ground with Boundary, 30-yd circle, Pitch & Trajectory
class _CricketGroundPainter extends CustomPainter {
  final double selectedAngle;
  final double selectedDistance;
  final String selectedSector;
  final int runs;
  final bool isRightHand;

  _CricketGroundPainter({
    required this.selectedAngle,
    required this.selectedDistance,
    required this.selectedSector,
    required this.runs,
    required this.isRightHand,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fieldRadius = math.min(size.width, size.height) * 0.46;
    final innerCircleRadius = fieldRadius * 0.55; // 30-yard circle

    // 1. Draw Outfield Base (Concentric Mowing Ring Shades)
    final darkGrass = const Color(0xFF0F5132);
    final lightGrass = const Color(0xFF146C43);

    for (int i = 5; i >= 1; i--) {
      final r = fieldRadius * (i / 5.0);
      final grassPaint = Paint()
        ..color = (i % 2 == 0) ? darkGrass : lightGrass
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, r, grassPaint);
    }

    // 2. Sector Wedge Shading (Subtle radial guidelines)
    final sectorDividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - (math.pi / 8);
      final endPt = Offset(
        center.dx + math.sin(angle) * fieldRadius,
        center.dy - math.cos(angle) * fieldRadius,
      );
      canvas.drawLine(center, endPt, sectorDividerPaint);
    }

    // 3. 30-Yard Fielding Circle (Dashed White Line)
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashCount = 36;
    const dashSweep = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: innerCircleRadius),
          i * dashSweep,
          dashSweep * 0.6,
          false,
          dashPaint,
        );
      }
    }

    // Label "30 YD"
    final tp30 = TextPainter(
      text: TextSpan(
        text: '30 YD',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp30.paint(canvas, Offset(center.dx - tp30.width / 2, center.dy - innerCircleRadius + 3));

    // 4. White Boundary Rope with Glow
    final boundaryGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, fieldRadius, boundaryGlow);

    final boundaryRope = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, fieldRadius, boundaryRope);

    // 5. Pitch Rectangle (Tan/Clay Color in Center)
    final pitchWidth = fieldRadius * 0.16;
    final pitchHeight = fieldRadius * 0.44;
    final pitchRect = Rect.fromCenter(center: center, width: pitchWidth, height: pitchHeight);

    final pitchPaint = Paint()
      ..color = const Color(0xFFD4B996) // Sand / clay
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(pitchRect, const Radius.circular(2)), pitchPaint);

    // Crease lines on pitch
    final creasePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2;

    final battingCreaseY = center.dy + (pitchHeight * 0.32);
    final bowlingCreaseY = center.dy - (pitchHeight * 0.32);

    canvas.drawLine(
      Offset(pitchRect.left, battingCreaseY),
      Offset(pitchRect.right, battingCreaseY),
      creasePaint,
    );
    canvas.drawLine(
      Offset(pitchRect.left, bowlingCreaseY),
      Offset(pitchRect.right, bowlingCreaseY),
      creasePaint,
    );

    // Stumps (Three dots at each end)
    final stumpPaint = Paint()..color = Colors.white;
    for (int s = -1; s <= 1; s++) {
      canvas.drawCircle(Offset(center.dx + (s * 3.0), battingCreaseY + 2.5), 1.2, stumpPaint);
      canvas.drawCircle(Offset(center.dx + (s * 3.0), bowlingCreaseY - 2.5), 1.2, stumpPaint);
    }

    // 6. Selected Shot Trajectory Line & Glow
    final shotColor = runs == 6
        ? const Color(0xFFC084FC) // Violet glow
        : (runs == 4
            ? const Color(0xFF34D399) // Emerald
            : (runs == 0
                ? const Color(0xFF94A3B8) // Slate
                : const Color(0xFF38BDF8))); // Sky Blue

    final targetX = center.dx + math.sin(selectedAngle) * (fieldRadius * selectedDistance);
    final targetY = center.dy - math.cos(selectedAngle) * (fieldRadius * selectedDistance);
    final battingOrigin = Offset(center.dx, battingCreaseY);

    // Glowing beam
    final beamGlowPaint = Paint()
      ..color = shotColor.withValues(alpha: 0.35)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(battingOrigin, Offset(targetX, targetY), beamGlowPaint);

    // Solid laser beam
    final beamPaint = Paint()
      ..color = shotColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(battingOrigin, Offset(targetX, targetY), beamPaint);

    // Target landing point ripple / beacon
    final targetRipplePaint = Paint()
      ..color = shotColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(targetX, targetY), 10.0, targetRipplePaint);

    final targetDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(targetX, targetY), 4.5, targetDotPaint);

    final targetBorderPaint = Paint()
      ..color = shotColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(targetX, targetY), 4.5, targetBorderPaint);

    // 7. Field Sector Text Labels around boundary
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.8),
      fontSize: 9,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    );

    final sectorLabels = isRightHand
        ? [
            'LONG OFF',
            'EX. COVER',
            'POINT',
            '3RD MAN',
            'FINE LEG',
            'SQ. LEG',
            'MID WKT',
            'LONG ON',
          ]
        : [
            'LONG ON',
            'MID WKT',
            'SQ. LEG',
            'FINE LEG',
            '3RD MAN',
            'POINT',
            'EX. COVER',
            'LONG OFF',
          ];

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final labelDist = fieldRadius * 0.84;
      final lx = center.dx + math.sin(angle) * labelDist;
      final ly = center.dy - math.cos(angle) * labelDist;

      final tp = TextPainter(
        text: TextSpan(text: sectorLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _CricketGroundPainter oldDelegate) {
    return oldDelegate.selectedAngle != selectedAngle ||
        oldDelegate.selectedDistance != selectedDistance ||
        oldDelegate.selectedSector != selectedSector ||
        oldDelegate.runs != runs ||
        oldDelegate.isRightHand != isRightHand;
  }
}
