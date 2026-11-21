import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/transaction_model.dart';
import '../state/finance_state.dart';
import '../widgets/create_account_sheet.dart';
import '../widgets/fintrack_app_bar.dart';
import '../widgets/fintrack_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'budgets_screen.dart';
import 'settings_screen.dart';
import 'add_transaction_screen.dart';

class MainShell extends StatefulWidget {
  final FinanceState? state;

  const MainShell({super.key, this.state});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final FinanceState _state;
  late final bool _isStateOwned;

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      _state = widget.state!;
      _isStateOwned = false;
    } else {
      _state = FinanceState();
      _isStateOwned = true;
    }
  }

  @override
  void dispose() {
    if (_isStateOwned) {
      _state.dispose();
    }
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAddTransaction({
    String? title,
    String? category,
    double? amount,
    String? notes,
    TransactionType? type,
  }) {
    if (!_state.hasAccount) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => CreateAccountSheet(state: _state),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.surfaceContainerHigh,
          content: Text(
            'Please create an account first to start tracking transactions.',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionScreen(
          state: _state,
          initialTitle: title,
          initialCategory: category,
          initialAmount: amount,
          initialNotes: notes,
          initialType: type,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  String get _currentSubtitle {
    switch (_currentIndex) {
      case 0:
        return 'Overview';
      case 1:
        return 'Analytics';
      case 2:
        return 'Budgets';
      case 3:
        return 'Settings';
      default:
        return 'Overview';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: FinTrackAppBar(subtitle: _currentSubtitle, state: _state),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              DashboardScreen(
                state: _state,
                onNavigateToBudgets: () => _onTabSelected(2),
                onAddTransaction: () => _openAddTransaction(),
                onAddTransactionPrefilled: ({
                  required String title,
                  required String category,
                  required double amount,
                  required String notes,
                }) {
                  _openAddTransaction(
                    title: title,
                    category: category,
                    amount: amount,
                    notes: notes,
                  );
                },
              ),
              AnalyticsScreen(state: _state),
              BudgetsScreen(state: _state),
              SettingsScreen(state: _state),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FinTrackBottomNav(
              currentIndex: _currentIndex,
              onTabSelected: _onTabSelected,
              onAddPressed: _openAddTransaction,
            ),
          ),
        ],
      ),
    );
  }
}
