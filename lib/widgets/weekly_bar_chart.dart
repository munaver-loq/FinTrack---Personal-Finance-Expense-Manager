import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/spending_breakdown_model.dart';

class DashboardWeeklyBarChart extends StatelessWidget {
  final List<WeeklyBarData> bars;
  final String currencySymbol;

  const DashboardWeeklyBarChart({
    super.key,
    required this.bars,
    this.currencySymbol = r'$',
  });

  @override
  Widget build(BuildContext context) {
    WeeklyBarData? peakBar;
    for (final b in bars) {
      if (b.amount > 0 && (peakBar == null || b.amount > peakBar.amount)) {
        peakBar = b;
      }
    }
    final subtitleText = peakBar != null
        ? 'Peak day: ${peakBar.day} ($currencySymbol${peakBar.amount.toStringAsFixed(2)})'
        : 'No outflow recorded this week';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
        boxShadow: const [AppColors.cardShadow],
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
                      'Weekly Outflow',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This Week',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bars Row
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((bar) {
                final isPeak = bar.isPeak;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: bar.percentage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isPeak
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(alpha: 0.70),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  boxShadow: isPeak
                                      ? [
                                          const BoxShadow(
                                            color: Color(0x804CD6FB),
                                            blurRadius: 12,
                                            offset: Offset(0, -2),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bar.day,
                          style: AppTypography.labelSmall.copyWith(
                            color: isPeak ? AppColors.primary : AppColors.onSurfaceVariant,
                            fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsWeeklyTrendChart extends StatelessWidget {
  final List<WeeklyTrendData> trends;
  final String currencySymbol;
  final double monthlyCeiling;

  const AnalyticsWeeklyTrendChart({
    super.key,
    required this.trends,
    this.currencySymbol = r'$',
    this.monthlyCeiling = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyCap = monthlyCeiling > 0 ? (monthlyCeiling / 4.0) : 0.0;
    final subtitleText = weeklyCap > 0
        ? 'Target safe velocity: $currencySymbol${weeklyCap.toStringAsFixed(0)}/week'
        : 'Safe pace based on recorded ledger';
    final capText = weeklyCap > 0
        ? 'Cap $currencySymbol${weeklyCap.toStringAsFixed(0)}'
        : 'Cap Limit';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
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
                      'Weekly Spending Trend',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Trend Matrix',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart with Cap line
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                // Dashed Cap Line at 75% height
                Positioned(
                  top: 48,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          color: AppColors.surfaceContainer,
                          child: Text(
                            capText,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.outline,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth <= 0) return const SizedBox.shrink();
                            return CustomPaint(
                              size: Size(constraints.maxWidth, 1),
                              painter: _DashedLinePainter(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          color: AppColors.surfaceContainer,
                          child: Text(
                            'Peak Zone',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.error,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4 Bars
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: trends.map((trend) {
                    final isPeak = trend.isPeak;
                    final isSafe = trend.isSafe;

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isPeak) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Peak $currencySymbol${trend.amount.toInt()}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          if (isSafe) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.tertiary,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$currencySymbol${trend.amount.toInt()}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.tertiary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              '$currencySymbol${trend.amount.toInt()}',
                              style: AppTypography.labelSmall.copyWith(
                                color: isPeak ? AppColors.error : AppColors.onSurfaceVariant,
                                fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 100 * trend.heightPercentage,
                            width: 38,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isPeak
                                    ? AppColors.primary
                                    : (isSafe
                                        ? AppColors.tertiaryContainer
                                        : AppColors.secondaryContainer),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                boxShadow: isPeak
                                    ? [
                                        const BoxShadow(
                                          color: Color(0x804CD6FB),
                                          blurRadius: 12,
                                          offset: Offset(0, -2),
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trend.weekLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: isPeak ? AppColors.primary : AppColors.onSurfaceVariant,
                              fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                dotColor: AppColors.primary,
                label: 'Actual Outflow',
                hasGlow: true,
              ),
              _buildLegendItem(
                dotColor: AppColors.outline,
                label: 'Budget Ceiling',
                isDash: true,
              ),
              _buildLegendItem(
                dotColor: AppColors.tertiary,
                label: 'Safe Pace',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color dotColor,
    required String label,
    bool isDash = false,
    bool hasGlow = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDash)
          Container(
            width: 10,
            height: 2,
            color: dotColor,
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: hasGlow
                  ? [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.8),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.70)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
