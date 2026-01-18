import 'package:flutter/material.dart';
import '../../../app/themes/colors.dart';
import '../../../core/utils/currency_formatter.dart';
import 'gradient_progress_bar.dart';

/// Savings goal widget with animated progress and glassmorphism style
class SavingsGoalWidget extends StatefulWidget {
  final String title;
  final double currentAmount;
  final double targetAmount;
  final IconData? icon;
  final DateTime? targetDate;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final bool compact;

  const SavingsGoalWidget({
    super.key,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    this.icon,
    this.targetDate,
    this.gradientColors,
    this.onTap,
    this.compact = false,
  });

  @override
  State<SavingsGoalWidget> createState() => _SavingsGoalWidgetState();
}

class _SavingsGoalWidgetState extends State<SavingsGoalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get progress => widget.targetAmount > 0
      ? (widget.currentAmount / widget.targetAmount).clamp(0.0, 1.0)
      : 0.0;

  String get daysRemaining {
    if (widget.targetDate == null) return '';
    final days = widget.targetDate!.difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Today';
    if (days == 1) return '1 day left';
    return '$days days left';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = widget.gradientColors ??
        [
          AppColors.primary,
          AppColors.primaryLight,
        ];

    if (widget.compact) {
      return _buildCompactView(context, isDark, gradientColors);
    }

    return _buildFullView(context, isDark, gradientColors);
  }

  Widget _buildFullView(
      BuildContext context, bool isDark, List<Color> gradientColors) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradientColors[0].withOpacity(0.15),
                      gradientColors[1].withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: gradientColors[0].withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradientColors),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon ?? Icons.savings_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.targetDate != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  daysRemaining,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: gradientColors[0].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              color: gradientColors[0],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GradientProgressBar(
                      progress: progress,
                      height: 10,
                      gradientColors: gradientColors,
                      showGlow: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountLabel(
                          'Current',
                          CurrencyFormatter.formatCompact(widget.currentAmount),
                          isDark,
                        ),
                        _buildAmountLabel(
                          'Target',
                          CurrencyFormatter.formatCompact(widget.targetAmount),
                          isDark,
                          alignment: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactView(
      BuildContext context, bool isDark, List<Color> gradientColors) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: gradientColors[0].withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            GradientCircularProgress(
              progress: progress,
              size: 56,
              strokeWidth: 5,
              gradientColors: gradientColors,
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyFormatter.formatCompact(widget.currentAmount)} / ${CurrencyFormatter.formatCompact(widget.targetAmount)}',
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
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountLabel(
    String label,
    String amount,
    bool isDark, {
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Goals list widget to show multiple savings goals
class SavingsGoalsList extends StatelessWidget {
  final List<SavingsGoalData> goals;
  final Function(SavingsGoalData)? onGoalTap;
  final VoidCallback? onAddGoal;

  const SavingsGoalsList({
    super.key,
    required this.goals,
    this.onGoalTap,
    this.onAddGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...goals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SavingsGoalWidget(
                title: goal.title,
                currentAmount: goal.currentAmount,
                targetAmount: goal.targetAmount,
                icon: goal.icon,
                targetDate: goal.targetDate,
                gradientColors: goal.colors,
                compact: true,
                onTap: () => onGoalTap?.call(goal),
              ),
            )),
        if (onAddGoal != null)
          TextButton.icon(
            onPressed: onAddGoal,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add New Goal'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
      ],
    );
  }
}

/// Data class for savings goal
class SavingsGoalData {
  final String id;
  final String title;
  final double currentAmount;
  final double targetAmount;
  final IconData? icon;
  final DateTime? targetDate;
  final List<Color>? colors;

  const SavingsGoalData({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    this.icon,
    this.targetDate,
    this.colors,
  });
}

/// Empty state widget for savings goal section
class SavingsGoalEmptyState extends StatefulWidget {
  final VoidCallback? onAddGoal;

  const SavingsGoalEmptyState({
    super.key,
    this.onAddGoal,
  });

  @override
  State<SavingsGoalEmptyState> createState() => _SavingsGoalEmptyStateState();
}

class _SavingsGoalEmptyStateState extends State<SavingsGoalEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onAddGoal,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primaryLight.withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    // Animated Icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.savings_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'No Savings Goals Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      'Start saving for your dreams!\nSet your first savings goal now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Add Goal Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onAddGoal,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add Savings Goal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
