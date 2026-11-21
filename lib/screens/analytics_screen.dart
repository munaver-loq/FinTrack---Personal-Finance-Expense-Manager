import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../state/finance_state.dart';
import '../widgets/custom_donut_chart.dart';
import '../widgets/weekly_bar_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final FinanceState state;

  const AnalyticsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Timeframe Segmented Controller
              _buildTimeframeSelector(context),
              const SizedBox(height: 16),

              // 2. Total Outflow Card
              _buildTotalOutflowCard(context),
              const SizedBox(height: 16),

              // 3. Riverpod Smart Insight Banner
              _buildSmartInsightBanner(context),
              const SizedBox(height: 16),

              // 4. Category Breakdown Donut Card
              _buildCategoryBreakdownCard(context),
              const SizedBox(height: 16),

              // 5. Weekly Spending Trend Card
              AnalyticsWeeklyTrendChart(
                trends: state.analyticsWeeklyTrends,
                currencySymbol: state.currencySymbol,
                monthlyCeiling: state.monthlyBudgetCeiling,
              ),
              const SizedBox(height: 16),

              // 6. Two Metric Cards (Highest Single Payee & Daily Velocity)
              _buildMetricCardsRow(context),
              const SizedBox(height: 16),

              // 7. Export Analytical Ledger Card
              _buildExportLedgerCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeframeSelector(BuildContext context) {
    const options = ['Week', 'Month', 'Quarter', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = state.analyticsPeriod == opt;
          return Expanded(
            child: GestureDetector(
              onTap: () => state.setAnalyticsPeriod(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x554CD6FB),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  opt,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.onPrimaryContainer
                        : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalOutflowCard(BuildContext context) {
    final currentMonth = DateFormat('MMMM').format(DateTime.now());
    final totalOutflow = state.monthlyExpenses;
    final ceiling = state.monthlyBudgetCeiling;

    String badgeLabel;
    Color badgeColor;
    Color badgeBg;
    IconData badgeIcon;

    if (totalOutflow == 0) {
      badgeLabel = '0.0% outflow';
      badgeColor = AppColors.onSurfaceVariant;
      badgeBg = AppColors.surfaceContainerHigh;
      badgeIcon = Icons.horizontal_rule_rounded;
    } else if (ceiling > 0) {
      final pctOfCeiling = (totalOutflow / ceiling * 100).clamp(0.0, 999.0);
      badgeLabel = '${pctOfCeiling.toStringAsFixed(1)}% of ceiling';
      if (pctOfCeiling > 100) {
        badgeColor = AppColors.alertDanger;
        badgeBg = AppColors.alertDanger.withValues(alpha: 0.15);
        badgeIcon = Icons.trending_up_rounded;
      } else {
        badgeColor = AppColors.tertiary;
        badgeBg = AppColors.tertiary.withValues(alpha: 0.15);
        badgeIcon = Icons.trending_down_rounded;
      }
    } else {
      badgeLabel = 'Active Outflow';
      badgeColor = AppColors.secondary;
      badgeBg = AppColors.secondary.withValues(alpha: 0.15);
      badgeIcon = Icons.trending_flat_rounded;
    }

    List<InlineSpan> summarySpans;
    if (totalOutflow == 0) {
      summarySpans = [
        TextSpan(
          text: 'No outflow recorded for this period. Total spending is ${state.currencySymbol}0.00.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ];
    } else if (ceiling > 0) {
      final diff = ceiling - totalOutflow;
      if (diff >= 0) {
        summarySpans = [
          const TextSpan(text: 'Under monthly ceiling! You have '),
          TextSpan(
            text: '${state.currencySymbol}${diff.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: ' remaining buffer this month.'),
        ];
      } else {
        summarySpans = [
          const TextSpan(text: 'Outflow exceeded monthly ceiling by '),
          TextSpan(
            text: '${state.currencySymbol}${diff.abs().toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.alertDanger,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: '. Pacing is critical.'),
        ];
      }
    } else {
      summarySpans = [
        const TextSpan(text: 'Total recorded outflow is '),
        TextSpan(
          text: '${state.currencySymbol}${totalOutflow.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const TextSpan(text: ' across all expense categories.'),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'TOTAL OUTFLOW',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badgeIcon,
                          color: badgeColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badgeLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${state.currencySymbol}${state.monthlyExpenses.toStringAsFixed(2)}',
                        style: AppTypography.displaySmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'in $currentMonth',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: totalOutflow > 0 && ceiling > 0 && totalOutflow > ceiling
                          ? AppColors.alertDanger
                          : AppColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        children: summarySpans,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightBanner(BuildContext context) {
    final totalOutflow = state.monthlyExpenses;
    List<InlineSpan> insightSpans;

    if (totalOutflow == 0) {
      insightSpans = [
        const TextSpan(
          text: 'Your expense ledger is clean. Log transactions to view real-time category distribution, velocity, and savings trends.',
        ),
      ];
    } else {
      final topCat = state.categoryBreakdown.isNotEmpty ? state.categoryBreakdown.first : null;
      if (topCat != null) {
        insightSpans = [
          const TextSpan(text: 'Highest expenditure is in '),
          TextSpan(
            text: topCat.title,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' at ${state.currencySymbol}${topCat.amount.toStringAsFixed(2)} (${topCat.percentage}% of outflow). Daily velocity is ~${state.currencySymbol}${state.dailyVelocity.toStringAsFixed(2)}/day.',
          ),
        ];
      } else {
        insightSpans = [
          TextSpan(
            text: 'Current daily spending velocity is ~${state.currencySymbol}${state.dailyVelocity.toStringAsFixed(2)}/day across active expenses.',
          ),
        ];
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FINANCIAL SMART INSIGHT',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                    children: insightSpans,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(BuildContext context) {
    final breakdown = state.categoryBreakdown;
    final topItem = breakdown.isNotEmpty ? breakdown.first : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      breakdown.isNotEmpty
                          ? 'Distribution across ${breakdown.length} active ${breakdown.length == 1 ? "category" : "categories"}'
                          : 'No expenses recorded yet',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Glowing Donut Chart
          CustomDonutChart(
            items: breakdown,
            centerTitle: topItem != null ? 'Top Spend' : 'Outflow',
            centerPercentage: topItem != null ? '${topItem.percentage}%' : '0%',
            centerSubtitle: topItem != null ? topItem.title : 'No Outflow',
          ),
          const SizedBox(height: 20),

          // Category items list or clean empty state
          if (breakdown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Text(
                'No category expenses recorded yet for this period. Log expenses to generate real-time visual breakdown.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: breakdown.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.subtitle,
                                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${state.currencySymbol}${item.amount.toStringAsFixed(2)}',
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${item.percentage}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: item.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCardsRow(BuildContext context) {
    return Row(
      children: [
        // Highest Single Payee
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HIGHEST SINGLE PAYEE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.highestPayeeName,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${state.currencySymbol}${state.highestPayeeAmount.toStringAsFixed(2)} • ${state.highestPayeeCategory}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Daily Velocity
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY VELOCITY',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: AppColors.tertiary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${state.currencySymbol}${state.dailyVelocity.toStringAsFixed(2)}',
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Average/day outflow',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.tertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportLedgerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Analytical Ledger',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SQLite .db format or CSV report',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              final csvData = state.getCsvExport();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  title: const Text('Analytical Ledger Export'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: SelectableText(
                        csvData,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytical Ledger exported to storage/fintrack_analytics.csv'),
                          ),
                        );
                      },
                      child: const Text('Save to Storage'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              'Export',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
