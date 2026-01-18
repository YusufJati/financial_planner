import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/goal.dart';
import '../../blocs/goal/goal_bloc.dart';
import '../../widgets/common/modern_dialogs.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        // Find updated goal from state
        final currentGoal = state.activeGoals.firstWhere(
          (g) => g.id == goal.id,
          orElse: () => state.completedGoals.firstWhere(
            (g) => g.id == goal.id,
            orElse: () => goal,
          ),
        );

        return _GoalDetailContent(goal: currentGoal);
      },
    );
  }
}

class _GoalDetailContent extends StatelessWidget {
  final Goal goal;

  const _GoalDetailContent({required this.goal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.fromHex(goal.color);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Goal Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _confirmDelete(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Goal'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getGoalIcon(goal.icon),
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      goal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (goal.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        goal.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(goal.progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 12,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saved',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            Text(
                              CurrencyFormatter.format(goal.currentAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Target',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            Text(
                              CurrencyFormatter.format(goal.targetAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Remaining',
                      value:
                          CurrencyFormatter.formatCompact(goal.remainingAmount),
                      icon: Icons.savings,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Days Left',
                      value: goal.daysRemaining?.toString() ?? '-',
                      icon: Icons.calendar_today,
                      color:
                          goal.daysRemaining != null && goal.daysRemaining! <= 0
                              ? AppColors.expense
                              : AppColors.warning,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              if (goal.dailySavingsNeeded != null &&
                  goal.dailySavingsNeeded! > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.income),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Save ${CurrencyFormatter.formatCompact(goal.dailySavingsNeeded!)} daily to reach your goal on time',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (goal.targetDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: color),
                      const SizedBox(width: 12),
                      Text(
                        'Target date: ${DateFormat('dd MMM yyyy').format(goal.targetDate!)}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDepositDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Money'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.income,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: goal.currentAmount > 0
                          ? () => _showWithdrawDialog(context)
                          : null,
                      icon: const Icon(Icons.remove),
                      label: const Text('Withdraw'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    final controller = TextEditingController();
    showAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Money'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixText: 'Rp ',
            hintText: 'Amount',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                context
                    .read<GoalBloc>()
                    .add(DepositToGoal(goalId: goal.id, amount: amount));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final controller = TextEditingController();
    showAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available: ${CurrencyFormatter.format(goal.currentAmount)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: 'Amount',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0 && amount <= goal.currentAmount) {
                context
                    .read<GoalBloc>()
                    .add(WithdrawFromGoal(goalId: goal.id, amount: amount));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showModernDialog(
      context: context,
      icon: LucideIcons.trash2,
      title: 'Hapus Goal? 🗑️',
      subtitle: 'Goal "${goal.name}" akan dihapus beserta semua progressnya.',
      description: 'Aksi ini tidak dapat dibatalkan!',
      cancelText: 'Batal',
      confirmText: 'Hapus',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<GoalBloc>().add(DeleteGoal(goal.id));
      context.pop();
    }
  }

  IconData _getGoalIcon(String iconName) {
    final iconMap = {
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
