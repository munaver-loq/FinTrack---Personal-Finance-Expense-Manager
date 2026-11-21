import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_shell.dart';

import 'state/finance_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark electric midnight theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF080E1B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  final FinanceState? initialState;

  const FinTrackApp({super.key, this.initialState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack - Personal Finance & Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MainShell(state: initialState),
    );
  }
}
