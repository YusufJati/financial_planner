import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/recurring_transaction.dart';
import '../../blocs/recurring/recurring_bloc.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/modern_dialogs.dart';

class RecurringListScreen extends StatelessWidget {
  const RecurringListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recurring Transactions'),
      ),
      body: BlocConsumer<RecurringBloc, RecurringState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading &&
              state.dueToday.isEmpty &&
              state.active.isEmpty) {
            return const ShimmerScreen(listItemCount: 5);
          }

          final isEmpty = state.dueToday.isEmpty &&
              state.active.isEmpty &&
              state.paused.isEmpty;

          if (isEmpty) {
            return const EmptyState(
              icon: Icons.repeat,
              title: 'No Recurring Transactions',
              subtitle: 'Add recurring transactions for automatic tracking',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<RecurringBloc>().add(LoadRecurring());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Due Today Section
                if (state.dueToday.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Due Today',
                    count: state.dueToday.length,
                    color: AppColors.warning,
                  ),
                  ...state.dueToday.map((r) => _RecurringCard(
                        recurring: r,
                        isDue: true,
                        categoryName: _getCategoryName(context, r),
                      )),
                  const SizedBox(height: 24),
                ],

                // Active Section
                if (state.active.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Active',
                    count: state.active.length,
                    color: AppColors.income,
                  ),
                  ...state.active.map((r) => _RecurringCard(
                        recurring: r,
                        categoryName: _getCategoryName(context, r),
                      )),
                  const SizedBox(height: 24),
                ],

                // Paused Section
                if (state.paused.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Paused',
                    count: state.paused.length,
                    color: AppColors.textSecondary,
                  ),
                  ...state.paused.map((r) => _RecurringCard(
                        recurring: r,
                        isPaused: true,
                        categoryName: _getCategoryName(context, r),
                      )),
                ],

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recurring/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring'),
      ),
    );
  }

  String _getCategoryName(BuildContext context, RecurringTransaction r) {
    final state = context.read<RecurringBloc>().state;
    final allCategories = [
      ...state.expenseCategories,
      ...state.incomeCategories
    ];
    final category = allCategories.firstWhere(
      (c) => c.id == r.categoryId,
      orElse: () => allCategories.first,
    );
    return category.name;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  final RecurringTransaction recurring;
  final String categoryName;
  final bool isDue;
  final bool isPaused;

  const _RecurringCard({
    required this.recurring,
    required this.categoryName,
    this.isDue = false,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = recurring.type.index == 0
        ? AppColors.expense
        : (recurring.type.index == 1 ? AppColors.income : AppColors.transfer);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showActions(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recurring.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isPaused ? AppColors.textSecondary : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$categoryName • ${recurring.frequency.displayName}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(recurring.amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPaused ? AppColors.textSecondary : color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isDue ? AppColors.warning : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Next: ${DateFormat('dd MMM yyyy').format(recurring.nextDueDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDue ? AppColors.warning : AppColors.textSecondary,
                      fontWeight: isDue ? FontWeight.w600 : null,
                    ),
                  ),
                  if (isDue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                  if (isPaused) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PAUSED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showAppBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDue) ...[
              ListTile(
                leading: const Icon(LucideIcons.checkCircle,
                    color: AppColors.primary),
                title: const Text('Execute Now'),
                subtitle: const Text('Record this transaction'),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<RecurringBloc>()
                      .add(ExecuteRecurring(recurring.id));
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.skipForward,
                    color: AppColors.primary),
                title: const Text('Skip'),
                subtitle: const Text('Skip to next occurrence'),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<RecurringBloc>()
                      .add(SkipRecurring(recurring.id));
                },
              ),
            ],
            ListTile(
              leading: Icon(
                isPaused ? LucideIcons.play : LucideIcons.pause,
                color: AppColors.primary,
              ),
              title: Text(isPaused ? 'Activate' : 'Pause'),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<RecurringBloc>()
                    .add(ToggleRecurringStatus(recurring.id));
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2,
                  color: AppColors.primary),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recurring?'),
        content: Text('Delete "${recurring.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RecurringBloc>().add(DeleteRecurring(recurring.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
