import 'package:flutter/material.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/spacing.dart';
import '../../../app/themes/text_styles.dart';

/// Quick action grid widget with animated tiles
class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> items;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const QuickActionGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 4,
    this.spacing = 12,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _QuickActionTile(
            item: items[index],
            index: index,
          );
        },
      ),
    );
  }
}

/// Quick action item data
class QuickActionItem {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBadge;
  final String? badgeText;

  const QuickActionItem({
    required this.icon,
    required this.label,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.showBadge = false,
    this.badgeText,
  });
}

class _QuickActionTile extends StatefulWidget {
  final QuickActionItem item;
  final int index;

  const _QuickActionTile({
    required this.item,
    required this.index,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.1,
          0.5 + widget.index * 0.1,
          curve: Curves.elasticOut,
        ),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.1,
          0.3 + widget.index * 0.1,
          curve: Curves.easeOut,
        ),
      ),
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
    final color = widget.item.color ?? AppColors.primary;
    final bgColor = widget.item.backgroundColor ?? color.withAlpha(20);
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.item.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: AppRadius.radiusSm,
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: AppRadius.radiusSm,
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs - 1),
                      Text(
                        widget.item.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.item.showBadge)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm - 2,
                        vertical: AppSpacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Text(
                        widget.item.badgeText ?? '',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.surface,
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
  }
}

/// Horizontal quick action list
class QuickActionList extends StatelessWidget {
  final List<QuickActionItem> items;
  final double itemWidth;
  final double height;
  final EdgeInsetsGeometry? padding;

  const QuickActionList({
    super.key,
    required this.items,
    this.itemWidth = 80,
    this.height = 100,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          return SizedBox(
            width: itemWidth,
            child: _QuickActionTile(
              item: items[index],
              index: index,
            ),
          );
        },
      ),
    );
  }
}
