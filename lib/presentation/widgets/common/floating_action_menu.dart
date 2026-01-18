import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/text_styles.dart';

/// Expandable floating action button menu with animations
class FloatingActionMenu extends StatefulWidget {
  final List<FloatingActionMenuItem> items;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData mainIcon;
  final IconData closeIcon;
  final double spacing;
  final Duration animationDuration;
  final Alignment alignment;

  const FloatingActionMenu({
    super.key,
    required this.items,
    this.backgroundColor,
    this.foregroundColor,
    this.mainIcon = LucideIcons.plus,
    this.closeIcon = LucideIcons.x,
    this.spacing = 12,
    this.animationDuration = const Duration(milliseconds: 300),
    this.alignment = Alignment.bottomRight,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.primary;
    final fgColor = widget.foregroundColor ?? AppColors.surface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.alignment == Alignment.bottomRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // Menu items
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[widget.items.length - 1 - index];
          final delay = index / widget.items.length;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final itemAnimation = CurvedAnimation(
                parent: _controller,
                curve: Interval(delay * 0.5, 0.5 + delay * 0.5,
                    curve: Curves.easeOutBack),
              );

              return Transform.scale(
                scale: itemAnimation.value,
                child: Opacity(
                  opacity: itemAnimation.value.clamp(0.0, 1.0),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: widget.spacing),
                    child: _FloatingMenuItem(
                      item: item,
                      onTap: () {
                        _toggle();
                        item.onTap?.call();
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Main FAB
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * math.pi,
              child: FloatingActionButton(
                onPressed: _toggle,
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                elevation: _isOpen ? 3 : 2,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    _isOpen ? widget.closeIcon : widget.mainIcon,
                    key: ValueKey(_isOpen),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Menu item for FloatingActionMenu
class FloatingActionMenuItem {
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;

  const FloatingActionMenuItem({
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
  });
}

class _FloatingMenuItem extends StatelessWidget {
  final FloatingActionMenuItem item;
  final VoidCallback? onTap;

  const _FloatingMenuItem({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = item.backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surface);
    final fgColor = item.foregroundColor ?? AppColors.primary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.radiusSm,
            border: Border.all(color: borderColor),
          ),
          child: Text(
            item.label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Mini FAB
        Material(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
            side: BorderSide(color: borderColor),
          ),
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.radiusSm,
            child: Container(
              width: 46,
              height: 46,
              child: Icon(
                item.icon,
                color: fgColor,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
