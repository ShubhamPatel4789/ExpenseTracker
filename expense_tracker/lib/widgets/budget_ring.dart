import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class BudgetRing extends StatelessWidget {
  final String label;
  final double spent;
  final double limit;
  final double percent;

  const BudgetRing({
    super.key,
    required this.label,
    required this.spent,
    required this.limit,
    required this.percent,
  });

  Color get _color {
    if (percent >= 1.0) return AppTheme.error;
    if (percent >= 0.8) return AppTheme.warning;
    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    final displayPercent = percent.clamp(0.0, 1.5); // allow visual overflow up to 150%
    final clampedForDraw = displayPercent.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: CustomPaint(
              painter: _RingPainter(
                percent: clampedForDraw,
                overBudget: percent > 1.0,
                color: _color,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: _color,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (percent > 1.0)
                      const Text('Over',
                          style: TextStyle(
                              color: AppTheme.error,
                              fontSize: 9,
                              fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            Formatters.shortCurrency(spent),
            style: TextStyle(
                color: _color, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          Text(
            'of ${Formatters.shortCurrency(limit)}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final bool overBudget;
  final Color color;

  _RingPainter(
      {required this.percent,
      required this.overBudget,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const strokeWidth = 10.0;

    // Background ring
    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (overBudget) {
      // Full ring + glowing effect for over budget
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, glowPaint);
      canvas.drawCircle(center, radius, progressPaint);
    } else {
      final sweep = 2 * math.pi * percent;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent || old.color != color;
}
