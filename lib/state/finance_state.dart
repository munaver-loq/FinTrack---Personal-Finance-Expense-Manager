import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/category_budget_model.dart';
import '../models/spending_breakdown_model.dart';
import '../models/transaction_model.dart';
import '../models/user_profile_model.dart';
import '../services/mock_database_service.dart';

class FinanceState extends ChangeNotifier {
  final MockDatabaseService _db = MockDatabaseService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isBalanceHidden = false;
  bool get isBalanceHidden => _isBalanceHidden;

  bool _pushAlertsEnabled = true;
  bool get pushAlertsEnabled => _pushAlertsEnabled;

  bool _isWarningBannerDismissed = false;
  bool get isWarningBannerDismissed => _isWarningBannerDismissed;

  String _analyticsPeriod = 'Month';
  String get analyticsPeriod => _analyticsPeriod;

  String? _selectedCategoryFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;

  FinanceState() {
    _init();
  }

  Future<void> _init() async {
    await _db.init();
    _isInitialized = true;
    notifyListeners();
  }

  // --- User Profiles & Currency ---

  List<UserProfileModel> get userProfiles => _db.profiles;
  bool get hasAccount => userProfiles.isNotEmpty;
  UserProfileModel get currentProfile => _db.activeProfile;

  String get currencySymbol => currentProfile.currencySymbol;
  String get currencyCode => currentProfile.currencyCode;

  Future<void> switchProfile(String id) async {
    await _db.switchProfile(id);
    notifyListeners();
  }

  Future<void> createProfile({
    required String name,
    required String email,
    required String photoUrl,
    required String currencyCode,
    required String currencySymbol,
  }) async {
    final profile = UserProfileModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      photoUrl: photoUrl,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      tier: 'PERSONAL TIER',
    );
    await _db.createProfile(profile);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String id,
    required String name,
    required String email,
    required String photoUrl,
    required String currencyCode,
    required String currencySymbol,
  }) async {
    await _db.updateProfile(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
    );
    notifyListeners();
  }

  Future<bool> deleteProfile(String id) async {
    await _db.deleteProfile(id);
    notifyListeners();
    return true;
  }

  Future<void> setCurrency(String code, String symbol) async {
    await _db.updateActiveProfileCurrency(code, symbol);
    notifyListeners();
  }

  // --- Dynamic Financial Calculations ---

  List<AccountBalance> get accounts => _db.accounts;

  double get totalLiquidity {
    if (!hasAccount || _db.accounts.isEmpty) return 0.00;
    final checking = _db.accounts.firstWhere(
      (a) => a.id.contains('checking'),
      orElse: () => _db.accounts.first,
    );
    return checking.balance;
  }

  double get monthlyIncome {
    double sum = 0.0;
    for (final tx in _db.transactions) {
      if (tx.isIncome) {
        sum += tx.amount.abs();
      }
    }
    return sum;
  }

  double get monthlyExpenses {
    double sum = 0.0;
    for (final tx in _db.transactions) {
      if (!tx.isIncome && tx.type != TransactionType.transfer) {
        sum += tx.amount.abs();
      }
    }
    return sum;
  }

  double get monthlyBudgetCeiling {
    double sum = 0.0;
    for (final b in _db.budgets) {
      sum += b.limit;
    }
    return sum;
  }

  String get highestPayeeName {
    final expenses = transactions.where((t) => !t.isIncome && t.type != TransactionType.transfer).toList();
    if (expenses.isEmpty) return 'None';
    expenses.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    return expenses.first.title;
  }

  double get highestPayeeAmount {
    final expenses = transactions.where((t) => !t.isIncome && t.type != TransactionType.transfer).toList();
    if (expenses.isEmpty) return 0.0;
    expenses.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    return expenses.first.amount.abs();
  }

  String get highestPayeeCategory {
    final expenses = transactions.where((t) => !t.isIncome && t.type != TransactionType.transfer).toList();
    if (expenses.isEmpty) return 'No expenses yet';
    expenses.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    return expenses.first.category;
  }

  double get dailyVelocity {
    return monthlyExpenses / 30.0;
  }

  List<TransactionModel> get transactions => _db.transactions;

  List<CategoryBudgetModel> get budgets => _db.budgets;

  double get dbLatencyMs => _db.lastQueryLatencyMs;

  int get totalRecordsCount => _db.transactions.length + _db.budgets.length + _db.accounts.length;

  // Category Breakdown calculated dynamically based on real transactions & budgets
  List<CategoryBreakdownItem> get categoryBreakdown {
    final Map<String, double> categorySums = {};
    final Map<String, int> categoryTxCounts = {};

    for (final tx in _db.transactions) {
      if (!tx.isIncome && tx.type != TransactionType.transfer) {
        final cat = tx.category.isNotEmpty ? tx.category : 'Other';
        categorySums[cat] = (categorySums[cat] ?? 0.0) + tx.amount.abs();
        categoryTxCounts[cat] = (categoryTxCounts[cat] ?? 0) + 1;
      }
    }

    // Also include any active budget categories that have spent > 0
    for (final b in _db.budgets) {
      if (b.spent > 0 && !categorySums.containsKey(b.name)) {
        categorySums[b.name] = b.spent;
        categoryTxCounts[b.name] = _db.transactions
            .where((t) =>
                !t.isIncome &&
                t.type != TransactionType.transfer &&
                (t.category.toLowerCase().contains(b.name.toLowerCase()) ||
                    b.name.toLowerCase().contains(t.category.toLowerCase())))
            .length;
      }
    }

    final total = categorySums.values.fold<double>(0, (a, b) => a + b);
    final List<CategoryBreakdownItem> items = [];

    final colors = [
      AppColors.primary,
      AppColors.secondaryContainer,
      AppColors.secondary,
      AppColors.secondaryFixed,
      AppColors.tertiary,
      AppColors.warningAmber,
    ];

    int colorIdx = 0;
    categorySums.forEach((catName, spent) {
      if (spent > 0) {
        final percentage = total > 0 ? ((spent / total) * 100).round() : 0;
        final color = colors[colorIdx % colors.length];
        colorIdx++;
        final txCount = categoryTxCounts[catName] ?? 0;

        items.add(CategoryBreakdownItem(
          title: catName,
          subtitle: '$txCount ${txCount == 1 ? "transaction" : "transactions"}',
          amount: spent,
          percentage: percentage,
          color: color,
        ));
      }
    });

    items.sort((a, b) => b.amount.compareTo(a.amount));
    return items;
  }

  // Dashboard weekly bars
  List<WeeklyBarData> get dashboardWeeklyBars {
    final txs = transactions;
    if (txs.isEmpty) {
      return const [
        WeeklyBarData(day: 'Mon', amount: 0, percentage: 0.0),
        WeeklyBarData(day: 'Tue', amount: 0, percentage: 0.0),
        WeeklyBarData(day: 'Wed', amount: 0, percentage: 0.0),
        WeeklyBarData(day: 'Thu', amount: 0, percentage: 0.0),
        WeeklyBarData(day: 'Fri', amount: 0, percentage: 0.0),
        WeeklyBarData(day: 'Sat', amount: 0, percentage: 0.0),
        WeeklyBarData(day: 'Sun', amount: 0, percentage: 0.0),
      ];
    }

    final Map<int, double> dayAmounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (final tx in txs) {
      if (!tx.isIncome && tx.type != TransactionType.transfer) {
        final wd = tx.date.weekday;
        dayAmounts[wd] = (dayAmounts[wd] ?? 0) + tx.amount.abs();
      }
    }

    final maxAmt = dayAmounts.values.fold<double>(0, (a, b) => a > b ? a : b);
    const dayNames = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};

    return dayNames.entries.map((entry) {
      final amt = dayAmounts[entry.key] ?? 0;
      final pct = (maxAmt > 0) ? (amt / maxAmt) : 0.0;
      return WeeklyBarData(
        day: entry.value,
        amount: amt,
        percentage: pct.clamp(0.0, 1.0),
        isPeak: amt == maxAmt && amt > 0,
      );
    }).toList();
  }

  // Analytics weekly trends
  List<WeeklyTrendData> get analyticsWeeklyTrends {
    final txs = transactions;
    final expenses = txs.where((t) => !t.isIncome && t.type != TransactionType.transfer).toList();

    final l1 = _analyticsPeriod == 'Quarter' ? 'Jul' : (_analyticsPeriod == 'Year' ? 'Q1' : (_analyticsPeriod == 'Week' ? 'Mon' : 'W1'));
    final l2 = _analyticsPeriod == 'Quarter' ? 'Aug' : (_analyticsPeriod == 'Year' ? 'Q2' : (_analyticsPeriod == 'Week' ? 'Wed' : 'W2'));
    final l3 = _analyticsPeriod == 'Quarter' ? 'Sep' : (_analyticsPeriod == 'Year' ? 'Q3' : (_analyticsPeriod == 'Week' ? 'Fri' : 'W3'));
    final l4 = _analyticsPeriod == 'Quarter' ? 'Oct' : (_analyticsPeriod == 'Year' ? 'Q4' : (_analyticsPeriod == 'Week' ? 'Sun' : 'W4'));

    if (expenses.isEmpty) {
      return [
        WeeklyTrendData(weekLabel: l1, amount: 0, heightPercentage: 0.0),
        WeeklyTrendData(weekLabel: l2, amount: 0, heightPercentage: 0.0),
        WeeklyTrendData(weekLabel: l3, amount: 0, heightPercentage: 0.0),
        WeeklyTrendData(weekLabel: l4, amount: 0, heightPercentage: 0.0, isSafe: true),
      ];
    }

    double b1 = 0, b2 = 0, b3 = 0, b4 = 0;
    for (final e in expenses) {
      final d = e.date.day;
      if (d <= 7) {
        b1 += e.amount.abs();
      } else if (d <= 14) {
        b2 += e.amount.abs();
      } else if (d <= 21) {
        b3 += e.amount.abs();
      } else {
        b4 += e.amount.abs();
      }
    }
    final maxB = [b1, b2, b3, b4].reduce((a, b) => a > b ? a : b);

    return [
      WeeklyTrendData(weekLabel: l1, amount: b1, heightPercentage: maxB > 0 ? (b1 / maxB) : 0.0),
      WeeklyTrendData(weekLabel: l2, amount: b2, heightPercentage: maxB > 0 ? (b2 / maxB) : 0.0, isPeak: b2 == maxB && b2 > 0),
      WeeklyTrendData(weekLabel: l3, amount: b3, heightPercentage: maxB > 0 ? (b3 / maxB) : 0.0),
      WeeklyTrendData(weekLabel: l4, amount: b4, heightPercentage: maxB > 0 ? (b4 / maxB) : 0.0, isSafe: true),
    ];
  }

  // --- Toggles & State Modifiers ---

  void toggleBalanceVisibility() {
    _isBalanceHidden = !_isBalanceHidden;
    notifyListeners();
  }

  void togglePushAlerts() {
    _pushAlertsEnabled = !_pushAlertsEnabled;
    notifyListeners();
  }

  void dismissWarningBanner() {
    _isWarningBannerDismissed = true;
    notifyListeners();
  }

  void setAnalyticsPeriod(String period) {
    _analyticsPeriod = period;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  // --- Actions ---

  Future<void> addTransaction({
    required String title,
    required String category,
    required double amount,
    required TransactionType type,
    String? notes,
    List<String> tags = const [],
    required DateTime date,
  }) async {
    final isIncome = type == TransactionType.income;
    final signedAmount = isIncome ? amount.abs() : -amount.abs();

    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      profileId: currentProfile.id,
      title: title,
      category: category,
      time: 'Just now',
      amount: signedAmount,
      badgeText: isIncome ? 'Verified' : 'Quick Pay',
      badgeColor: isIncome ? AppColors.tertiary : AppColors.onSurfaceVariant,
      icon: _getCategoryIcon(category),
      iconColor: isIncome ? AppColors.tertiary : AppColors.primary,
      iconBgColor: isIncome ? const Color(0x334EDEA3) : const Color(0x3300B4D8),
      type: type,
      notes: notes,
      tags: tags,
      date: date,
    );

    await _db.insertTransaction(newTx);
    _isWarningBannerDismissed = false; // check if new threshold reached
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    notifyListeners();
  }

  Future<void> updateCategoryLimit(String id, double newLimit, double newThreshold) async {
    await _db.updateCategoryLimit(id, newLimit, newThreshold);
    notifyListeners();
  }

  Future<void> addCategoryBudget({
    required String name,
    required double limit,
    double threshold = 80.0,
  }) async {
    await _db.addCategoryBudget(
      profileId: currentProfile.id,
      name: name,
      limit: limit,
      threshold: threshold,
    );
    notifyListeners();
  }

  Future<void> transferBetweenAccounts({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) async {
    await _db.transferBetweenAccounts(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
    );
    notifyListeners();
  }

  String getCsvExport() => _db.exportToCsvString();

  List<Map<String, dynamic>> runMockQuery(String sql) => _db.executeMockSqlQuery(sql);

  Future<void> resetDemoData() async {
    await _db.resetToDefaultDemo();
    _isBalanceHidden = false;
    _isWarningBannerDismissed = false;
    notifyListeners();
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') || lower.contains('dining') || lower.contains('restaurant')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('shop')) return Icons.shopping_bag_outlined;
    if (lower.contains('grocer')) return Icons.local_grocery_store_rounded;
    if (lower.contains('transport') || lower.contains('transit') || lower.contains('metro')) {
      return Icons.commute_rounded;
    }
    if (lower.contains('bill') || lower.contains('house') || lower.contains('rent') || lower.contains('utilit')) {
      return Icons.roofing_rounded;
    }
    if (lower.contains('entertain') || lower.contains('game')) return Icons.sports_esports_rounded;
    if (lower.contains('tech') || lower.contains('subscription')) return Icons.terminal_rounded;
    if (lower.contains('health') || lower.contains('medic')) return Icons.favorite_rounded;
    if (lower.contains('salary') || lower.contains('paycheck')) return Icons.payments_rounded;
    if (lower.contains('freelance') || lower.contains('work')) return Icons.laptop_mac_rounded;
    if (lower.contains('invest')) return Icons.trending_up_rounded;
    if (lower.contains('business')) return Icons.storefront_rounded;
    if (lower.contains('gift')) return Icons.card_giftcard_rounded;
    if (lower.contains('bonus') || lower.contains('cashback')) return Icons.monetization_on_rounded;
    if (lower.contains('bank')) return Icons.account_balance_rounded;
    if (lower.contains('saving') || lower.contains('vault')) return Icons.savings_rounded;
    if (lower.contains('card')) return Icons.credit_card_rounded;
    if (lower.contains('wallet')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('atm') || lower.contains('cash')) return Icons.local_atm_rounded;
    if (lower.contains('friend') || lower.contains('fam')) return Icons.people_alt_rounded;
    if (lower.contains('loan')) return Icons.handshake_rounded;
    if (lower.contains('transfer')) return Icons.sync_alt_rounded;
    if (lower.contains('income')) return Icons.attach_money_rounded;
    return Icons.account_balance_wallet_rounded;
  }
}
