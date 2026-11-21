import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/spending_breakdown_model.dart';

class CustomDonutChart extends StatelessWidget {
  final List<CategoryBreakdownItem> items;
  final double size;
  final String centerTitle;
  final String centerPercentage;
  final String centerSubtitle;

  const CustomDonutChart({
    super.key,
    required this.items,
    this.size = 190,
    required this.centerTitle,
    required this.centerPercentage,
    required this.centerSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartPainter(items: items),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerTitle.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  letterSpacing: 1.2,
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                centerPercentage,
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                centerSubtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryBreakdownItem> items;

  _DonutChartPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // Background track ring
    final bgPaint = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    const gapAngle = 0.04; // small gap between arcs for clean fintech look

    for (final item in items) {
      final sweepAngle = (item.amount / total) * 2 * math.pi - gapAngle;
      if (sweepAngle > 0) {
        final arcPaint = Paint()
          ..color = item.color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + (gapAngle / 2),
          sweepAngle,
          false,
          arcPaint,
        );
      }
      startAngle += (item.amount / total) * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

/// Circular gauge used on Category Budgets & Alerts screen
class CircularBudgetGauge extends StatelessWidget {
  final double percentage; // e.g. 71.5
  final double size;

  const CircularBudgetGauge({
    super.key,
    required this.percentage,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(percentage: percentage),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  fontSize: 18,
                ),
              ),
              Text(
                'Spent',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;

  _GaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 10.0;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Active Arc
    final sweepAngle = (percentage / 100).clamp(0.0, 1.0) * 2 * math.pi;
    final activePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}
