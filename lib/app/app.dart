import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'themes/app_theme.dart';
import 'themes/colors.dart';
import 'routes.dart';
import '../injection.dart';
import '../presentation/blocs/settings/settings_bloc.dart';

class FinancialPlannerApp extends StatefulWidget {
  const FinancialPlannerApp({super.key});

  @override
  State<FinancialPlannerApp> createState() => _FinancialPlannerAppState();
}

class _FinancialPlannerAppState extends State<FinancialPlannerApp> {
  static const _channel =
      MethodChannel('com.example.financial_planner/back_handler');

  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _setupBackHandler();
  }

  void _setupBackHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBackPressed') {
        _handleBackPressed();
      }
      return null;
    });
  }

  Future<void> _handleBackPressed() async {
    final ctx = router.routerDelegate.navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final now = DateTime.now();

    // If pressed within 2 seconds, exit
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2)) {
      await _channel.invokeMethod('exitApp');
      return;
    }

    // First press - show snackbar
    _lastBackPressTime = now;

    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.logOut, color: AppColors.surface, size: 20),
            SizedBox(width: 12),
            Text('Tekan sekali lagi untuk keluar'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>.value(
      value: getIt<SettingsBloc>(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Money Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
