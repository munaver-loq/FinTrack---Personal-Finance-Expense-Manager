import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/category_budget_model.dart';
import '../state/finance_state.dart';
import '../widgets/custom_donut_chart.dart';
import '../widgets/budget_limit_modal.dart';

class BudgetsScreen extends StatelessWidget {
  final FinanceState state;

  const BudgetsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final warningBudget = state.budgets.where((b) => b.isNearLimit).firstOrNull;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Period Selector & Filter
              _buildPeriodSelector(context),
              const SizedBox(height: 16),

              // 2. Top Monthly Budget Overview Card
              _buildMonthlyOverviewCard(context),
              const SizedBox(height: 16),

              // 3. Warning Threshold Alert Banner (dismissible)
              if (!state.isWarningBannerDismissed && warningBudget != null) ...[
                _buildWarningThresholdBanner(context, warningBudget),
                const SizedBox(height: 16),
              ],

              // 4. Instant Push Alerts Card
              _buildPushAlertsCard(context),
              const SizedBox(height: 16),

              // 5. Category Budgets Header
              _buildBudgetsListHeader(context),
              const SizedBox(height: 12),

              // 6. Category Budgets List
              ...state.budgets.map((budget) => _buildCategoryBudgetCard(context, budget)),

              const SizedBox(height: 8),

              // 7. Create New Category Limit Button
              _buildCreateLimitButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final now = DateTime.now();
    final formattedMonth = DateFormat('MMMM yyyy').format(now);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    formattedMonth,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Filter (${state.budgets.length} Active)',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyOverviewCard(BuildContext context) {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = (lastDay - now.day).clamp(0, 31);
    final daysText = daysRemaining == 0 ? 'Today' : '$daysRemaining days remaining';

    final ceiling = state.monthlyBudgetCeiling;
    final spent = state.monthlyExpenses;
    final percentage = ceiling > 0 ? ((spent / ceiling) * 100).clamp(0.0, 100.0) : 0.0;

    final String paceText;
    final Color paceColor;
    if (ceiling <= 0) {
      paceText = 'No Limit';
      paceColor = AppColors.onSurfaceVariant;
    } else if (spent > ceiling) {
      paceText = 'Exceeded';
      paceColor = AppColors.alertDanger;
    } else if (percentage >= 80) {
      paceText = 'Near Limit';
      paceColor = AppColors.warningAmber;
    } else {
      paceText = 'Paced OK';
      paceColor = AppColors.tertiary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Row(
            children: [
              // Gauge
              CircularBudgetGauge(percentage: percentage, size: 78),
              const SizedBox(width: 12),

              // Overview Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'MONTHLY CEILING',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                          children: [
                            TextSpan(text: '${state.currencySymbol}${state.monthlyExpenses.toInt()} '),
                            TextSpan(
                              text: '/ ${state.currencySymbol}${state.monthlyBudgetCeiling.toInt()}',
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.currencySymbol}${((state.monthlyBudgetCeiling - state.monthlyExpenses).clamp(0, 999999)).toInt()} left',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.tertiary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  daysText,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 9.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: paceColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              paceText,
                              style: AppTypography.labelSmall.copyWith(
                                color: paceColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningThresholdBanner(BuildContext context, CategoryBudgetModel warningBudget) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorContainer.withValues(alpha: 0.40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_rounded, color: AppColors.onErrorContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        warningBudget.spent >= warningBudget.limit
                            ? 'Limit Exceeded'
                            : 'Warning Threshold Reached',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.onErrorContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${warningBudget.percentSpentInt}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySmall.copyWith(color: AppColors.onSurface),
                    children: [
                      TextSpan(
                        text: warningBudget.name,
                        style: const TextStyle(
                          color: AppColors.alertDanger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' is at ${warningBudget.percentSpentInt}% of monthly limit (${state.currencySymbol}${warningBudget.spent.toInt()} / ${state.currencySymbol}${warningBudget.limit.toInt()}). Threshold alert set at ${warningBudget.thresholdPercent.toInt()}%.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerHighest,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      icon: const Icon(Icons.edit_calendar_rounded, size: 14),
                      label: const Text('Adjust Limit', style: TextStyle(fontSize: 12)),
                      onPressed: () => _showAdjustLimitModal(context, warningBudget),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => state.dismissWarningBanner(),
                      child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPushAlertsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
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
                        'Instant Push Alerts',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Triggers automatically at 80% limit',
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
          Switch(
            value: state.pushAlertsEnabled,
            activeTrackColor: AppColors.primaryContainer,
            activeThumbColor: AppColors.onPrimary,
            inactiveTrackColor: AppColors.surfaceContainerHighest,
            onChanged: (val) => state.togglePushAlerts(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsListHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Category Budgets',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.budgets.length} Limits',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Reset Auto-Sort',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBudgetCard(BuildContext context, CategoryBudgetModel budget) {
    final percent = budget.percentSpent;
    final isAlert = budget.isNearLimit;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
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
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: budget.iconBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(budget.icon, color: budget.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            budget.subtitle,
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            maxLines: 1,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(text: '${state.currencySymbol}${budget.spent.toInt()} '),
                        TextSpan(
                          text: '/ ${state.currencySymbol}${budget.limit.toInt()}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: budget.statusBgColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${budget.percentSpentInt}% • ${budget.status}',
                      style: AppTypography.labelSmall.copyWith(
                        color: budget.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Track with threshold tick
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAlert ? AppColors.alertDanger : budget.color,
                  ),
                ),
              ),
              if (budget.thresholdPercent > 0)
                Positioned(
                  left: (MediaQuery.of(context).size.width - 64) *
                      (budget.thresholdPercent / 100),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: AppColors.onSurface.withValues(alpha: 0.70),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Footer info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Remaining: ${state.currencySymbol}${budget.remaining.toInt()}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: GestureDetector(
                  onTap: () => _showAdjustLimitModal(context, budget),
                  child: Text(
                    budget.footerRight,
                    style: AppTypography.labelSmall.copyWith(
                      color: isAlert ? AppColors.alertDanger : AppColors.tertiary,
                      fontWeight: isAlert ? FontWeight.bold : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateLimitButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _showAddLimitModal(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '+ Create New Category Limit',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustLimitModal(BuildContext context, CategoryBudgetModel budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BudgetLimitModal(
        budget: budget,
        currencySymbol: state.currencySymbol,
        onSave: (newLimit, newThreshold) {
          state.updateCategoryLimit(budget.id, newLimit, newThreshold);
        },
      ),
    );
  }

  void _showAddLimitModal(BuildContext context) {
    final nameController = TextEditingController();
    final limitController = TextEditingController(text: '300');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Budget Limit',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: InputDecoration(
                labelText: 'Monthly Limit (${state.currencySymbol})',
                labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final catName = nameController.text.isNotEmpty ? nameController.text : 'Personal & Wellness';
                  final catLimit = double.tryParse(limitController.text) ?? 300.0;
                  state.addCategoryBudget(name: catName, limit: catLimit);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      content: Text(
                        'New budget category "$catName" (${state.currencySymbol}${catLimit.toInt()}/mo) added to SQLite!',
                        style: const TextStyle(color: AppColors.tertiary),
                      ),
                    ),
                  );
                },
                child: const Text('Add Category Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
