import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/themes/colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/goal.dart';
import '../../blocs/goal/goal_bloc.dart';
import '../../widgets/common/stylish_header.dart';
import '../../widgets/common/common_widgets.dart';

class GoalListScreen extends StatelessWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            StylishHeader(
              title: 'Savings Goals',
              subtitle: 'Dream big!',
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () async {
                    final result = await context.push('/goal/add');
                    if (result == true && context.mounted) {
                      context.read<GoalBloc>().add(RefreshGoals());
                    }
                  },
                ),
              ],
            ),
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const TabBar(
                dividerColor: Colors.transparent,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<GoalBloc, GoalState>(
                builder: (context, state) {
                  if (state.isLoading && state.activeGoals.isEmpty) {
                    return const ShimmerScreen(cardCount: 1, listItemCount: 3);
                  }

                  return TabBarView(
                    children: [
                      _GoalList(
                        goals: state.activeGoals,
                        emptyMessage: 'No active goals',
                        emptySubtitle: 'Start saving for your dreams!',
                        summaryCard: state.activeGoals.isNotEmpty
                            ? _GoalSummaryCard(
                                totalSavings: state.totalSavings,
                                totalTarget: state.totalTarget,
                                progress: state.overallProgress,
                                goalCount: state.activeGoals.length,
                              )
                            : null,
                      ),
                      _GoalList(
                        goals: state.completedGoals,
                        emptyMessage: 'No completed goals yet',
                        emptySubtitle: 'Complete a goal to see it here',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await context.push('/goal/add');
            if (result == true && context.mounted) {
              context.read<GoalBloc>().add(RefreshGoals());
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('New Goal'),
        ),
      ),
    );
  }
}

class _GoalSummaryCard extends StatelessWidget {
  final double totalSavings;
  final double totalTarget;
  final double progress;
  final int goalCount;

  const _GoalSummaryCard({
    required this.totalSavings,
    required this.totalTarget,
    required this.progress,
    required this.goalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
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
                    'Total Savings',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalSavings),
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
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$goalCount Goals',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% of target',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              Text(
                'Target: ${CurrencyFormatter.formatCompact(totalTarget)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalList extends StatelessWidget {
  final List<Goal> goals;
  final String emptyMessage;
  final String emptySubtitle;
  final Widget? summaryCard;

  const _GoalList({
    required this.goals,
    required this.emptyMessage,
    required this.emptySubtitle,
    this.summaryCard,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty && summaryCard == null) {
      return EmptyState(
        icon: Icons.savings_outlined,
        title: emptyMessage,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<GoalBloc>().add(RefreshGoals());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length + (summaryCard != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (summaryCard != null) {
            if (index == 0) return summaryCard!;
            return _GoalItem(
              goal: goals[index - 1],
              onTap: () =>
                  context.push('/goal/detail', extra: goals[index - 1]),
            );
          }
          return _GoalItem(
            goal: goals[index],
            onTap: () => context.push('/goal/detail', extra: goals[index]),
          );
        },
      ),
    );
  }
}

class _GoalItem extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const _GoalItem({required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.fromHex(goal.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getGoalIcon(goal.icon),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${CurrencyFormatter.formatCompact(goal.currentAmount)} / ${CurrencyFormatter.formatCompact(goal.targetAmount)}',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(goal.progress * 100).toInt()}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (goal.daysRemaining != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.daysRemaining! > 0
                            ? '${goal.daysRemaining}d left'
                            : 'Overdue',
                        style: TextStyle(
                          color: goal.daysRemaining! <= 0
                              ? AppColors.expense
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 6,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
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
