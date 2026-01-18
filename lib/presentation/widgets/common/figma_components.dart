import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/spacing.dart';

/// Simple progress bar matching Figma design - solid color with rounded ends
class FigmaProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;

  const FigmaProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgress = progress.clamp(0.0, 1.0);
    final effectiveColor = progressColor ?? AppColors.primary;
    final effectiveBgColor = backgroundColor ?? const Color(0xFFE8E8E8);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: effectiveProgress,
        child: Container(
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// Animated version of the Figma progress bar
class FigmaProgressBarAnimated extends StatefulWidget {
  final double progress;
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final Duration duration;

  const FigmaProgressBarAnimated({
    super.key,
    required this.progress,
    this.height = 6,
    this.progressColor,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<FigmaProgressBarAnimated> createState() =>
      _FigmaProgressBarAnimatedState();
}

class _FigmaProgressBarAnimatedState extends State<FigmaProgressBarAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(FigmaProgressBarAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FigmaProgressBar(
          progress: _animation.value,
          height: widget.height,
          progressColor: widget.progressColor,
          backgroundColor: widget.backgroundColor,
        );
      },
    );
  }
}

/// Budget category card matching Figma design
/// Shows category with icon, total amount, and sub-items with progress bars
class BudgetCategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final double totalAmount;
  final List<BudgetSubItem> subItems;
  final VoidCallback? onTap;

  const BudgetCategoryCard({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.subItems,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Category Name + Total
          _buildHeader(isDark),
          if (subItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            // Sub-items
            ...subItems.map((item) => _buildSubItem(item, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        // Category Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: categoryColor.withAlpha(25),
            borderRadius: AppRadius.radiusSm,
          ),
          child: Icon(
            categoryIcon,
            color: categoryColor,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Category Name
        Expanded(
          child: Text(
            categoryName,
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        // Total Amount
        Text(
          '\$${totalAmount.toStringAsFixed(0)}',
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubItem(BudgetSubItem item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and amounts row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.spent.toStringAsFixed(0)}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Left \$${item.remaining.toStringAsFixed(0)}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Progress bar
          FigmaProgressBarAnimated(
            progress: item.budget > 0 ? (item.spent / item.budget) : 0,
            progressColor:
                item.isOverBudget ? AppColors.accent : AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Sub-item data for budget category card
class BudgetSubItem {
  final String name;
  final double spent;
  final double budget;

  const BudgetSubItem({
    required this.name,
    required this.spent,
    required this.budget,
  });

  double get remaining => (budget - spent).clamp(0, double.infinity);
  bool get isOverBudget => spent > budget;
}

/// Budget summary card showing left to spend and monthly budget
class BudgetSummaryCard extends StatelessWidget {
  final double leftToSpend;
  final double monthlyBudget;
  final double spent;

  const BudgetSummaryCard({
    super.key,
    required this.leftToSpend,
    required this.monthlyBudget,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = monthlyBudget > 0 ? (spent / monthlyBudget) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Left to spend',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '\$${leftToSpend.toStringAsFixed(0)}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Monthly budget',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '\$${monthlyBudget.toStringAsFixed(0)}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Multi-color progress bar (orange portion + blue portion)
          _buildMultiColorProgress(progress),
        ],
      ),
    );
  }

  Widget _buildMultiColorProgress(double progress) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Orange portion (spent)
          Flexible(
            flex: (progress * 60).round().clamp(0, 60),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.horizontal(
                  left: const Radius.circular(4),
                  right:
                      progress >= 1.0 ? const Radius.circular(4) : Radius.zero,
                ),
              ),
            ),
          ),
          // Blue portion (remaining budget portion)
          if (progress < 1.0)
            Flexible(
              flex: ((1.0 - progress) * 40).round().clamp(0, 40),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(4),
                  ),
                ),
              ),
            ),
          // Gray remaining
          Flexible(
            flex: 100 - (progress * 100).round().clamp(0, 100),
            child: const SizedBox(),
          ),
        ],
      ),
    );
  }
}
