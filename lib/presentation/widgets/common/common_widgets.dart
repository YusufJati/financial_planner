import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/spacing.dart';
import '../../../app/themes/text_styles.dart';

// Export all widget components
export 'glassmorphism_card.dart';
export 'animated_stat_card.dart';
export 'gradient_progress_bar.dart';
export 'shimmer_loading.dart';
export 'floating_action_menu.dart';
export 'quick_action_grid.dart';
export 'app_background.dart';
export 'savings_goal_widget.dart';
export 'figma_components.dart';
export 'figma_widgets.dart';

/// App Card with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Material(
      color: color ?? (isDark ? AppColors.surfaceDark : AppColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSm,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusSm,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

/// Section Header with title and optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionText!,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Loading indicator
class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: AppRadius.radiusSm,
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text(
                  actionText!,
                  style: AppTextStyles.labelLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Category icon with background
class CategoryIcon extends StatelessWidget {
  final String icon;
  final Color color;
  final double size;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Icon(
          _getIconData(icon),
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'wallet': LucideIcons.wallet,
      'building-2': LucideIcons.building2,
      'smartphone': LucideIcons.smartphone,
      'credit-card': LucideIcons.creditCard,
      'utensils': LucideIcons.utensils,
      'car': LucideIcons.car,
      'shopping-bag': LucideIcons.shoppingBag,
      'file-text': LucideIcons.fileText,
      'heart-pulse': LucideIcons.heartPulse,
      'gamepad-2': LucideIcons.gamepad2,
      'graduation-cap': LucideIcons.graduationCap,
      'more-horizontal': LucideIcons.moreHorizontal,
      'briefcase': LucideIcons.briefcase,
      'gift': LucideIcons.gift,
      'trending-up': LucideIcons.trendingUp,
      'heart': LucideIcons.heart,
      'arrow-left-right': LucideIcons.arrowLeftRight,
      'piggy-bank': LucideIcons.piggyBank,
      'home': LucideIcons.home,
      'plane': LucideIcons.plane,
      'coffee': LucideIcons.coffee,
      'music': LucideIcons.music,
      'book': LucideIcons.book,
      'film': LucideIcons.film,
    };
    return iconMap[iconName] ?? LucideIcons.shapes;
  }
}
