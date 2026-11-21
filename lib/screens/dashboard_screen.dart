import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/transaction_model.dart';
import '../state/finance_state.dart';
import '../widgets/account_switcher_sheet.dart';
import '../widgets/create_account_sheet.dart';
import '../widgets/receipt_scanner_sheet.dart';
import '../widgets/sqlite_inspector_sheet.dart';
import '../widgets/transfer_funds_sheet.dart';
import '../widgets/user_avatar_view.dart';
import '../widgets/weekly_bar_chart.dart';

class DashboardScreen extends StatelessWidget {
  final FinanceState state;
  final VoidCallback onNavigateToBudgets;
  final VoidCallback onAddTransaction;
  final Function({
    required String title,
    required String category,
    required double amount,
    required String notes,
  })? onAddTransactionPrefilled;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onNavigateToBudgets,
    required this.onAddTransaction,
    this.onAddTransactionPrefilled,
  });

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
              // 1. Top Greeting Header
              _buildGreetingHeader(context),
              const SizedBox(height: 16),

              // 2. Total Net Liquidity Hero Card OR Add Account Hero Card
              if (state.hasAccount)
                _buildNetLiquidityCard(context)
              else
                _buildAddAccountHeroCard(context),
              const SizedBox(height: 16),

              // 3. Quick Action Pills
              _buildQuickActionPills(context),
              const SizedBox(height: 16),

              // 4. Monthly Budget Pace Card
              _buildBudgetPulseCard(context),
              const SizedBox(height: 16),

              // 5. Weekly Outflow Micro-Chart
              DashboardWeeklyBarChart(
                bars: state.dashboardWeeklyBars,
                currencySymbol: state.currencySymbol,
              ),
              const SizedBox(height: 20),

              // 6. Recent Transactions Section
              _buildRecentTransactionsSection(context),
              const SizedBox(height: 16),

              // 7. Interactive SQLite Diagnostic Card (Tappable!)
              _buildDiagnosticCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    final profile = state.currentProfile;
    final firstName = profile.name.trim().isNotEmpty ? profile.name.trim().split(' ').first : 'Guest';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (state.hasAccount) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => AccountSwitcherSheet(state: state),
                    );
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => CreateAccountSheet(state: state),
                    );
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    UserAvatarView(
                      photoUrl: profile.photoUrl,
                      size: 48,
                      borderColor: AppColors.primary,
                      borderWidth: 1.5,
                    ),
                    if (!state.hasAccount)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.onPrimary,
                            size: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.hasAccount ? 'Good evening, $firstName' : 'Welcome to FinTrack',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.hasAccount ? profile.email : 'Tap avatar or card to add account',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
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
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(
            Icons.search_rounded,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          onPressed: () {
            _showSearchModal(context);
          },
        ),
      ],
    );
  }

  Widget _buildAddAccountHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderStroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1400B4D8),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'ACCOUNT SETUP',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 18),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'No Account Configured',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create an account with your preferred currency, name, and profile photo to track your net liquidity and expenses.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                    label: const Text(
                      'Add Account',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => CreateAccountSheet(state: state),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetLiquidityCard(BuildContext context) {
    final totalIncome = state.monthlyIncome;
    final totalExpenses = state.monthlyExpenses;
    String flowBadgeText;
    Color flowBadgeColor;
    Color flowBadgeBg;
    if (totalIncome == 0 && totalExpenses == 0) {
      flowBadgeText = '0.0%';
      flowBadgeColor = AppColors.onSurfaceVariant;
      flowBadgeBg = AppColors.surfaceContainerHigh;
    } else if (totalIncome > 0) {
      final rate = (((totalIncome - totalExpenses) / totalIncome) * 100).clamp(-999.0, 999.0);
      if (rate >= 0) {
        flowBadgeText = '+${rate.toStringAsFixed(1)}%';
        flowBadgeColor = AppColors.tertiary;
        flowBadgeBg = AppColors.tertiary.withValues(alpha: 0.15);
      } else {
        flowBadgeText = '${rate.toStringAsFixed(1)}%';
        flowBadgeColor = AppColors.alertDanger;
        flowBadgeBg = AppColors.alertDanger.withValues(alpha: 0.15);
      }
    } else {
      flowBadgeText = '-100%';
      flowBadgeColor = AppColors.alertDanger;
      flowBadgeBg = AppColors.alertDanger.withValues(alpha: 0.15);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderStroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1400B4D8),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Glow effects
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withValues(alpha: 0.10),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'TOTAL NET LIQUIDITY',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        state.isBalanceHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      splashRadius: 20,
                      onPressed: () => state.toggleBalanceVisibility(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Amount & badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          state.isBalanceHidden
                              ? '••••••••'
                              : '${state.currencySymbol}${state.totalLiquidity.toStringAsFixed(2)}',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: flowBadgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        flowBadgeText,
                        style: AppTypography.labelMedium.copyWith(
                          color: flowBadgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Income & Expense flow pills
                Row(
                  children: [
                    // Income Pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                color: AppColors.tertiary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'INCOME',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    state.isBalanceHidden
                                        ? '••••'
                                        : '+${state.currencySymbol}${state.monthlyIncome.toStringAsFixed(2)}',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.tertiary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Expenses Pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.alertDanger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
                                color: AppColors.alertDanger,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EXPENSES',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    state.isBalanceHidden
                                        ? '••••'
                                        : '-${state.currencySymbol}${state.monthlyExpenses.toStringAsFixed(2)}',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.alertDanger,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildQuickActionPills(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildActionPill(
            icon: Icons.document_scanner_rounded,
            iconColor: AppColors.primary,
            label: 'Scan Receipt',
            onTap: () {
              _simulateReceiptScan(context);
            },
          ),
          const SizedBox(width: 10),
          _buildActionPill(
            icon: Icons.sync_alt_rounded,
            iconColor: AppColors.secondary,
            label: 'Send/Transfer',
            onTap: () {
              _showTransferModal(context);
            },
          ),
          const SizedBox(width: 10),
          _buildActionPill(
            icon: Icons.pie_chart_rounded,
            iconColor: AppColors.tertiary,
            label: 'Budget Status',
            onTap: onNavigateToBudgets,
          ),
          const SizedBox(width: 10),
          _buildActionPill(
            icon: Icons.file_present_rounded,
            iconColor: AppColors.onSurfaceVariant,
            label: 'Export CSV',
            onTap: () {
              _showCsvExportDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPulseCard(BuildContext context) {
    final double ceiling = state.monthlyBudgetCeiling;
    final double expenses = state.monthlyExpenses;
    final double percent = (ceiling > 0)
        ? (expenses / ceiling).clamp(0.0, 1.0)
        : 0.0;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = (daysInMonth - now.day).clamp(1, 31);

    String paceStatus;
    Color paceStatusColor;
    Color paceStatusBg;
    if (ceiling == 0) {
      paceStatus = 'NO CEILING';
      paceStatusColor = AppColors.onSurfaceVariant;
      paceStatusBg = AppColors.surfaceContainerHigh;
    } else if (expenses > ceiling) {
      paceStatus = 'OVER BUDGET';
      paceStatusColor = AppColors.alertDanger;
      paceStatusBg = AppColors.alertDanger.withValues(alpha: 0.20);
    } else if (percent >= 0.85) {
      paceStatus = 'NEAR LIMIT';
      paceStatusColor = AppColors.alertWarning;
      paceStatusBg = AppColors.alertWarning.withValues(alpha: 0.20);
    } else {
      paceStatus = 'SAFE ZONE';
      paceStatusColor = AppColors.tertiary;
      paceStatusBg = AppColors.tertiary.withValues(alpha: 0.20);
    }

    final remainingBudget = (ceiling - expenses).clamp(0.0, double.infinity);
    final dailyLeft = (ceiling > 0 && daysRemaining > 0) ? (remainingBudget / daysRemaining) : 0.0;
    final dailyText = ceiling > 0
        ? '~${state.currencySymbol}${dailyLeft.toStringAsFixed(2)}/day left'
        : 'Set limits in Budgets tab';

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
                child: Row(
                  children: [
                    const Icon(Icons.speed_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Monthly Budget Pace',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: paceStatusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  paceStatus,
                  style: AppTypography.labelSmall.copyWith(
                    color: paceStatusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${(percent * 100).toInt()}%',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.bodySmall,
                      children: [
                        TextSpan(
                          text: '${state.currencySymbol}${state.monthlyExpenses.toStringAsFixed(2)} ',
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'of ${state.currencySymbol}${state.monthlyBudgetCeiling.toStringAsFixed(0)}.00',
                          style: const TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '$daysRemaining ${daysRemaining == 1 ? "day" : "days"} remaining',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  dailyText,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context) {
    final today = DateTime.now();
    final todayTxs = state.transactions.where((t) =>
        t.date.year == today.year &&
        t.date.month == today.month &&
        t.date.day == today.day).length;
    final txBadgeText = state.transactions.isEmpty
        ? '0 logged'
        : (todayTxs > 0 ? '$todayTxs today' : '${state.transactions.length} total');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Recent Transactions',
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      txBadgeText,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _showAllTransactionsModal(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of transactions or empty state
        if (state.transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  'No Transactions Yet',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total shows ${state.currencySymbol}0.00. Log your first transaction below to start building your ledger!',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Transaction'),
                  onPressed: onAddTransaction,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.transactions.length.clamp(0, 4),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tx = state.transactions[index];
              return InkWell(
                onTap: () => _showTransactionDetails(context, tx),
                borderRadius: BorderRadius.circular(16),
                child: _buildTransactionRow(tx),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTransactionRow(TransactionModel tx) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tx.iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tx.icon, color: tx.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.category} • ${tx.time}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx.formatAmount(state.currencySymbol),
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tx.isIncome ? AppColors.tertiary : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              if (tx.badgeText != null)
                Text(
                  tx.badgeText!,
                  style: AppTypography.labelSmall.copyWith(
                    color: tx.badgeColor ?? AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => SqliteInspectorSheet(state: state),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.storage_rounded, color: AppColors.tertiary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: AppTypography.bodySmall,
                        children: [
                          const TextSpan(
                            text: 'Encrypted SQLite DB: ',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                          TextSpan(
                            text: '${state.totalRecordsCount} Records (Tap Console)',
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${state.dbLatencyMs.toStringAsFixed(1)}ms Latency',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateReceiptScan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptScannerSheet(
        onReceiptScanned: ({
          required String merchant,
          required double amount,
          required String category,
          required String notes,
        }) {
          if (onAddTransactionPrefilled != null) {
            onAddTransactionPrefilled!(
              title: merchant,
              category: category,
              amount: amount,
              notes: notes,
            );
          } else {
            onAddTransaction();
          }
        },
      ),
    );
  }

  void _showTransferModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TransferFundsSheet(
        accounts: state.accounts,
        onTransfer: ({required fromId, required toId, required amount}) {
          state.transferBetweenAccounts(
            fromAccountId: fromId,
            toAccountId: toId,
            amount: amount,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceContainerHigh,
              content: Text(
                'Successfully transferred \$${amount.toStringAsFixed(2)} between accounts!',
                style: const TextStyle(color: AppColors.tertiary),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCsvExportDialog(BuildContext context) {
    final csvData = state.getCsvExport();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Row(
          children: [
            Icon(Icons.file_present_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Analytical Ledger CSV'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export generated with ${state.transactions.length} records:',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              width: double.maxFinite,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  csvData,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
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
                  content: Text('CSV successfully downloaded to internal storage.'),
                ),
              );
            },
            child: const Text('Download CSV'),
          ),
        ],
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final results = state.transactions.where((t) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return t.title.toLowerCase().contains(q) ||
                  t.category.toLowerCase().contains(q) ||
                  (t.notes != null && t.notes!.toLowerCase().contains(q));
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: 480,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      child: TextField(
                        autofocus: true,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: const InputDecoration(
                          hintText: 'Search transactions, payees, notes...',
                          hintStyle: TextStyle(color: AppColors.outline),
                          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${results.length} matches found in SQLite',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final tx = results[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              _showTransactionDetails(context, tx);
                            },
                            child: _buildTransactionRow(tx),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAllTransactionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Transactions (${state.transactions.length})',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onAddTransaction();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: state.transactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final tx = state.transactions[i];
                    return Dismissible(
                      key: Key(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.alertDanger,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        state.deleteTransaction(tx.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted "${tx.title}"')),
                        );
                      },
                      child: InkWell(
                        onTap: () => _showTransactionDetails(context, tx),
                        child: _buildTransactionRow(tx),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: tx.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(tx.icon, color: tx.iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text(tx.category, style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
                Text(
                  tx.formatAmount(state.currencySymbol),
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tx.isIncome ? AppColors.tertiary : AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tx.notes != null && tx.notes!.isNotEmpty) ...[
              Text('Memo', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(tx.notes!, style: AppTypography.bodyMedium),
              const SizedBox(height: 12),
            ],
            if (tx.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                children: tx.tags.map((t) => Chip(
                  label: Text(t, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.surfaceContainer,
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.alertDanger,
                      side: const BorderSide(color: AppColors.alertDanger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete Entry'),
                    onPressed: () {
                      state.deleteTransaction(tx.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Transaction "${tx.title}" deleted.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHighest,
                      foregroundColor: AppColors.onSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
