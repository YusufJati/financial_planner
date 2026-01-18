import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/budget.dart';
import '../../blocs/budget/budget_bloc.dart';
import '../../widgets/common/stylish_header.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/modern_dialogs.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StylishHeader(
            title: 'My Budgets',
            subtitle: 'Track your limits',
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () => context.push('/budget/add'),
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<BudgetBloc, BudgetState>(
              builder: (context, state) {
                if (state.isLoading && state.budgets.isEmpty) {
                  return const ShimmerScreen(cardCount: 1, listItemCount: 4);
                }

                if (state.error != null && state.budgets.isEmpty) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'Error loading budgets',
                    subtitle: state.error,
                    actionText: 'Retry',
                    onAction: () {
                      context.read<BudgetBloc>().add(LoadBudgets());
                    },
                  );
                }

                if (state.budgets.isEmpty) {
                  return EmptyState(
                    icon: Icons.pie_chart_outline,
                    title: 'No Budgets Yet',
                    subtitle: 'Create a budget to track your spending',
                    actionText: 'Create Budget',
                    onAction: () => context.push('/budget/add'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<BudgetBloc>().add(RefreshBudgets());
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary Card
                      _BudgetSummaryCard(
                        totalBudget: state.totalBudget,
                        totalSpent: state.totalSpent,
                        progress: state.overallProgress,
                      ),

                      const SizedBox(height: 24),

                      // Section Header
                      Text(
                        'Category Budgets',
                        style: GoogleFonts.spaceMono(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Budget List
                      ...state.budgets.map((budget) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BudgetItem(
                              budget: budget,
                              onTap: () => _showBudgetOptions(context, budget),
                            ),
                          )),

                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/budget/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }

  void _showBudgetOptions(BuildContext context, Budget budget) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final iconBackground =
        isDark ? AppColors.borderDark : AppColors.primarySoft;

    showAppBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        side: BorderSide(color: borderColor),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(LucideIcons.pencil, color: AppColors.primary),
                ),
                title: const Text('Edit Budget'),
                subtitle: const Text('Modify budget amount'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/budget/add', extra: budget);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(LucideIcons.trash2, color: AppColors.primary),
                ),
                title: const Text('Delete Budget'),
                subtitle: const Text('Remove this budget'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, budget);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Budget budget) async {
    final confirmed = await showModernDialog(
      context: context,
      icon: LucideIcons.trash2,
      title: 'Hapus Budget? 🗑️',
      subtitle:
          'Budget untuk "${budget.category?.name ?? 'kategori ini'}" akan dihapus.',
      description: 'Aksi ini tidak dapat dibatalkan!',
      cancelText: 'Batal',
      confirmText: 'Hapus',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<BudgetBloc>().add(DeleteBudget(budget.id));
    }
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double progress;

  const _BudgetSummaryCard({
    required this.totalBudget,
    required this.totalSpent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudget - totalSpent;
    final isOverBudget = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? [AppColors.expense, AppColors.expense.withOpacity(0.8)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? AppColors.expense : AppColors.primary)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalBudget),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                isOverBudget ? Colors.red.shade300 : Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _SummaryStatItem(
                  label: 'Spent',
                  value: CurrencyFormatter.formatCompact(totalSpent),
                  icon: Icons.arrow_upward,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _SummaryStatItem(
                  label: isOverBudget ? 'Over Budget' : 'Remaining',
                  value: CurrencyFormatter.formatCompact(remaining.abs()),
                  icon: isOverBudget ? Icons.warning : Icons.savings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BudgetItem extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;

  const _BudgetItem({
    required this.budget,
    this.onTap,
  });

  Color get statusColor {
    switch (budget.status) {
      case BudgetStatus.normal:
        return AppColors.income;
      case BudgetStatus.warning:
        return AppColors.warning;
      case BudgetStatus.exceeded:
        return AppColors.expense;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = budget.category != null
        ? AppColors.fromHex(budget.category!.color)
        : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: categoryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(budget.category?.icon ?? 'category'),
                    color: categoryColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            budget.category?.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(budget.progress * 100).toInt()}%',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${CurrencyFormatter.formatCompact(budget.spentAmount)} / ${CurrencyFormatter.formatCompact(budget.amount)}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),

            if (budget.isOverBudget) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.expense, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Over budget by ${CurrencyFormatter.formatCompact(budget.spentAmount - budget.amount)}',
                    style: const TextStyle(
                      color: AppColors.expense,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    final iconMap = {
      'utensils': Icons.restaurant,
      'car': Icons.directions_car,
      'shopping-bag': Icons.shopping_bag,
      'file-text': Icons.receipt,
      'heart-pulse': Icons.medical_services,
      'gamepad-2': Icons.sports_esports,
      'graduation-cap': Icons.school,
      'more-horizontal': Icons.more_horiz,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
