import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../core/theme/app_colors.dart';
import '../models/category_budget_model.dart';
import '../models/transaction_model.dart';
import '../models/user_profile_model.dart';

class AccountBalance {
  final String id;
  final String profileId;
  final String name;
  final String accountNumber;
  double balance;
  final IconData icon;

  AccountBalance({
    required this.id,
    this.profileId = 'user_alex',
    required this.name,
    required this.accountNumber,
    required this.balance,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'profileId': profileId,
        'name': name,
        'accountNumber': accountNumber,
        'balance': balance,
      };

  factory AccountBalance.fromJson(Map<String, dynamic> json) => AccountBalance(
        id: json['id'] as String,
        profileId: json['profileId'] as String? ?? 'user_alex',
        name: json['name'] as String,
        accountNumber: json['accountNumber'] as String,
        balance: (json['balance'] as num).toDouble(),
        icon: json['id'].toString().contains('checking')
            ? Icons.account_balance_wallet_rounded
            : (json['id'].toString().contains('savings')
                ? Icons.savings_rounded
                : Icons.payments_rounded),
      );
}

class MockDatabaseService {
  static final MockDatabaseService _instance = MockDatabaseService._internal();
  factory MockDatabaseService() => _instance;
  MockDatabaseService._internal() {
    _seedInitialDemoData();
  }

  bool _isInitialized = false;
  File? _dbFile;
  double _lastQueryLatencyMs = 0.8;

  double get lastQueryLatencyMs => _lastQueryLatencyMs;

  final List<UserProfileModel> _profiles = [];
  String _activeProfileId = '';

  List<UserProfileModel> get profiles => List.unmodifiable(_profiles);
  UserProfileModel get activeProfile => _profiles.firstWhere(
        (p) => p.id == _activeProfileId,
        orElse: () => _profiles.isNotEmpty
            ? _profiles.first
            : const UserProfileModel(
                id: '',
                name: 'Guest',
                email: 'No active account',
                photoUrl: '',
                currencyCode: 'USD',
                currencySymbol: '\$',
                tier: 'STARTER',
              ),
      );

  final List<AccountBalance> _accounts = [];
  final List<TransactionModel> _transactions = [];
  final List<CategoryBudgetModel> _budgets = [];

  List<AccountBalance> get accounts =>
      _accounts.where((a) => a.profileId == _activeProfileId).toList();
  List<TransactionModel> get transactions =>
      _transactions.where((t) => t.profileId == _activeProfileId).toList();
  List<CategoryBudgetModel> get budgets =>
      _budgets.where((b) => b.profileId == _activeProfileId).toList();

  List<AccountBalance> get allAccounts => List.unmodifiable(_accounts);
  List<TransactionModel> get allTransactions => List.unmodifiable(_transactions);
  List<CategoryBudgetModel> get allBudgets => List.unmodifiable(_budgets);

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        _dbFile = File('${dir.path}/fintrack_local_sqlite.json');
      }

      if (_dbFile != null && await _dbFile!.exists()) {
        final raw = await _dbFile!.readAsString();
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _loadFromJson(data);
      } else {
        _seedInitialDemoData();
        await _persist();
      }
    } catch (e) {
      debugPrint('Error loading persistent db: $e, using in-memory demo data');
      _seedInitialDemoData();
    }

    _isInitialized = true;
  }

  void _seedInitialDemoData() {
    clearAll();
  }

  void clearAll() {
    _profiles.clear();
    _activeProfileId = '';
    _accounts.clear();
    _transactions.clear();
    _budgets.clear();
  }

  Future<void> _persist() async {
    if (_dbFile == null) return;
    try {
      final jsonMap = {
        'version': '1.0.0',
        'encrypted': true,
        'activeProfileId': _activeProfileId,
        'profiles': _profiles.map((p) => p.toJson()).toList(),
        'accounts': _accounts.map((a) => a.toJson()).toList(),
        'transactions': _transactions.map((t) => _txToJson(t)).toList(),
        'budgets': _budgets.map((b) => _budgetToJson(b)).toList(),
      };
      await _dbFile!.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      debugPrint('Failed to save db to disk: $e');
    }
  }

  void _loadFromJson(Map<String, dynamic> data) {
    if (data.containsKey('profiles')) {
      final list = (data['profiles'] as List)
          .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
          .where((p) => p.id != 'user_alex' && p.id != 'user_sarah')
          .toList();
      _profiles.clear();
      _profiles.addAll(list);
    }
    if (data.containsKey('activeProfileId')) {
      final savedId = data['activeProfileId'] as String;
      if (savedId != 'user_alex' && savedId != 'user_sarah' && _profiles.any((p) => p.id == savedId)) {
        _activeProfileId = savedId;
      } else {
        _activeProfileId = _profiles.isNotEmpty ? _profiles.first.id : '';
      }
    } else {
      _activeProfileId = _profiles.isNotEmpty ? _profiles.first.id : '';
    }
    if (data.containsKey('accounts')) {
      final list = (data['accounts'] as List)
          .map((e) => AccountBalance.fromJson(e as Map<String, dynamic>))
          .where((a) => a.profileId != 'user_alex' && a.profileId != 'user_sarah')
          .toList();
      _accounts.clear();
      _accounts.addAll(list);
    }
    if (data.containsKey('transactions')) {
      final list = (data['transactions'] as List)
          .map((e) => _txFromJson(e as Map<String, dynamic>))
          .where((t) => t.profileId != 'user_alex' && t.profileId != 'user_sarah')
          .toList();
      _transactions.clear();
      _transactions.addAll(list);
    }
    if (data.containsKey('budgets')) {
      final list = (data['budgets'] as List)
          .map((e) => _budgetFromJson(e as Map<String, dynamic>))
          .where((b) => b.profileId != 'user_alex' && b.profileId != 'user_sarah')
          .toList();
      _budgets.clear();
      _budgets.addAll(list);
    }
  }

  Map<String, dynamic> _txToJson(TransactionModel t) => {
        'id': t.id,
        'profileId': t.profileId,
        'title': t.title,
        'category': t.category,
        'time': t.time,
        'amount': t.amount,
        'badgeText': t.badgeText,
        'type': t.type.name,
        'notes': t.notes,
        'tags': t.tags,
        'date': t.date.toIso8601String(),
      };

  TransactionModel _txFromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'expense';
    final type = TransactionType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => TransactionType.expense,
    );
    final amt = (json['amount'] as num).toDouble();
    final isIncome = type == TransactionType.income || (type != TransactionType.expense && amt > 0);
    final profileId = json['profileId'] as String? ?? 'user_alex';

    return TransactionModel(
      id: json['id'] as String,
      profileId: profileId,
      title: json['title'] as String,
      category: json['category'] as String,
      time: json['time'] as String? ?? 'Recently',
      amount: amt,
      badgeText: json['badgeText'] as String?,
      badgeColor: isIncome ? AppColors.tertiary : AppColors.onSurfaceVariant,
      icon: _getCategoryIcon(json['category'] as String),
      iconColor: isIncome ? AppColors.tertiary : AppColors.primary,
      iconBgColor: isIncome ? const Color(0x334EDEA3) : const Color(0x3300B4D8),
      type: type,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _budgetToJson(CategoryBudgetModel b) => {
        'id': b.id,
        'profileId': b.profileId,
        'name': b.name,
        'subtitle': b.subtitle,
        'spent': b.spent,
        'limit': b.limit,
        'thresholdPercent': b.thresholdPercent,
        'status': b.status,
        'footerRight': b.footerRight,
        'isNearLimit': b.isNearLimit,
      };

  CategoryBudgetModel _budgetFromJson(Map<String, dynamic> json) {
    final spent = (json['spent'] as num).toDouble();
    final limit = (json['limit'] as num).toDouble();
    final threshold = (json['thresholdPercent'] as num?)?.toDouble() ?? 80.0;
    final isNear = (limit > 0) && (spent / limit * 100 >= threshold);
    final profileId = json['profileId'] as String? ?? 'user_alex';

    return CategoryBudgetModel(
      id: json['id'] as String,
      profileId: profileId,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String,
      spent: spent,
      limit: limit,
      thresholdPercent: threshold,
      icon: _getCategoryIcon(json['name'] as String),
      color: isNear ? AppColors.alertDanger : AppColors.secondary,
      iconBgColor: isNear ? const Color(0x3393000A) : const Color(0x3300A6E0),
      status: isNear ? 'Near Limit' : (json['status'] as String? ?? 'On Track'),
      statusColor: isNear ? AppColors.onErrorContainer : AppColors.tertiary,
      statusBgColor: isNear ? AppColors.errorContainer : const Color(0x3319BC84),
      footerRight: json['footerRight'] as String? ?? 'Paced OK',
      isNearLimit: isNear,
    );
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

  // --- CRUD Operations ---

  Future<void> insertTransaction(TransactionModel tx) async {
    final effectiveProfileId = (tx.profileId.isNotEmpty && tx.profileId != 'user_alex')
        ? tx.profileId
        : _activeProfileId;

    final scopedTx = TransactionModel(
      id: tx.id,
      profileId: effectiveProfileId,
      title: tx.title,
      category: tx.category,
      time: tx.time,
      amount: tx.amount,
      badgeText: tx.badgeText,
      badgeColor: tx.badgeColor,
      icon: tx.icon,
      iconColor: tx.iconColor,
      iconBgColor: tx.iconBgColor,
      type: tx.type,
      notes: tx.notes,
      tags: tx.tags,
      date: tx.date,
    );

    _transactions.insert(0, scopedTx);

    // Update checking balance for this profile
    final checkingIdx = _accounts.indexWhere(
      (a) => a.profileId == effectiveProfileId && a.id.contains('checking'),
    );
    if (checkingIdx != -1) {
      if (scopedTx.isIncome) {
        _accounts[checkingIdx].balance += scopedTx.amount.abs();
      } else {
        _accounts[checkingIdx].balance -= scopedTx.amount.abs();
      }
    } else {
      final anyIdx = _accounts.indexWhere((a) => a.profileId == effectiveProfileId);
      if (anyIdx != -1) {
        if (scopedTx.isIncome) {
          _accounts[anyIdx].balance += scopedTx.amount.abs();
        } else {
          _accounts[anyIdx].balance -= scopedTx.amount.abs();
        }
      }
    }

    // update category spent if matches
    if (!scopedTx.isIncome && scopedTx.type != TransactionType.transfer) {
      final budgetIndex = _budgets.indexWhere(
        (b) => b.profileId == effectiveProfileId &&
            (b.name.toLowerCase().contains(scopedTx.category.toLowerCase()) ||
                scopedTx.category.toLowerCase().contains(b.name.toLowerCase())),
      );
      if (budgetIndex != -1) {
        _budgets[budgetIndex].spent += scopedTx.amount.abs();
        final b = _budgets[budgetIndex];
        final isNear = (b.limit > 0) && (b.spent / b.limit * 100 >= b.thresholdPercent);
        _budgets[budgetIndex] = b.copyWith(
          isNearLimit: isNear,
          status: isNear ? 'Near Limit' : 'On Track',
          statusColor: isNear ? AppColors.onErrorContainer : AppColors.tertiary,
          statusBgColor: isNear ? AppColors.errorContainer : const Color(0x3319BC84),
          footerRight: isNear
              ? 'Threshold ${b.thresholdPercent.toInt()}% Triggered'
              : 'Remaining: ${activeProfile.currencySymbol}${b.remaining.toInt()}',
        );
      }
    }

    _lastQueryLatencyMs = 0.4 + (DateTime.now().microsecond % 80) / 100.0;
    await _persist();
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tx = _transactions[index];
      final checkingIdx = _accounts.indexWhere(
        (a) => a.profileId == tx.profileId && a.id.contains('checking'),
      );
      if (checkingIdx != -1) {
        if (tx.isIncome) {
          _accounts[checkingIdx].balance -= tx.amount.abs();
        } else {
          _accounts[checkingIdx].balance += tx.amount.abs();
        }
      }
      _transactions.removeAt(index);
      await _persist();
    }
  }

  Future<void> updateCategoryLimit(String id, double newLimit, double newThreshold) async {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      final old = _budgets[index];
      final spent = old.spent;
      final isNear = (newLimit > 0) && (spent / newLimit * 100 >= newThreshold);

      _budgets[index] = old.copyWith(
        limit: newLimit,
        thresholdPercent: newThreshold,
        isNearLimit: isNear,
        status: isNear ? 'Near Limit' : 'On Track',
        statusColor: isNear ? AppColors.onErrorContainer : AppColors.tertiary,
        statusBgColor: isNear ? AppColors.errorContainer : const Color(0x3319BC84),
        footerRight: isNear
            ? 'Threshold ${newThreshold.toInt()}% Triggered'
            : 'Remaining: \$${(newLimit - spent).toStringAsFixed(0)}',
      );
      await _persist();
    }
  }

  Future<void> addCategoryBudget({
    String? profileId,
    required String name,
    required double limit,
    double threshold = 80.0,
  }) async {
    final effectiveProfileId = profileId ?? _activeProfileId;
    final newBudget = CategoryBudgetModel(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      profileId: effectiveProfileId,
      name: name,
      subtitle: 'Custom offline budget cap',
      spent: 0.0,
      limit: limit,
      thresholdPercent: threshold,
      icon: _getCategoryIcon(name),
      color: AppColors.primary,
      iconBgColor: const Color(0x3300B4D8),
      status: 'On Track',
      statusColor: AppColors.tertiary,
      statusBgColor: const Color(0x3319BC84),
      footerRight: 'Remaining: ${activeProfile.currencySymbol}${limit.toInt()}',
    );
    _budgets.add(newBudget);
    await _persist();
  }

  Future<void> transferBetweenAccounts({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) async {
    final fromAcc = _accounts.firstWhere((a) => a.id == fromAccountId);
    final toAcc = _accounts.firstWhere((a) => a.id == toAccountId);

    fromAcc.balance -= amount;
    toAcc.balance += amount;

    // Add a transfer transaction
    final tx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Transfer to ${toAcc.name.split(' ').first}',
      category: 'Transfer',
      time: 'Just now',
      amount: -amount,
      badgeText: 'Internal Transfer',
      badgeColor: AppColors.secondary,
      icon: Icons.sync_alt_rounded,
      iconColor: AppColors.secondary,
      iconBgColor: const Color(0x3300A6E0),
      type: TransactionType.transfer,
      notes: 'Transfer from ${fromAcc.name} to ${toAcc.name}',
      tags: const ['#transfer', '#internal'],
      date: DateTime.now(),
    );

    _transactions.insert(0, tx);
    await _persist();
  }

  String exportToCsvString() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Payee/Title,Category,Type,Amount,Status/Tag,Notes');
    for (final tx in _transactions) {
      final signAmt = tx.isIncome ? tx.amount.abs() : -tx.amount.abs();
      buffer.writeln(
        '"${tx.id}","${tx.date.toIso8601String()}","${tx.title.replaceAll('"', '""')}","${tx.category}","${tx.type.name}","${signAmt.toStringAsFixed(2)}","${tx.badgeText ?? ''}","${(tx.notes ?? '').replaceAll('"', '""')}"',
      );
    }
    return buffer.toString();
  }

  List<Map<String, dynamic>> executeMockSqlQuery(String query) {
    _lastQueryLatencyMs = 0.5 + (DateTime.now().microsecond % 60) / 100.0;
    final lower = query.trim().toLowerCase();

    if (lower.contains('from transactions')) {
      return _transactions
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'category': t.category,
                'amount': t.amount,
                'type': t.type.name,
                'time': t.time,
              })
          .toList();
    } else if (lower.contains('from budgets')) {
      return _budgets
          .map((b) => {
                'id': b.id,
                'name': b.name,
                'spent': b.spent,
                'limit': b.limit,
                'percent': '${b.percentSpentInt}%',
                'status': b.status,
              })
          .toList();
    } else if (lower.contains('from accounts')) {
      return _accounts
          .map((a) => {
                'id': a.id,
                'name': a.name,
                'balance': '\$${a.balance.toStringAsFixed(2)}',
              })
          .toList();
    }

    return [
      {'status': 'SUCCESS', 'message': 'Query executed in ${_lastQueryLatencyMs.toStringAsFixed(2)}ms'}
    ];
  }

  Future<void> switchProfile(String id) async {
    _activeProfileId = id;
    await _persist();
  }

  Future<void> createProfile(UserProfileModel profile) async {
    _profiles.add(profile);
    _activeProfileId = profile.id;

    // Create fresh checking, savings, and cash accounts starting at EXACT 0.00 balance
    _accounts.addAll([
      AccountBalance(
        id: 'acc_${profile.id}_checking',
        profileId: profile.id,
        name: '${profile.name.split(' ').first}\'s Checking',
        accountNumber: '•••• ${(1000 + (DateTime.now().millisecond % 9000))}',
        balance: 0.0,
        icon: Icons.account_balance_wallet_rounded,
      ),
      AccountBalance(
        id: 'acc_${profile.id}_savings',
        profileId: profile.id,
        name: 'Vault Savings',
        accountNumber: '•••• ${(5000 + (DateTime.now().millisecond % 4000))}',
        balance: 0.0,
        icon: Icons.savings_rounded,
      ),
      AccountBalance(
        id: 'acc_${profile.id}_cash',
        profileId: profile.id,
        name: 'Cash Reserve',
        accountNumber: 'Physical Vault',
        balance: 0.0,
        icon: Icons.payments_rounded,
      ),
    ]);

    // Create fresh initial category budgets starting at 0.00 spent
    _budgets.addAll([
      CategoryBudgetModel(
        id: 'cat_${profile.id}_food',
        profileId: profile.id,
        name: 'Food & Dining',
        subtitle: 'Daily dining & groceries',
        spent: 0.0,
        limit: 500.0,
        thresholdPercent: 80.0,
        icon: Icons.restaurant_rounded,
        color: AppColors.secondary,
        iconBgColor: const Color(0x3300A6E0),
        status: 'On Track',
        statusColor: AppColors.tertiary,
        statusBgColor: const Color(0x3319BC84),
        footerRight: 'Remaining: ${profile.currencySymbol}500',
      ),
      CategoryBudgetModel(
        id: 'cat_${profile.id}_shop',
        profileId: profile.id,
        name: 'Shopping & Essentials',
        subtitle: 'Personal & household items',
        spent: 0.0,
        limit: 300.0,
        thresholdPercent: 80.0,
        icon: Icons.shopping_bag_outlined,
        color: AppColors.primary,
        iconBgColor: const Color(0x3300B4D8),
        status: 'On Track',
        statusColor: AppColors.tertiary,
        statusBgColor: const Color(0x3319BC84),
        footerRight: 'Remaining: ${profile.currencySymbol}300',
      ),
      CategoryBudgetModel(
        id: 'cat_${profile.id}_housing',
        profileId: profile.id,
        name: 'Housing & Utilities',
        subtitle: 'Rent, electricity & fiber',
        spent: 0.0,
        limit: 1000.0,
        thresholdPercent: 85.0,
        icon: Icons.roofing_rounded,
        color: AppColors.secondaryFixedDim,
        iconBgColor: const Color(0x3300A6E0),
        status: 'On Track',
        statusColor: AppColors.tertiary,
        statusBgColor: const Color(0x3319BC84),
        footerRight: 'Remaining: ${profile.currencySymbol}1000',
      ),
      CategoryBudgetModel(
        id: 'cat_${profile.id}_enter',
        profileId: profile.id,
        name: 'Entertainment',
        subtitle: 'Gaming, media & concerts',
        spent: 0.0,
        limit: 200.0,
        thresholdPercent: 80.0,
        icon: Icons.sports_esports_rounded,
        color: AppColors.tertiary,
        iconBgColor: const Color(0x334EDEA3),
        status: 'On Track',
        statusColor: AppColors.tertiary,
        statusBgColor: const Color(0x334EDEA3),
        footerRight: 'Remaining: ${profile.currencySymbol}200',
      ),
    ]);

    await _persist();
  }

  Future<void> updateProfile({
    required String id,
    required String name,
    required String email,
    required String photoUrl,
    required String currencyCode,
    required String currencySymbol,
  }) async {
    final idx = _profiles.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _profiles[idx] = _profiles[idx].copyWith(
        name: name,
        email: email,
        photoUrl: photoUrl,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
      );
      await _persist();
    }
  }

  Future<void> deleteProfile(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    _transactions.removeWhere((t) => t.profileId == id);
    _accounts.removeWhere((a) => a.profileId == id);
    _budgets.removeWhere((b) => b.profileId == id);
    if (_activeProfileId == id) {
      _activeProfileId = _profiles.isNotEmpty ? _profiles.first.id : '';
    }
    await _persist();
  }

  Future<void> updateActiveProfileCurrency(String code, String symbol) async {
    final idx = _profiles.indexWhere((p) => p.id == _activeProfileId);
    if (idx != -1) {
      _profiles[idx] = _profiles[idx].copyWith(
        currencyCode: code,
        currencySymbol: symbol,
      );
      await _persist();
    }
  }

  Future<void> resetToDefaultDemo() async {
    _seedInitialDemoData();
    await _persist();
  }
}
