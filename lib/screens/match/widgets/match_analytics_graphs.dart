import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import 'cricket_field_selector.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS FOR ANALYTICS GRAPHS
// ═══════════════════════════════════════════════════════════════════════════════

/// Represents cumulative over data for Worm and Manhattan charts
class CricketOverProgress {
  final int overNumber; // 1-indexed
  final int runsInOver;
  final int cumulativeRuns;
  final int wicketsInOver;
  final int cumulativeWickets;
  final List<String> balls;
  final List<String> wicketBatsmen;

  const CricketOverProgress({
    required this.overNumber,
    required this.runsInOver,
    required this.cumulativeRuns,
    this.wicketsInOver = 0,
    this.cumulativeWickets = 0,
    this.balls = const [],
    this.wicketBatsmen = const [],
  });

  Map<String, dynamic> toMap() => {
    'over_number': overNumber,
    'runs_in_over': runsInOver,
    'cumulative_runs': cumulativeRuns,
    'wickets_in_over': wicketsInOver,
    'cumulative_wickets': cumulativeWickets,
    'balls': balls,
    'wicket_batsmen': wicketBatsmen,
  };

  factory CricketOverProgress.fromMap(Map<String, dynamic> map) {
    return CricketOverProgress(
      overNumber: (map['over_number'] as num?)?.toInt() ?? 1,
      runsInOver: (map['runs_in_over'] as num?)?.toInt() ?? 0,
      cumulativeRuns: (map['cumulative_runs'] as num?)?.toInt() ?? 0,
      wicketsInOver: (map['wickets_in_over'] as num?)?.toInt() ?? 0,
      cumulativeWickets: (map['cumulative_wickets'] as num?)?.toInt() ?? 0,
      balls: List<String>.from(map['balls'] ?? []),
      wicketBatsmen: List<String>.from(map['wicket_batsmen'] ?? []),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 1. CRICKET WORM CHART (RUN VS OVER WITH WICKETS FOR BOTH TEAMS)
// ═══════════════════════════════════════════════════════════════════════════════

class CricketWormChart extends StatelessWidget {
  final String team1Name;
  final String team2Name;
  final String team1Short;
  final String team2Short;
  final List<CricketOverProgress> team1Overs;
  final List<CricketOverProgress> team2Overs;
  final int maxOvers;
  final int targetRuns;

  const CricketWormChart({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.team1Short,
    required this.team2Short,
    required this.team1Overs,
    required this.team2Overs,
    this.maxOvers = 20,
    this.targetRuns = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Determine peak runs for Y scale
    int maxRuns = 150;
    for (final o in team1Overs) {
      if (o.cumulativeRuns > maxRuns) maxRuns = o.cumulativeRuns;
    }
    for (final o in team2Overs) {
      if (o.cumulativeRuns > maxRuns) maxRuns = o.cumulativeRuns;
    }
    if (targetRuns > maxRuns) maxRuns = targetRuns;
    maxRuns = ((maxRuns / 25).ceil() * 25) + 25; // Round up with headroom

    final t1Current = team1Overs.isNotEmpty ? team1Overs.last : null;
    final t2Current = team2Overs.isNotEmpty ? team2Overs.last : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Team Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WORM GRAPH (RUNS VS OVERS)',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Over-by-over progression with wicket falls (W)',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${maxOvers}v Format',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Team Legend Pills
          Row(
            children: [
              // Team 1 Pill
              _buildTeamLegendPill(
                teamShort: team1Short,
                score: t1Current != null ? '${t1Current.cumulativeRuns}/${t1Current.cumulativeWickets}' : '0/0',
                overs: t1Current != null ? '${t1Current.overNumber}.0 ov' : '0.0 ov',
                color: const Color(0xFF2563EB), // Sapphire Blue
              ),
              const SizedBox(width: 8),
              // Team 2 Pill
              _buildTeamLegendPill(
                teamShort: team2Short,
                score: t2Current != null ? '${t2Current.cumulativeRuns}/${t2Current.cumulativeWickets}' : '0/0',
                overs: t2Current != null ? '${t2Current.overNumber}.0 ov' : '0.0 ov',
                color: const Color(0xFF059669), // Emerald Green
              ),
              const Spacer(),
              // Wicket marker legend
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('W', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                  const SizedBox(width: 4),
                  Text('Wicket', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Paint Canvas for Worm Chart
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _WormChartPainter(
                team1Overs: team1Overs,
                team2Overs: team2Overs,
                maxOvers: maxOvers,
                maxRuns: maxRuns,
                targetRuns: targetRuns,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLegendPill({
    required String teamShort,
    required String score,
    required String overs,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$teamShort: ',
            style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            score,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          Text(
            ' ($overs)',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WormChartPainter extends CustomPainter {
  final List<CricketOverProgress> team1Overs;
  final List<CricketOverProgress> team2Overs;
  final int maxOvers;
  final int maxRuns;
  final int targetRuns;

  _WormChartPainter({
    required this.team1Overs,
    required this.team2Overs,
    required this.maxOvers,
    required this.maxRuns,
    required this.targetRuns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 34.0;
    const bottomPadding = 24.0;
    const topPadding = 12.0;
    const rightPadding = 12.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - bottomPadding - topPadding;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.2;

    final labelStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF94A3B8),
    );

    // 1. Horizontal Y-Axis Gridlines & Labels
    const ySteps = 4;
    for (int i = 0; i <= ySteps; i++) {
      final runVal = (maxRuns * i ~/ ySteps);
      final y = size.height - bottomPadding - (chartHeight * i / ySteps);

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: '$runVal', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
    }

    // 2. Vertical X-Axis Overs Gridlines & Labels (every 5 overs or 2 overs)
    final xStepOvers = maxOvers <= 20 ? 4 : 5;
    for (int ov = 0; ov <= maxOvers; ov += xStepOvers) {
      final x = leftPadding + (chartWidth * (ov / maxOvers));

      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, size.height - bottomPadding),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: '$ov', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPadding + 5));
    }

    // Baseline & Left Axis
    canvas.drawLine(
      Offset(leftPadding, size.height - bottomPadding),
      Offset(size.width - rightPadding, size.height - bottomPadding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, size.height - bottomPadding),
      axisPaint,
    );

    // 3. Draw Target Line (if 2nd innings chasing)
    if (targetRuns > 0 && targetRuns <= maxRuns) {
      final targetY = size.height - bottomPadding - (chartHeight * (targetRuns / maxRuns));
      final targetPaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Dashed line
      for (double x = leftPadding; x < size.width - rightPadding; x += 8) {
        canvas.drawLine(Offset(x, targetY), Offset(math.min(x + 4, size.width - rightPadding), targetY), targetPaint);
      }

      final tpTarget = TextPainter(
        text: TextSpan(
          text: 'Target: $targetRuns',
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpTarget.paint(canvas, Offset(size.width - rightPadding - tpTarget.width - 4, targetY - tpTarget.height - 2));
    }

    // 4. Plot Team 1 Line (Blue)
    _plotTeamCurve(
      canvas: canvas,
      overs: team1Overs,
      color: const Color(0xFF2563EB),
      leftPadding: leftPadding,
      bottomPadding: bottomPadding,
      chartWidth: chartWidth,
      chartHeight: chartHeight,
      size: size,
    );

    // 5. Plot Team 2 Line (Emerald Green)
    _plotTeamCurve(
      canvas: canvas,
      overs: team2Overs,
      color: const Color(0xFF059669),
      leftPadding: leftPadding,
      bottomPadding: bottomPadding,
      chartWidth: chartWidth,
      chartHeight: chartHeight,
      size: size,
    );
  }

  void _plotTeamCurve({
    required Canvas canvas,
    required List<CricketOverProgress> overs,
    required Color color,
    required double leftPadding,
    required double bottomPadding,
    required double chartWidth,
    required double chartHeight,
    required Size size,
  }) {
    if (overs.isEmpty) return;

    final path = Path();
    final points = <Offset>[];

    // Start at 0,0
    final startPt = Offset(leftPadding, size.height - bottomPadding);
    points.add(startPt);
    path.moveTo(startPt.dx, startPt.dy);

    for (final ov in overs) {
      final x = leftPadding + (chartWidth * (ov.overNumber / maxOvers));
      final y = size.height - bottomPadding - (chartHeight * (ov.cumulativeRuns / maxRuns));
      points.add(Offset(x, y));
    }

    // Draw Smooth Spline / Lines
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Line Shadow/Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint);

    // Main Curve
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Draw Wicket Markers on this team's curve
    for (final ov in overs) {
      if (ov.wicketsInOver > 0) {
        final x = leftPadding + (chartWidth * (ov.overNumber / maxOvers));
        final y = size.height - bottomPadding - (chartHeight * (ov.cumulativeRuns / maxRuns));

        // Red Wicket Badge
        final wPaint = Paint()..color = const Color(0xFFEF4444);
        canvas.drawCircle(Offset(x, y), 8, wPaint);

        final wBorder = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(x, y), 8, wBorder);

        final wText = ov.wicketsInOver > 1 ? 'W${ov.wicketsInOver}' : 'W';
        final tp = TextPainter(
          text: TextSpan(
            text: wText,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WormChartPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. CRICKET MANHATTAN CHART (PER OVER RUN BAR GRAPH WITH WICKETS)
// ═══════════════════════════════════════════════════════════════════════════════

class CricketManhattanChart extends StatefulWidget {
  final String team1Short;
  final String team2Short;
  final List<CricketOverProgress> team1Overs;
  final List<CricketOverProgress> team2Overs;
  final int maxOvers;

  const CricketManhattanChart({
    super.key,
    required this.team1Short,
    required this.team2Short,
    required this.team1Overs,
    required this.team2Overs,
    this.maxOvers = 20,
  });

  @override
  State<CricketManhattanChart> createState() => _CricketManhattanChartState();
}

class _CricketManhattanChartState extends State<CricketManhattanChart> {
  int _viewFilter = 0; // 0 = Both, 1 = Team 1, 2 = Team 2

  @override
  Widget build(BuildContext context) {
    int maxRunsInAnyOver = 18;
    for (final o in widget.team1Overs) {
      if (o.runsInOver > maxRunsInAnyOver) maxRunsInAnyOver = o.runsInOver;
    }
    for (final o in widget.team2Overs) {
      if (o.runsInOver > maxRunsInAnyOver) maxRunsInAnyOver = o.runsInOver;
    }
    maxRunsInAnyOver = ((maxRunsInAnyOver / 5).ceil() * 5) + 5;

    final displayedOversCount = math.max(widget.team1Overs.length, widget.team2Overs.length);
    final count = math.max(1, displayedOversCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Filter Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MANHATTAN GRAPH (RUNS PER OVER)',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Per-over scoring comparison with wickets fallen',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Segmented Filter
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildFilterTab(0, 'Both'),
                    _buildFilterTab(1, widget.team1Short),
                    _buildFilterTab(2, widget.team2Short),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Over Bars Area
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(340.0, count * 36.0 + 40.0),
              height: 200,
              child: CustomPaint(
                painter: _ManhattanBarsPainter(
                  team1Overs: widget.team1Overs,
                  team2Overs: widget.team2Overs,
                  maxRunsInOver: maxRunsInAnyOver,
                  maxOvers: widget.maxOvers,
                  viewFilter: _viewFilter,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Legend indicator bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_viewFilter != 2) ...[
                Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 4),
                Text(widget.team1Short, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF2563EB))),
                const SizedBox(width: 14),
              ],
              if (_viewFilter != 1) ...[
                Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 4),
                Text(widget.team2Short, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF059669))),
                const SizedBox(width: 14),
              ],
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('W', style: GoogleFonts.outfit(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              const SizedBox(width: 4),
              Text('Wicket Lost', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final isSelected = _viewFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _viewFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 2)] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ManhattanBarsPainter extends CustomPainter {
  final List<CricketOverProgress> team1Overs;
  final List<CricketOverProgress> team2Overs;
  final int maxRunsInOver;
  final int maxOvers;
  final int viewFilter;

  _ManhattanBarsPainter({
    required this.team1Overs,
    required this.team2Overs,
    required this.maxRunsInOver,
    required this.maxOvers,
    required this.viewFilter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 26.0;
    const botPad = 26.0;
    const topPad = 20.0;

    final chartH = size.height - botPad - topPad;
    final totalOvers = math.max(team1Overs.length, team2Overs.length);
    final count = math.max(1, totalOvers);
    final overSlotW = (size.width - leftPad - 16.0) / count;

    // Gridlines for Y (every 5 runs)
    final gridPaint = Paint()..color = const Color(0xFFF1F5F9);
    for (int r = 0; r <= maxRunsInOver; r += 5) {
      final y = size.height - botPad - (chartH * (r / maxRunsInOver));
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(text: '$r', style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    final t1Map = {for (var o in team1Overs) o.overNumber: o};
    final t2Map = {for (var o in team2Overs) o.overNumber: o};

    final t1Paint = Paint()..color = const Color(0xFF2563EB);
    final t2Paint = Paint()..color = const Color(0xFF059669);

    for (int ov = 1; ov <= count; ov++) {
      final slotX = leftPad + ((ov - 1) * overSlotW);
      final t1 = t1Map[ov];
      final t2 = t2Map[ov];

      if (viewFilter == 0) {
        // Both teams side-by-side
        final barW = (overSlotW * 0.38).clamp(6.0, 14.0);
        final gap = 2.0;
        final startX = slotX + (overSlotW - (barW * 2 + gap)) / 2;

        if (t1 != null) {
          final barH = chartH * (t1.runsInOver / maxRunsInOver);
          final barY = size.height - botPad - barH;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(startX, barY, barW, barH), const Radius.circular(3)),
            t1Paint,
          );

          if (t1.wicketsInOver > 0) {
            _drawWicketMarker(canvas, startX + barW / 2, barY - 7, t1.wicketsInOver);
          }
        }

        if (t2 != null) {
          final bar2X = startX + barW + gap;
          final barH = chartH * (t2.runsInOver / maxRunsInOver);
          final barY = size.height - botPad - barH;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(bar2X, barY, barW, barH), const Radius.circular(3)),
            t2Paint,
          );

          if (t2.wicketsInOver > 0) {
            _drawWicketMarker(canvas, bar2X + barW / 2, barY - 7, t2.wicketsInOver);
          }
        }
      } else if (viewFilter == 1) {
        // Team 1 Only
        if (t1 != null) {
          final barW = (overSlotW * 0.65).clamp(8.0, 24.0);
          final barX = slotX + (overSlotW - barW) / 2;
          final barH = chartH * (t1.runsInOver / maxRunsInOver);
          final barY = size.height - botPad - barH;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(barX, barY, barW, barH), const Radius.circular(4)),
            t1Paint,
          );

          // Over run number on top of bar
          _drawRunText(canvas, '${t1.runsInOver}', barX + barW / 2, barY - 10);

          if (t1.wicketsInOver > 0) {
            _drawWicketMarker(canvas, barX + barW / 2, barY - 22, t1.wicketsInOver);
          }
        }
      } else {
        // Team 2 Only
        if (t2 != null) {
          final barW = (overSlotW * 0.65).clamp(8.0, 24.0);
          final barX = slotX + (overSlotW - barW) / 2;
          final barH = chartH * (t2.runsInOver / maxRunsInOver);
          final barY = size.height - botPad - barH;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(barX, barY, barW, barH), const Radius.circular(4)),
            t2Paint,
          );

          // Over run number on top of bar
          _drawRunText(canvas, '${t2.runsInOver}', barX + barW / 2, barY - 10);

          if (t2.wicketsInOver > 0) {
            _drawWicketMarker(canvas, barX + barW / 2, barY - 22, t2.wicketsInOver);
          }
        }
      }

      // X-Axis Over Number Label
      final tpOv = TextPainter(
        text: TextSpan(
          text: '$ov',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpOv.paint(canvas, Offset(slotX + (overSlotW - tpOv.width) / 2, size.height - botPad + 5));
    }
  }

  void _drawWicketMarker(Canvas canvas, double cx, double cy, int count) {
    final p = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(cx, cy), 6.5, p);
    final border = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), 6.5, border);

    final tp = TextPainter(
      text: TextSpan(
        text: count > 1 ? 'W$count' : 'W',
        style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawRunText(Canvas canvas, String text, double cx, double cy) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ManhattanBarsPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. CRICKET BOUNDARY & RUN BREAKDOWN GRAPH
// ═══════════════════════════════════════════════════════════════════════════════

class CricketBoundaryBreakdownCard extends StatelessWidget {
  final String team1Short;
  final String team2Short;
  final int team1TotalRuns;
  final int team2TotalRuns;
  final int team1Fours;
  final int team1Sixes;
  final int team2Fours;
  final int team2Sixes;
  final int team1DotBalls;
  final int team1TotalBalls;
  final int team2DotBalls;
  final int team2TotalBalls;

  const CricketBoundaryBreakdownCard({
    super.key,
    required this.team1Short,
    required this.team2Short,
    required this.team1TotalRuns,
    required this.team2TotalRuns,
    required this.team1Fours,
    required this.team1Sixes,
    required this.team2Fours,
    required this.team2Sixes,
    required this.team1DotBalls,
    required this.team1TotalBalls,
    required this.team2DotBalls,
    required this.team2TotalBalls,
  });

  @override
  Widget build(BuildContext context) {
    final t1BoundaryRuns = (team1Fours * 4) + (team1Sixes * 6);
    final t2BoundaryRuns = (team2Fours * 4) + (team2Sixes * 6);

    final t1BoundaryPct = team1TotalRuns > 0 ? (t1BoundaryRuns / team1TotalRuns) * 100 : 0.0;
    final t2BoundaryPct = team2TotalRuns > 0 ? (t2BoundaryRuns / team2TotalRuns) * 100 : 0.0;

    final t1DotPct = team1TotalBalls > 0 ? (team1DotBalls / team1TotalBalls) * 100 : 0.0;
    final t2DotPct = team2TotalBalls > 0 ? (team2DotBalls / team2TotalBalls) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BOUNDARY BREAKDOWN & SCORING PROFILE',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // 4s & 6s Metric Grid
          Row(
            children: [
              // Fours (4s) Box
              Expanded(
                child: _buildMetricBox(
                  title: 'BOUNDARIES (4s)',
                  t1Val: '$team1Fours',
                  t2Val: '$team2Fours',
                  t1Sub: '${team1Fours * 4} runs',
                  t2Sub: '${team2Fours * 4} runs',
                  icon: Icons.filter_4_rounded,
                  accentColor: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 10),
              // Sixes (6s) Box
              Expanded(
                child: _buildMetricBox(
                  title: 'MAXIMUMS (6s)',
                  t1Val: '$team1Sixes',
                  t2Val: '$team2Sixes',
                  t1Sub: '${team1Sixes * 6} runs',
                  t2Sub: '${team2Sixes * 6} runs',
                  icon: Icons.filter_6_rounded,
                  accentColor: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Boundary Run Percentage Comparison Bar
          _buildComparisonBar(
            title: 'Boundary Run Contribution %',
            t1ValStr: '${t1BoundaryPct.toStringAsFixed(1)}% (${t1BoundaryRuns}r)',
            t2ValStr: '${t2BoundaryPct.toStringAsFixed(1)}% (${t2BoundaryRuns}r)',
            ratio: (t1BoundaryPct + t2BoundaryPct) > 0 ? (t1BoundaryPct / (t1BoundaryPct + t2BoundaryPct)) : 0.5,
            barColor1: const Color(0xFF2563EB),
            barColor2: const Color(0xFF059669),
          ),
          const Divider(height: 24),

          // Dot Ball Percentage Comparison Bar
          _buildComparisonBar(
            title: 'Dot Ball Percentage (Deliveries without Runs)',
            t1ValStr: '${t1DotPct.toStringAsFixed(1)}% (${team1DotBalls} dots)',
            t2ValStr: '${t2DotPct.toStringAsFixed(1)}% (${team2DotBalls} dots)',
            ratio: (t1DotPct + t2DotPct) > 0 ? (t1DotPct / (t1DotPct + t2DotPct)) : 0.5,
            barColor1: const Color(0xFF64748B),
            barColor2: const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String t1Val,
    required String t2Val,
    required String t1Sub,
    required String t2Sub,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Team 1
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t1Val, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF2563EB))),
                    Text('$team1Short • $t1Sub', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Team 2
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(t2Val, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF059669))),
                    Text('$team2Short • $t2Sub', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar({
    required String title,
    required String t1ValStr,
    required String t2ValStr,
    required double ratio,
    required Color barColor1,
    required Color barColor2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$team1Short: $t1ValStr', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: barColor1)),
            Text('$team2Short: $t2ValStr', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: barColor2)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(flex: (ratio * 100).round().clamp(5, 95), child: Container(color: barColor1)),
                const SizedBox(width: 2),
                Expanded(flex: ((1.0 - ratio) * 100).round().clamp(5, 95), child: Container(color: barColor2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. CRICKET WAGON WHEEL GRAPH (FIELD SHOT VISUALIZER)
// ═══════════════════════════════════════════════════════════════════════════════

class CricketWagonWheelCard extends StatefulWidget {
  final List<CricketShotResult> shots;
  final String batsmanFilter;

  const CricketWagonWheelCard({
    super.key,
    required this.shots,
    this.batsmanFilter = 'All Batsmen',
  });

  @override
  State<CricketWagonWheelCard> createState() => _CricketWagonWheelCardState();
}

class _CricketWagonWheelCardState extends State<CricketWagonWheelCard> {
  int _shotFilter = 0; // 0 = All, 1 = Boundaries Only, 2 = 1s & 2s

  @override
  Widget build(BuildContext context) {
    final filteredShots = widget.shots.where((s) {
      if (_shotFilter == 1) return s.runs == 4 || s.runs == 6;
      if (_shotFilter == 2) return s.runs == 1 || s.runs == 2 || s.runs == 3;
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WAGON WHEEL SHOT MAP',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Spatial distribution of shots around the ground',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Filter Chips
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildWagonFilter(0, 'All'),
                    _buildWagonFilter(1, '4s & 6s'),
                    _buildWagonFilter(2, '1s-3s'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Wagon Wheel Graphic
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipOval(
                child: CustomPaint(
                  size: const Size(260, 260),
                  painter: _WagonWheelPainter(shots: filteredShots),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShotLegend(const Color(0xFF9333EA), '6s (Sixes)'),
              _buildShotLegend(const Color(0xFF10B981), '4s (Fours)'),
              _buildShotLegend(const Color(0xFF3B82F6), '1s - 3s (Runs)'),
              _buildShotLegend(const Color(0xFF94A3B8), '0s (Dots)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWagonFilter(int index, String label) {
    final isSelected = _shotFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _shotFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildShotLegend(Color c, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _WagonWheelPainter extends CustomPainter {
  final List<CricketShotResult> shots;

  _WagonWheelPainter({required this.shots});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outfield Base
    final grass = Paint()..color = const Color(0xFF0F5132);
    canvas.drawCircle(center, radius, grass);

    // 30 yard circle
    final circlePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.55, circlePaint);

    // Boundary Rope
    final boundary = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 2, boundary);

    // Pitch
    final pitch = Paint()..color = const Color(0xFFD4B996);
    canvas.drawRect(Rect.fromCenter(center: center, width: radius * 0.16, height: radius * 0.44), pitch);

    final creaseY = center.dy + (radius * 0.44 * 0.32);
    final origin = Offset(center.dx, creaseY);

    // Draw all shots
    for (final s in shots) {
      Color c;
      double width;
      if (s.runs == 6) {
        c = const Color(0xFFC084FC); // Purple
        width = 2.2;
      } else if (s.runs == 4) {
        c = const Color(0xFF34D399); // Emerald
        width = 1.8;
      } else if (s.runs == 0) {
        c = const Color(0xFF94A3B8); // Slate
        width = 1.0;
      } else {
        c = const Color(0xFF60A5FA); // Blue
        width = 1.4;
      }

      final targetDist = (radius - 8) * s.distance;
      final targetX = center.dx + math.sin(s.angle) * targetDist;
      final targetY = center.dy - math.cos(s.angle) * targetDist;

      final p = Paint()
        ..color = c.withValues(alpha: 0.85)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(origin, Offset(targetX, targetY), p);

      // Dot at landing
      final dot = Paint()..color = c;
      canvas.drawCircle(Offset(targetX, targetY), s.runs >= 4 ? 3.0 : 1.8, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _WagonWheelPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5. FOOTBALL TIMELINE & ATTACK MOMENTUM GRAPH
// ═══════════════════════════════════════════════════════════════════════════════

class FootballMomentumTimelineCard extends StatelessWidget {
  final String team1Name;
  final String team2Name;
  final String team1Short;
  final String team2Short;
  final int currentMinute;
  final List<Map<String, dynamic>> events;

  const FootballMomentumTimelineCard({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.team1Short,
    required this.team2Short,
    required this.currentMinute,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                    'TIMESTAMP VS GOAL & ATTACK MOMENTUM',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Match timeline (0\' - 90\') with goal and card events',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Minute $currentMinute\'',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Team Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('$team1Short (Attacking Pressure)', style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800, color: const Color(0xFF2563EB))),
                ],
              ),
              Row(
                children: [
                  Text('$team2Short (Attacking Pressure)', style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444))),
                  const SizedBox(width: 6),
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Momentum & Goal Canvas
          SizedBox(
            height: 170,
            width: double.infinity,
            child: CustomPaint(
              painter: _FootballMomentumPainter(
                currentMinute: currentMinute,
                events: events,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Goal Event Pills List
          if (events.isNotEmpty) ...[
            Text('GOAL & DISCIPLINARY LOG', style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            ...events.map((e) {
              final isT1 = e['team'] == 1;
              final isGoal = e['type'] == 'goal';
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(
                      '${e['minute']}\'',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      isGoal ? Icons.sports_soccer_rounded : Icons.square_rounded,
                      size: 15,
                      color: isGoal ? const Color(0xFF059669) : Colors.amber.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isGoal ? 'GOAL! ${e['player']}' : '${e['type']?.toString().toUpperCase()} - ${e['player']}',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    Text(
                      isT1 ? team1Short : team2Short,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isT1 ? const Color(0xFF2563EB) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _FootballMomentumPainter extends CustomPainter {
  final int currentMinute;
  final List<Map<String, dynamic>> events;

  _FootballMomentumPainter({required this.currentMinute, required this.events});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 20.0;
    const rightPad = 20.0;
    const topPad = 26.0;
    const botPad = 24.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - botPad;
    final centerY = topPad + (chartH / 2);

    // Center Baseline (0 momentum)
    final basePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(leftPad, centerY), Offset(size.width - rightPad, centerY), basePaint);

    // Minute intervals (0, 15, 30, 45 HT, 60, 75, 90)
    final labelStyle = const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8));
    for (int m = 0; m <= 90; m += 15) {
      final x = leftPad + (chartW * (m / 90.0));
      canvas.drawLine(Offset(x, topPad), Offset(x, size.height - botPad), Paint()..color = const Color(0xFFF1F5F9));

      final text = m == 45 ? 'HT' : '$m\'';
      final tp = TextPainter(text: TextSpan(text: text, style: labelStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - botPad + 4));
    }

    // Generate procedural realistic momentum oscillations based on minute
    final t1Path = Path();
    final t2Path = Path();
    t1Path.moveTo(leftPad, centerY);
    t2Path.moveTo(leftPad, centerY);

    final maxMin = math.min(90, currentMinute);
    for (int m = 0; m <= maxMin; m += 2) {
      final x = leftPad + (chartW * (m / 90.0));
      // Procedural momentum value (-1.0 to 1.0)
      final mom = math.sin(m * 0.18) * 0.7 + math.cos(m * 0.35) * 0.3;
      final val = mom * (chartH / 2.2);

      if (val >= 0) {
        t1Path.lineTo(x, centerY - val);
        t2Path.lineTo(x, centerY);
      } else {
        t1Path.lineTo(x, centerY);
        t2Path.lineTo(x, centerY - val);
      }
    }

    // Complete paths to base
    final endX = leftPad + (chartW * (maxMin / 90.0));
    t1Path.lineTo(endX, centerY);
    t2Path.lineTo(endX, centerY);

    // Draw Team 1 Momentum Fill (Blue)
    canvas.drawPath(
      t1Path,
      Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.25)..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      t1Path,
      Paint()..color = const Color(0xFF2563EB)..strokeWidth = 1.5..style = PaintingStyle.stroke,
    );

    // Draw Team 2 Momentum Fill (Red)
    canvas.drawPath(
      t2Path,
      Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.25)..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      t2Path,
      Paint()..color = const Color(0xFFEF4444)..strokeWidth = 1.5..style = PaintingStyle.stroke,
    );

    // Plot Goal Markers atop timeline
    for (final e in events) {
      final m = (e['minute'] as num?)?.toInt() ?? 0;
      final isT1 = e['team'] == 1;
      final x = leftPad + (chartW * (m / 90.0));
      final y = isT1 ? topPad - 8 : size.height - botPad + 18;

      // Goal Icon Marker
      final bg = Paint()..color = isT1 ? const Color(0xFF2563EB) : const Color(0xFFEF4444);
      canvas.drawCircle(Offset(x, isT1 ? topPad - 2 : size.height - botPad - 2), 6, bg);

      final tp = TextPainter(
        text: const TextSpan(text: '⚽', style: TextStyle(fontSize: 8)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, (isT1 ? topPad - 2 : size.height - botPad - 2) - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _FootballMomentumPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 6. BASKETBALL TIMELINE & LEAD TRACKER GRAPH
// ═══════════════════════════════════════════════════════════════════════════════

class BasketballLeadTrackerCard extends StatelessWidget {
  final String team1Short;
  final String team2Short;
  final int team1Score;
  final int team2Score;
  final int currentQuarter;

  const BasketballLeadTrackerCard({
    super.key,
    required this.team1Short,
    required this.team2Short,
    required this.team1Score,
    required this.team2Score,
    this.currentQuarter = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                    'SCORING PROGRESSION & LEAD TRACKER',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Point margin flow across Quarters 1 - 4',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Quarter $currentQuarter',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFEA580C)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lead differential curve
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _BasketballLeadPainter(
                team1Score: team1Score,
                team2Score: team2Score,
                currentQuarter: currentQuarter,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Quarter Scoring Breakdown Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuarterScore('Q1', '24 - 20'),
                _buildQuarterScore('Q2', '28 - 26'),
                _buildQuarterScore('Q3', '22 - 27'),
                _buildQuarterScore('Q4', '${team1Score - 74} - ${team2Score - 73}'),
                _buildQuarterScore('TOTAL', '$team1Score - $team2Score', isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterScore(String q, String score, {bool isBold = false}) {
    return Column(
      children: [
        Text(q, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: isBold ? AppColors.primary : AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(score, style: GoogleFonts.outfit(fontSize: 12, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _BasketballLeadPainter extends CustomPainter {
  final int team1Score;
  final int team2Score;
  final int currentQuarter;

  _BasketballLeadPainter({required this.team1Score, required this.team2Score, required this.currentQuarter});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 24.0;
    const rightPad = 20.0;
    const topPad = 16.0;
    const botPad = 22.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - botPad;
    final centerY = topPad + (chartH / 2);

    // Center Tie Line (0 lead)
    final tiePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(leftPad, centerY), Offset(size.width - rightPad, centerY), tiePaint);

    // Quarter divisions (Q1, Q2, Q3, Q4)
    final labelStyle = const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8));
    for (int q = 0; q <= 4; q++) {
      final x = leftPad + (chartW * (q / 4.0));
      canvas.drawLine(Offset(x, topPad), Offset(x, size.height - botPad), Paint()..color = const Color(0xFFF1F5F9));

      if (q > 0) {
        final tp = TextPainter(text: TextSpan(text: 'Q$q', style: labelStyle), textDirection: TextDirection.ltr)..layout();
        final prevX = leftPad + (chartW * ((q - 1) / 4.0));
        tp.paint(canvas, Offset(prevX + (x - prevX) / 2 - tp.width / 2, size.height - botPad + 4));
      }
    }

    // Lead Margin points
    final diff = team1Score - team2Score;
    final path = Path();
    path.moveTo(leftPad, centerY);

    final points = [
      Offset(leftPad, centerY),
      Offset(leftPad + chartW * 0.25, centerY - 18), // +4 T1
      Offset(leftPad + chartW * 0.50, centerY - 28), // +6 T1
      Offset(leftPad + chartW * 0.75, centerY + 12), // +3 T2
      Offset(leftPad + chartW, centerY - (diff * 2.5).clamp(-chartH / 2.2, chartH / 2.2)),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFEA580C)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _BasketballLeadPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 7. TABLE TENNIS STATS & MOMENTUM CARD
// ═══════════════════════════════════════════════════════════════════════════════

class TableTennisStatsCard extends StatelessWidget {
  final String player1Name;
  final String player2Name;
  final int p1Sets;
  final int p2Sets;
  final int p1CurrentPoints;
  final int p2CurrentPoints;
  final List<Map<String, int>> completedGames;

  const TableTennisStatsCard({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.p1Sets,
    required this.p2Sets,
    required this.p1CurrentPoints,
    required this.p2CurrentPoints,
    this.completedGames = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                    'TABLE TENNIS OFFICIAL METRICS',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '11-point game sets • Service & Rally Analytics',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Best of 5 Games',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF059669)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Game-by-Game Score Badges
          if (completedGames.isNotEmpty) ...[
            Text('COMPLETED GAMES', style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: completedGames.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final g = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'G$idx: ${g['p1'] ?? 11}-${g['p2'] ?? 9}',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Table Tennis Performance Metrics
          _buildTtMetricRow('Service Points Won %', '68%', '54%', 0.68),
          const Divider(height: 18),
          _buildTtMetricRow('Smash / Attack Winners', '18', '11', 0.62),
          const Divider(height: 18),
          _buildTtMetricRow('Longest Rally Length', '23 shots', '19 shots', 0.55),
          const Divider(height: 18),
          _buildTtMetricRow('Unforced Errors', '9', '16', 0.36),
          const Divider(height: 18),
          _buildTtMetricRow('Service Aces', '4', '1', 0.80),
        ],
      ),
    );
  }

  Widget _buildTtMetricRow(String label, String v1, String v2, double ratio) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(v1, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, color: const Color(0xFF059669))),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSecondary)),
            Text(v2, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, color: const Color(0xFF2563EB))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Expanded(flex: (ratio * 100).round().clamp(5, 95), child: Container(color: const Color(0xFF059669))),
                const SizedBox(width: 2),
                Expanded(flex: ((1.0 - ratio) * 100).round().clamp(5, 95), child: Container(color: const Color(0xFF2563EB))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
