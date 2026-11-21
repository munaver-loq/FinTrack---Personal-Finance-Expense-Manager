import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/transaction_model.dart';
import '../state/finance_state.dart';

class AddTransactionScreen extends StatefulWidget {
  final FinanceState state;
  final String? initialTitle;
  final String? initialCategory;
  final double? initialAmount;
  final String? initialNotes;
  final TransactionType? initialType;

  const AddTransactionScreen({
    super.key,
    required this.state,
    this.initialTitle,
    this.initialCategory,
    this.initialAmount,
    this.initialNotes,
    this.initialType,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TransactionType _selectedType;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late String _selectedPaymentMethod;

  static const List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food & Dining', 'icon': Icons.restaurant_rounded},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Groceries', 'icon': Icons.local_grocery_store_rounded},
    {'name': 'Transport', 'icon': Icons.directions_subway_rounded},
    {'name': 'Bills & Utilities', 'icon': Icons.receipt_long_rounded},
    {'name': 'Entertainment', 'icon': Icons.sports_esports_rounded},
    {'name': 'Health & Medical', 'icon': Icons.favorite_rounded},
    {'name': 'Housing & Rent', 'icon': Icons.home_rounded},
    {'name': 'Education', 'icon': Icons.school_rounded},
    {'name': 'Personal Care', 'icon': Icons.spa_rounded},
    {'name': 'Travel', 'icon': Icons.flight_takeoff_rounded},
    {'name': 'Other Expense', 'icon': Icons.more_horiz_rounded},
  ];

  static const List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': Icons.payments_rounded},
    {'name': 'Freelance', 'icon': Icons.laptop_mac_rounded},
    {'name': 'Investments', 'icon': Icons.trending_up_rounded},
    {'name': 'Business', 'icon': Icons.storefront_rounded},
    {'name': 'Rental Income', 'icon': Icons.real_estate_agent_rounded},
    {'name': 'Gift / Grant', 'icon': Icons.card_giftcard_rounded},
    {'name': 'Bonus / Cashback', 'icon': Icons.monetization_on_rounded},
    {'name': 'Interest Income', 'icon': Icons.account_balance_rounded},
    {'name': 'Other Income', 'icon': Icons.attach_money_rounded},
  ];

  static const List<Map<String, dynamic>> _transferCategories = [
    {'name': 'Bank Transfer', 'icon': Icons.account_balance_rounded},
    {'name': 'Savings Vault', 'icon': Icons.savings_rounded},
    {'name': 'Credit Card Pay', 'icon': Icons.credit_card_rounded},
    {'name': 'Digital Wallet', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'Investment Transfer', 'icon': Icons.swap_horiz_rounded},
    {'name': 'Family & Friends', 'icon': Icons.people_alt_rounded},
    {'name': 'Cash Withdrawal', 'icon': Icons.local_atm_rounded},
    {'name': 'Loan Payment', 'icon': Icons.handshake_rounded},
    {'name': 'Other Transfer', 'icon': Icons.sync_alt_rounded},
  ];

  List<Map<String, dynamic>> get _currentCategories {
    switch (_selectedType) {
      case TransactionType.income:
        return _incomeCategories;
      case TransactionType.transfer:
        return _transferCategories;
      case TransactionType.expense:
        return _expenseCategories;
    }
  }

  late TextEditingController _notesController;
  final List<String> _tags = ['#client', '#quarterly-dinner'];

  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController = TextEditingController(text: widget.initialAmount!.toStringAsFixed(2));
    } else {
      _amountController = TextEditingController(text: '0.00');
    }
    _selectedCategory = widget.initialCategory ?? (_currentCategories.isNotEmpty ? _currentCategories.first['name'] as String : 'General');
    _selectedPaymentMethod = 'Offline Cash / Primary Bank';
    _notesController = TextEditingController(
      text: widget.initialNotes ?? widget.initialTitle ?? 'Dinner with team',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addQuickAmount(double amount) {
    HapticFeedback.lightImpact();
    double current = double.tryParse(_amountController.text) ?? 0.0;
    current += amount;
    _amountController.text = current.toStringAsFixed(2);
    setState(() {});
  }

  void _handleSave() async {
    if (_isSaving || _isSaved) return;

    final amountVal = double.tryParse(_amountController.text) ?? 0.0;
    if (amountVal <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.errorContainer,
          content: Text(
            'Please enter a valid amount greater than 0',
            style: TextStyle(color: AppColors.onErrorContainer),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulate SQLite encrypted write
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isSaved = true;
    });

    widget.state.addTransaction(
      title: _notesController.text.isNotEmpty
          ? _notesController.text
          : '$_selectedCategory Payment',
      category: _selectedCategory,
      amount: amountVal,
      type: _selectedType,
      notes: _notesController.text,
      tags: List.from(_tags),
      date: DateTime.now(),
    );

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = widget.state.currencySymbol;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.90),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 12,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondaryContainer],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.auto_graph_rounded,
                          color: AppColors.surfaceContainerLowest,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Transaction',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.onPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Action Bar (Cancel, SQLite Local, Save)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surfaceContainerLow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.surfaceContainer,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'SQLITE (${widget.state.currencyCode})',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.tertiary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _handleSave,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x664CD6FB),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Save',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.check_rounded, color: AppColors.onPrimary, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Controller (Expense, Income, Transfer)
                    _buildSegmentedController(),
                    const SizedBox(height: 16),

                    // Amount Hero with Native Text Entry & Quick Increment Zone
                    _buildAmountHeroCard(currencySymbol),
                    const SizedBox(height: 16),

                    // Category Selector Strip
                    _buildCategorySelector(),
                    const SizedBox(height: 16),

                    // Metadata Card Form Fields
                    _buildMetadataCard(),
                    const SizedBox(height: 24),

                    // Floating Bottom Confirmation Action
                    _buildConfirmSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedController() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          _buildTypeButton(TransactionType.expense, 'Expense'),
          _buildTypeButton(TransactionType.income, 'Income'),
          _buildTypeButton(TransactionType.transfer, 'Transfer'),
        ],
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedType = type;
            final available = _currentCategories;
            if (!available.any((c) => c['name'] == _selectedCategory)) {
              _selectedCategory = available.isNotEmpty ? available.first['name'] as String : 'General';
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x5500B4D8),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelLarge.copyWith(
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountHeroCard(String currencySymbol) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          Text(
            'Enter Transaction Amount',
            style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),

          // Native Numeric Input Field (No custom keypad!)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                currencySymbol,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              const SizedBox(width: 6),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 40,
                    letterSpacing: -0.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () {
                    if (_amountController.text == '0.00') {
                      _amountController.text = '';
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick increment pills (horizontally scrollable, never overflow)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickPill('+$currencySymbol 10', 10),
                const SizedBox(width: 8),
                _buildQuickPill('+$currencySymbol 50', 50),
                const SizedBox(width: 8),
                _buildQuickPill('+$currencySymbol 100', 100),
                const SizedBox(width: 8),
                _buildQuickPill('Max ($currencySymbol 250)', 250, isMax: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPill(String label, double val, {bool isMax = false}) {
    return InkWell(
      onTap: () => _addQuickAmount(val),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isMax ? AppColors.tertiary : AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categoryHeader = _selectedType == TransactionType.income
        ? 'Income Category'
        : (_selectedType == TransactionType.transfer ? 'Transfer Category' : 'Expense Category');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryHeader,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              '${_currentCategories.length} Options',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _currentCategories.map((cat) {
              final isSelected = _selectedCategory == cat['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedCategory = cat['name'] as String;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderStroke,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x664CD6FB),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['name'] as String,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          // Payment Method
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
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
                        'Payment Method',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        _selectedPaymentMethod,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Safe Sync',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 18),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Timestamp
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timestamp',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        'Today, Oct 24 • 07:45 PM',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.schedule_rounded, color: AppColors.onSurfaceVariant, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Notes & Tags
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _notesController,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Add optional memo...',
                          hintStyle: TextStyle(color: AppColors.outline),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ..._tags.map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _tags.remove(tag);
                                  });
                                },
                                child: const Icon(Icons.close_rounded, size: 12, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showAddTagDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, size: 12, color: AppColors.onSurfaceVariant),
                              SizedBox(width: 2),
                              Text('Tag', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                            ],
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
    );
  }

  void _showAddTagDialog() {
    final tagCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Add Tag', style: TextStyle(color: AppColors.onSurface)),
        content: TextField(
          controller: tagCtrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: const InputDecoration(
            hintText: 'e.g. coffee, project',
            hintStyle: TextStyle(color: AppColors.outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tagCtrl.text.isNotEmpty) {
                final newTag = tagCtrl.text.startsWith('#') ? tagCtrl.text : '#${tagCtrl.text}';
                setState(() {
                  _tags.add(newTag);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmSaveButton() {
    Color bg = AppColors.primary;
    Color fg = AppColors.onPrimary;
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Save Transaction',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: fg,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (_isSaving) {
      content = const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Syncing with SQLite...',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary),
          ),
        ],
      );
    } else if (_isSaved) {
      bg = AppColors.tertiaryContainer;
      fg = AppColors.onTertiaryContainer;
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.done_all_rounded, size: 22),
          const SizedBox(width: 8),
          Text(
            'Saved Locally!',
            style: TextStyle(fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 4,
          shadowColor: const Color(0x664CD6FB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _handleSave,
        child: content,
      ),
    );
  }
}
