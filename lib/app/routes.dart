import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'themes/colors.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/transactions/transaction_list_screen.dart';
import '../presentation/screens/transactions/add_transaction_screen.dart';
import '../presentation/screens/accounts/account_list_screen.dart';
import '../presentation/screens/accounts/add_account_screen.dart';
import '../presentation/screens/accounts/account_detail_screen.dart';
import '../presentation/screens/budget/budget_list_screen.dart';
import '../presentation/screens/budget/add_budget_screen.dart';
import '../presentation/screens/reports/reports_screen.dart';
import '../presentation/screens/categories/category_list_screen.dart';
import '../presentation/screens/categories/add_edit_category_screen.dart';
import '../presentation/screens/goals/goal_list_screen.dart';
import '../presentation/screens/goals/add_goal_screen.dart';
import '../presentation/screens/goals/goal_detail_screen.dart';
import '../presentation/screens/recurring/recurring_list_screen.dart';
import '../presentation/screens/recurring/add_recurring_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/notifications/notification_settings_screen.dart';
import '../presentation/screens/diary/diary_screen.dart';
import '../presentation/screens/diary/diary_entry_screen.dart';
import '../presentation/screens/credit_score/credit_score_screen.dart';
import '../presentation/screens/bill/bill_screen.dart';
import '../presentation/screens/expenses/expenses_screen.dart';
import '../presentation/blocs/home/home_bloc.dart';
import '../presentation/blocs/transaction/transaction_bloc.dart';
import '../presentation/blocs/account/account_bloc.dart';
import '../presentation/blocs/budget/budget_bloc.dart';
import '../presentation/blocs/report/report_bloc.dart';
import '../presentation/blocs/category/category_bloc.dart';
import '../presentation/blocs/goal/goal_bloc.dart';
import '../presentation/blocs/recurring/recurring_bloc.dart';
import '../presentation/blocs/diary/diary_bloc.dart';
import '../domain/entities/category.dart';
import '../domain/entities/goal.dart';
import '../domain/entities/diary_entry.dart';
import '../domain/entities/account.dart';
import '../injection.dart';
import '../presentation/widgets/common/modern_dialogs.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    // Main Shell with Bottom Navigation
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => getIt<HomeBloc>()..add(LoadHomeData()),
              ),
              BlocProvider(
                create: (_) => getIt<GoalBloc>()..add(LoadGoals()),
              ),
              BlocProvider(
                create: (_) => getIt<DiaryBloc>()
                  ..add(LoadDiaryData(
                    month: DateTime.now().month,
                    year: DateTime.now().year,
                  )),
              ),
            ],
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<TransactionBloc>(),
            child: const TransactionListScreen(),
          ),
        ),
        GoRoute(
          path: '/budget',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<BudgetBloc>()..add(LoadBudgets()),
            child: const BudgetListScreen(),
          ),
        ),
        GoRoute(
          path: '/goals',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<GoalBloc>()..add(LoadGoals()),
            child: const GoalListScreen(),
          ),
        ),
        GoRoute(
          path: '/more',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Standalone Routes (no bottom nav)
    GoRoute(
      path: '/credit-score',
      builder: (context, state) => const CreditScoreScreen(),
    ),
    GoRoute(
      path: '/bill',
      builder: (context, state) => const BillScreen(),
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<BudgetBloc>()..add(LoadBudgets()),
        child: const ExpensesScreen(),
      ),
    ),
    GoRoute(
      path: '/transaction/add',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<TransactionBloc>(),
        child: const AddTransactionScreen(),
      ),
    ),
    GoRoute(
      path: '/account/add',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AccountBloc>(),
        child: const AddAccountScreen(),
      ),
    ),
    GoRoute(
      path: '/account/detail',
      builder: (context, state) {
        final account = state.extra as Account;
        return BlocProvider(
          create: (_) => getIt<AccountBloc>()..add(LoadAccounts()),
          child: AccountDetailScreen(account: account),
        );
      },
    ),
    GoRoute(
      path: '/account/edit',
      builder: (context, state) {
        final account = state.extra as Account;
        return BlocProvider(
          create: (_) => getIt<AccountBloc>(),
          child: AddAccountScreen(account: account),
        );
      },
    ),
    GoRoute(
      path: '/budget/add',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<BudgetBloc>()..add(LoadBudgets()),
        child: const AddBudgetScreen(),
      ),
    ),
    GoRoute(
      path: '/accounts',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AccountBloc>()..add(LoadAccounts()),
        child: const AccountListScreen(),
      ),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ReportBloc>()..add(const LoadReport()),
        child: const ReportsScreen(),
      ),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<CategoryBloc>()..add(LoadCategories()),
        child: const CategoryListScreen(),
      ),
    ),
    GoRoute(
      path: '/category/add',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<CategoryBloc>(),
        child: const AddEditCategoryScreen(),
      ),
    ),
    GoRoute(
      path: '/category/edit',
      builder: (context, state) {
        final category = state.extra as Category;
        return BlocProvider(
          create: (_) => getIt<CategoryBloc>(),
          child: AddEditCategoryScreen(category: category),
        );
      },
    ),
    GoRoute(
      path: '/goal/add',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<GoalBloc>(),
        child: const AddGoalScreen(),
      ),
    ),
    GoRoute(
      path: '/goal/detail',
      builder: (context, state) {
        final goal = state.extra as Goal;
        return BlocProvider(
          create: (_) => getIt<GoalBloc>()..add(LoadGoals()),
          child: GoalDetailScreen(goal: goal),
        );
      },
    ),
    // Recurring Transactions
    GoRoute(
      path: '/recurring',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<RecurringBloc>()..add(LoadRecurring()),
        child: const RecurringListScreen(),
      ),
    ),
    GoRoute(
      path: '/recurring/add',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<RecurringBloc>()..add(LoadRecurring()),
        child: const AddRecurringScreen(),
      ),
    ),
    // Notification Settings
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    // Financial Diary
    GoRoute(
      path: '/diary',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<DiaryBloc>()
          ..add(LoadDiaryData(
            month: DateTime.now().month,
            year: DateTime.now().year,
          )),
        child: const DiaryScreen(),
      ),
    ),
    GoRoute(
      path: '/diary/entry',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final date = extra['date'] as DateTime;
        final entry = extra['entry'] as DiaryEntry?;
        return BlocProvider(
          create: (_) => getIt<DiaryBloc>()
            ..add(LoadDiaryData(
              month: date.month,
              year: date.year,
            )),
          child: DiaryEntryScreen(date: date, entry: entry),
        );
      },
    ),
  ],
);

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  Future<bool> _showExitDialog() async {
    return await showExitAppDialog(context);
  }

  Future<bool> _onBackPressed() async {
    // First check if GoRouter can pop (e.g., from standalone screens)
    if (context.canPop()) {
      context.pop();
      return false; // Return false to prevent default back behavior
    }

    // If we're on a non-home tab, go to home
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      context.go('/');
      return false; // Prevent default back behavior
    }

    // If we're on home and can't pop, show exit dialog
    final shouldExit = await _showExitDialog();
    if (shouldExit) {
      SystemNavigator.pop();
      return false; // Allow exit
    }
    return false; // Don't exit if user cancelled
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final navSurface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onBackPressed();
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: navSurface,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/transactions');
                  break;
                case 2:
                  context.go('/budget');
                  break;
                case 3:
                  context.go('/goals');
                  break;
                case 4:
                  context.go('/more');
                  break;
              }
            },
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.home),
              selectedIcon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.receipt),
              selectedIcon: Icon(LucideIcons.receipt),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.pieChart),
              selectedIcon: Icon(LucideIcons.pieChart),
              label: 'Budget',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.piggyBank),
              selectedIcon: Icon(LucideIcons.piggyBank),
              label: 'Goals',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.moreHorizontal),
              selectedIcon: Icon(LucideIcons.moreHorizontal),
              label: 'More',
            ),
          ],
          ),
        ),
      ),
    );
  }
}
