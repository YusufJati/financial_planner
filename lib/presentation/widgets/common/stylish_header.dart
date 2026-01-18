import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/spacing.dart';
import '../../../app/themes/text_styles.dart';
import '../../../data/datasources/local/database_service.dart';
import '../../../injection.dart';
import 'typewriter_text.dart';

class StylishHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showGreeting;
  final bool showBackArrow;
  final List<Widget>? actions;

  const StylishHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showGreeting = false,
    this.showBackArrow = false,
    this.actions,
  });

  String _getUserName() {
    try {
      final db = getIt<DatabaseService>();
      return db.getSetting<String>('userName') ?? 'Financial Hero';
    } catch (_) {
      return 'Financial Hero';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning ☀️';
    } else if (hour < 17) {
      greeting = 'Good Afternoon 🌤️';
    } else {
      greeting = 'Good Evening 🌙';
    }

    final userName = _getUserName();
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.xl,
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        bottom: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          if (showBackArrow)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: AppRadius.radiusSm,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: AppRadius.radiusSm,
                    border: Border.all(color: borderColor),
                  ),
                  child: const Icon(LucideIcons.arrowLeft),
                ),
              ),
            ),
          if (showGreeting) ...[
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: AppRadius.radiusSm,
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: AppColors.surface,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showGreeting) ...[
                  Text(
                    greeting,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  TypewriterText(
                    text: userName,
                    style: AppTextStyles.h2.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    charDelay: const Duration(milliseconds: 70),
                    startDelay: const Duration(milliseconds: 200),
                    showCursor: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  if (title != null)
                    Text(
                      title!,
                      style: AppTextStyles.h1.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
          if (showGreeting) ...[
            _HeaderIconButton(
              icon: LucideIcons.bell,
              onTap: () => context.push('/notifications'),
              isDark: isDark,
            ),
            const SizedBox(width: AppSpacing.md),
            _HeaderIconButton(
              icon: LucideIcons.settings,
              onTap: () => context.go('/more'),
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusSm,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          padding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}
