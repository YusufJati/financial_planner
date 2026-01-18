import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/spacing.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/goal/goal_bloc.dart';
import '../../blocs/diary/diary_bloc.dart';
import '../../widgets/common/common_widgets.dart';
import 'widgets/balance_card.dart';
import 'widgets/account_list.dart';
import 'widgets/expense_chart.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/financial_diary_widget.dart';
import '../../widgets/common/stylish_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.isLoading && state.accounts.isEmpty) {
                return const ShimmerScreen(cardCount: 1, listItemCount: 5);
              }

              if (state.error != null && state.accounts.isEmpty) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error loading data',
                  subtitle: state.error,
                  actionText: 'Retry',
                  onAction: () {
                    context.read<HomeBloc>().add(LoadHomeData());
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(RefreshHomeData());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Stylish Header
                      const StylishHeader(showGreeting: true),

                      // Balance Card
                      BalanceCard(
                        totalBalance: state.totalBalance,
                        monthlyIncome: state.monthlyIncome,
                        monthlyExpense: state.monthlyExpense,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Quick Actions
                      const SectionHeader(title: 'Quick Actions'),
                      QuickActionGrid(
                        crossAxisCount: 5,
                        items: [
                      QuickActionItem(
                        icon: LucideIcons.arrowDown,
                        label: 'Income',
                        color: AppColors.income,
                        onTap: () async {
                              final result = await context
                                  .push('/transaction/add?type=income');
                              if (result == true && context.mounted) {
                                context.read<HomeBloc>().add(RefreshHomeData());
                              }
                            },
                          ),
                      QuickActionItem(
                        icon: LucideIcons.arrowUp,
                        label: 'Expense',
                        color: AppColors.expense,
                        onTap: () async {
                              final result = await context
                                  .push('/transaction/add?type=expense');
                              if (result == true && context.mounted) {
                                context.read<HomeBloc>().add(RefreshHomeData());
                              }
                            },
                          ),
                      QuickActionItem(
                        icon: LucideIcons.arrowLeftRight,
                        label: 'Transfer',
                        color: AppColors.transfer,
                        onTap: () async {
                              final result = await context
                                  .push('/transaction/add?type=transfer');
                              if (result == true && context.mounted) {
                                context.read<HomeBloc>().add(RefreshHomeData());
                              }
                            },
                          ),
                      QuickActionItem(
                        icon: LucideIcons.pieChart,
                        label: 'Budget',
                        color: AppColors.warning,
                        onTap: () => context.go('/budget'),
                      ),
                      QuickActionItem(
                        icon: LucideIcons.bookOpen,
                        label: 'Diary',
                        color: AppColors.primary,
                        onTap: () => context.push('/diary'),
                      ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Savings Goal
                      SectionHeader(
                        title: 'Savings Goals',
                        actionText: 'See All',
                        onActionTap: () => context.go('/goals'),
                      ),
                      BlocBuilder<GoalBloc, GoalState>(
                        builder: (context, goalState) {
                          if (goalState.activeGoals.isEmpty) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              child: SavingsGoalEmptyState(
                                onAddGoal: () => context.go('/goals'),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 210,
                            child: PageView.builder(
                              controller: PageController(viewportFraction: 0.9),
                              itemCount: goalState.activeGoals.length,
                              itemBuilder: (context, index) {
                                final goal = goalState.activeGoals[index];
                                final goalColor = AppColors.fromHex(goal.color);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs),
                                  child: SavingsGoalWidget(
                                    title: goal.name,
                                    currentAmount: goal.currentAmount,
                                    targetAmount: goal.targetAmount,
                                    targetDate: goal.targetDate,
                                    icon: _getGoalIcon(goal.icon),
                                    gradientColors: [
                                      goalColor,
                                      goalColor.withAlpha(180)
                                    ],
                                    onTap: () =>
                                        context.push('/goal/detail', extra: goal),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // My Accounts
                      SectionHeader(
                        title: 'My Accounts',
                        actionText: 'Manage',
                        onActionTap: () => context.go('/accounts'),
                      ),
                      AccountListHorizontal(
                        accounts: state.accounts,
                        onAddAccount: () async {
                          final result = await context.push('/account/add');
                          if (result == true && context.mounted) {
                            context.read<HomeBloc>().add(RefreshHomeData());
                          }
                        },
                        onAccountTap: (account) async {
                          final result =
                              await context.push('/account/detail', extra: account);
                          if (result == true && context.mounted) {
                            context.read<HomeBloc>().add(RefreshHomeData());
                          }
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // This Month Chart
                      SectionHeader(
                        title: 'This Month',
                        actionText: 'Details',
                        onActionTap: () => context.go('/transactions'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: ExpensePieChart(
                          spendingByCategory: state.spendingByCategory,
                          categoryNames: state.categoryNames,
                          categoryColors: state.categoryColors,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Financial Diary
                      BlocBuilder<DiaryBloc, DiaryState>(
                        builder: (context, diaryState) {
                          return FinancialDiaryWidget(
                            totalIncome: diaryState.totalIncome,
                            totalExpense: diaryState.totalExpense,
                            expenseByCategory: diaryState.expenseByCategory,
                            selectedMonth: diaryState.selectedMonth,
                            selectedYear: diaryState.selectedYear,
                            isLoading: diaryState.isLoading,
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      SectionHeader(
                        title: 'Recent Transactions',
                        actionText: 'See All',
                        onActionTap: () => context.go('/transactions'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: RecentTransactionsList(
                          transactions: state.recentTransactions,
                          onSeeAll: () => context.go('/transactions'),
                          onTransactionTap: (transaction) {
                            context.go('/transactions');
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s100), // Space for bottom nav
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionMenu(
        items: [
          FloatingActionMenuItem(
            icon: LucideIcons.arrowDown,
            label: 'Income',
            foregroundColor: AppColors.income,
            onTap: () async {
              final result = await context.push('/transaction/add?type=income');
              if (result == true && context.mounted) {
                context.read<HomeBloc>().add(RefreshHomeData());
              }
            },
          ),
          FloatingActionMenuItem(
            icon: LucideIcons.arrowUp,
            label: 'Expense',
            foregroundColor: AppColors.expense,
            onTap: () async {
              final result =
                  await context.push('/transaction/add?type=expense');
              if (result == true && context.mounted) {
                context.read<HomeBloc>().add(RefreshHomeData());
              }
            },
          ),
          FloatingActionMenuItem(
            icon: LucideIcons.arrowLeftRight,
            label: 'Transfer',
            foregroundColor: AppColors.transfer,
            onTap: () async {
              final result =
                  await context.push('/transaction/add?type=transfer');
              if (result == true && context.mounted) {
                context.read<HomeBloc>().add(RefreshHomeData());
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Helper to convert icon name to IconData
IconData _getGoalIcon(String iconName) {
  const iconMap = {
    'target': Icons.gps_fixed,
    'home': Icons.home,
    'car': Icons.directions_car,
    'plane': Icons.flight,
    'graduation-cap': Icons.school,
    'ring': Icons.favorite,
    'baby': Icons.child_care,
    'umbrella': Icons.umbrella,
    'piggy-bank': Icons.savings,
    'laptop': Icons.laptop,
    'phone': Icons.phone_android,
    'camera': Icons.camera_alt,
  };
  return iconMap[iconName] ?? Icons.flag;
}
