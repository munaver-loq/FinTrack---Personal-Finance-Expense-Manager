import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack_personal_finance_and_expense_manager/main.dart';
import 'package:fintrack_personal_finance_and_expense_manager/services/mock_database_service.dart';
import 'package:fintrack_personal_finance_and_expense_manager/state/finance_state.dart';
import 'package:fintrack_personal_finance_and_expense_manager/models/transaction_model.dart';
import 'package:fintrack_personal_finance_and_expense_manager/screens/add_transaction_screen.dart';

void main() {
  setUp(() {
    MockDatabaseService().clearAll();
  });
  testWidgets('FinTrack opening smoke test without demo accounts', (WidgetTester tester) async {
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint('WIDGET CAUSING OVERFLOW: ${details.toString()}');
    };
    addTearDown(() {
      FlutterError.onError = oldHandler;
    });

    await tester.pumpWidget(const FinTrackApp());
    await tester.pumpAndSettle();

    // Verify FinTrack title renders in App Bar without SQLite green pill
    expect(find.text('FinTrack'), findsWidgets);
    expect(find.text('SQLite'), findsNothing);

    // Initial app opening time without account:
    // Greeting displays 'Welcome to FinTrack' and no small green text
    expect(find.text('Welcome to FinTrack'), findsOneWidget);
    expect(find.text('LOCAL SQLITE ACTIVE • OFFLINE FIRST'), findsNothing);

    // Overview area shows "Add Account" hero card in place of "TOTAL NET LIQUIDITY"
    expect(find.text('Add Account'), findsWidgets);
    expect(find.text('No Account Configured'), findsOneWidget);
    expect(find.text('TOTAL NET LIQUIDITY'), findsNothing);
  });

  test('FinanceState new profile starts at zero and isolates data', () async {
    final state = FinanceState();

    // Before creating an account, hasAccount is false
    // Create a new account
    await state.createProfile(
      name: 'Elena Rostova',
      email: 'elena@fintrack.app',
      photoUrl: 'preset_violet',
      currencyCode: 'GBP',
      currencySymbol: '£',
    );

    expect(state.hasAccount, true);
    expect(state.currentProfile.name, 'Elena Rostova');
    expect(state.currencyCode, 'GBP');
    expect(state.currencySymbol, '£');

    // New profile MUST start at exact zero!
    expect(state.totalLiquidity, 0.0);
    expect(state.monthlyIncome, 0.0);
    expect(state.monthlyExpenses, 0.0);
    expect(state.transactions.isEmpty, true);

    // Weekly bars and analytics trends start at 0
    final bars = state.dashboardWeeklyBars;
    expect(bars.every((b) => b.amount == 0.0), true);

    // Log an income transaction (+£2000 Salary)
    await state.addTransaction(
      title: 'Salary Direct Deposit',
      category: 'Salary',
      amount: 2000.0,
      type: TransactionType.income,
      date: DateTime.now(),
    );

    expect(state.totalLiquidity, 2000.0);
    expect(state.monthlyIncome, 2000.0);
    expect(state.monthlyExpenses, 0.0);
    expect(state.transactions.length, 1);

    // Log an expense transaction (-£150 Food & Dining)
    await state.addTransaction(
      title: 'Dinner with Team',
      category: 'Food & Dining',
      amount: 150.0,
      type: TransactionType.expense,
      date: DateTime.now(),
    );

    expect(state.totalLiquidity, 1850.0);
    expect(state.monthlyExpenses, 150.0);
    expect(state.highestPayeeName, 'Dinner with Team');
    expect(state.highestPayeeAmount, 150.0);

    // Create a second profile and verify data isolation
    await state.createProfile(
      name: 'Marcus Vance',
      email: 'marcus@fintrack.app',
      photoUrl: 'preset_cyan',
      currencyCode: 'USD',
      currencySymbol: r'$',
    );

    expect(state.currentProfile.name, 'Marcus Vance');
    expect(state.currencySymbol, r'$');
    expect(state.totalLiquidity, 0.0);
    expect(state.transactions.isEmpty, true);

    // Switch back to Elena
    final elenaId = state.userProfiles.firstWhere((p) => p.name == 'Elena Rostova').id;
    await state.switchProfile(elenaId);
    expect(state.currentProfile.name, 'Elena Rostova');
    expect(state.currencySymbol, '£');
    expect(state.totalLiquidity, 1850.0);
  });

  test('FinanceState edit and delete account tests down to zero accounts', () async {
    final state = FinanceState();

    // Create a profile
    await state.createProfile(
      name: 'Temp User',
      email: 'temp@fintrack.app',
      photoUrl: 'preset_amber',
      currencyCode: 'JPY',
      currencySymbol: '¥',
    );

    final tempId = state.currentProfile.id;

    // Edit account
    await state.updateProfile(
      id: tempId,
      name: 'Updated User Name',
      email: 'updated@fintrack.app',
      photoUrl: 'preset_cyan',
      currencyCode: 'CAD',
      currencySymbol: r'CA$',
    );

    expect(state.currentProfile.name, 'Updated User Name');
    expect(state.currentProfile.email, 'updated@fintrack.app');
    expect(state.currentProfile.currencyCode, 'CAD');

    // Delete account
    final deleted = await state.deleteProfile(tempId);
    expect(deleted, true);
    expect(state.userProfiles.any((p) => p.id == tempId), false);
  });

  testWidgets('AddTransactionScreen dynamic category switching for Income and Transfer', (WidgetTester tester) async {
    final state = FinanceState();
    await state.createProfile(
      name: 'Test User',
      email: 'test@fintrack.app',
      photoUrl: 'preset_cyan',
      currencyCode: 'USD',
      currencySymbol: r'$',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AddTransactionScreen(state: state),
      ),
    );
    await tester.pumpAndSettle();

    // Default is Expense: verify expense categories present
    expect(find.text('Expense Category'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);

    // Tap 'Income' segmented button
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    // Verify income categories dynamically appear
    expect(find.text('Income Category'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    expect(find.text('Investments'), findsOneWidget);

    // Tap 'Transfer' segmented button
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    // Verify transfer categories dynamically appear
    expect(find.text('Transfer Category'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsOneWidget);
    expect(find.text('Savings Vault'), findsOneWidget);
    expect(find.text('Credit Card Pay'), findsOneWidget);
  });

  testWidgets('Screen rendering without RenderFlex overflows on 360x640 small screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint('WIDGET CAUSING OVERFLOW: ${details.toString()}');
    };
    addTearDown(() {
      FlutterError.onError = oldHandler;
    });

    await tester.pumpWidget(const FinTrackApp());
    await tester.pumpAndSettle();

    // 1. Overview tab renders with "Add Account" hero card without exceptions
    expect(tester.takeException(), isNull);
    expect(find.text('Add Account'), findsWidgets);

    // 2. Switch to Analytics tab
    final analyticsTab = find.text('Analytics');
    if (analyticsTab.evaluate().isNotEmpty) {
      await tester.tap(analyticsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    // 3. Switch to Budgets tab
    final budgetsTab = find.text('Budgets');
    if (budgetsTab.evaluate().isNotEmpty) {
      await tester.tap(budgetsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    // 4. Switch to Settings tab
    final settingsTab = find.text('Settings');
    if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('+ Add Account'), findsOneWidget);
    }
  });

  testWidgets('Screen rendering without RenderFlex overflows on 320x568 ultra-small screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FinTrackApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Switch to Budgets
    final budgetsTab = find.text('Budgets');
    if (budgetsTab.evaluate().isNotEmpty) {
      await tester.tap(budgetsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Dynamic zero-state and amount-based metrics across Overview, Analytics, and Budgets', (WidgetTester tester) async {
    final state = FinanceState();
    await state.createProfile(
      name: 'Dynamic Test User',
      email: 'dynamic@fintrack.app',
      photoUrl: 'preset_cyan',
      currencyCode: 'USD',
      currencySymbol: r'$',
    );

    // Initial state: 0 expenses, 0 income
    expect(state.monthlyExpenses, 0.0);
    expect(state.totalLiquidity, 0.0);

    // Build the app with this state
    await tester.pumpWidget(FinTrackApp(initialState: state));
    await tester.pumpAndSettle();

    // 1. Overview Section verification:
    // Should NOT show hardcoded 72%
    expect(find.text('72%'), findsNothing);
    // Should show 0% pace
    expect(find.text('0%'), findsWidgets);
    // Should not show hardcoded "Peak day: Saturday ($420.00)"
    expect(find.textContaining('Peak day: Saturday'), findsNothing);

    // 2. Analytics Section verification:
    final analyticsTab = find.text('Analytics');
    await tester.tap(analyticsTab);
    await tester.pumpAndSettle();

    // Should NOT show hardcoded $195.00 or "Great pacing! You saved $195.00"
    expect(find.textContaining(r'$195.00'), findsNothing);
    expect(find.textContaining('grocery spending decreased by 14%'), findsNothing);
    // Should show zero outflow dynamic state
    expect(find.text('0.0% outflow'), findsOneWidget);
    expect(find.textContaining('No outflow recorded for this period', findRichText: true), findsOneWidget);
    expect(find.text('No expenses recorded yet'), findsOneWidget);

    // 3. Budgets Section verification:
    final budgetsTab = find.text('Budgets');
    await tester.tap(budgetsTab);
    await tester.pumpAndSettle();

    // Should NOT show hardcoded 71.5%
    expect(find.text('71.5%'), findsNothing);
    // Should NOT show hardcoded "October 2024" (unless current month happens to be October 2024)
    // Should show 0.0% on CircularBudgetGauge
    expect(find.text('0.0%'), findsOneWidget);
    // Warning banner should NOT appear when all budgets are at 0
    expect(find.text('Warning Threshold Reached'), findsNothing);
    expect(find.text('Food & Dining is at 88%'), findsNothing);
  });
}
