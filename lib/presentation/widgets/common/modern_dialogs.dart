import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/text_styles.dart';

/// Modern themed dialog with monochrome styling and subtle animations.
class ModernDialog extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String subtitle;
  final String? description;
  final String cancelText;
  final String confirmText;
  final Color? confirmColor;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final bool isDanger;

  const ModernDialog({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    this.description,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.confirmColor,
    this.onCancel,
    required this.onConfirm,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final iconBg = iconBackgroundColor ??
        (isDanger
            ? AppColors.primary
            : (isDark ? AppColors.borderDark : AppColors.primarySoft));
    final iconFg = iconColor ??
        (ThemeData.estimateBrightnessForColor(iconBg) == Brightness.dark
            ? AppColors.surface
            : textPrimary);
    final confirmBg = confirmColor ?? AppColors.primary;
    final confirmFg =
        ThemeData.estimateBrightnessForColor(confirmBg) == Brightness.dark
            ? AppColors.surface
            : textPrimary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.radiusXxl,
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: border),
                ),
                child: Icon(icon, size: 32, color: iconFg),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
            ),
            if (description != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.backgroundDark : AppColors.background,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isDanger
                          ? LucideIcons.alertTriangle
                          : LucideIcons.info,
                      size: 18,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ??
                        () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: textSecondary,
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusSm,
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmBg,
                      foregroundColor: confirmFg,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusSm,
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: confirmFg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Success dialog with simple monochrome styling.
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final String buttonText;
  final VoidCallback? onPressed;
  final Widget? additionalAction;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.buttonText = 'OK',
    this.onPressed,
    this.additionalAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.radiusXxl,
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: border),
                ),
                child: const Icon(
                  LucideIcons.check,
                  size: 32,
                  color: AppColors.surface,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
            ),
            if (details != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.backgroundDark : AppColors.background,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: border),
                ),
                child: Text(
                  details!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (additionalAction != null) ...[
              additionalAction!,
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ??
                    () => Navigator.of(context, rootNavigator: true).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusSm,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show modern dialogs.
Future<bool?> showModernDialog({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  String? description,
  String cancelText = 'Cancel',
  String confirmText = 'Confirm',
  bool isDanger = false,
}) async {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dialog',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 280),
    useRootNavigator: true,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return ModernDialog(
        icon: icon,
        title: title,
        subtitle: subtitle,
        description: description,
        cancelText: cancelText,
        confirmText: confirmText,
        isDanger: isDanger,
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      );
    },
  );
}

/// Helper function to show success dialogs.
void showSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? details,
  String buttonText = 'OK',
  VoidCallback? onPressed,
  Widget? additionalAction,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dialog',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 280),
    useRootNavigator: true,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return SuccessDialog(
        title: title,
        message: message,
        details: details,
        buttonText: buttonText,
        onPressed: onPressed,
        additionalAction: additionalAction,
      );
    },
  );
}

/// Generic dialog helper with consistent animation and barrier styling.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  Color? barrierColor,
  Duration transitionDuration = const Duration(milliseconds: 260),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dialog',
    barrierColor: barrierColor ?? Colors.black.withOpacity(0.45),
    transitionDuration: transitionDuration,
    useRootNavigator: useRootNavigator,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
  );
}

/// Bottom sheet helper with a subtle content reveal animation.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  ShapeBorder? shape,
}) {
  final theme = Theme.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    shape: shape ?? theme.bottomSheetTheme.shape,
    clipBehavior: Clip.antiAlias,
    builder: (ctx) => _AppSheetAnimation(child: builder(ctx)),
  );
}

class _AppSheetAnimation extends StatelessWidget {
  final Widget child;

  const _AppSheetAnimation({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        final offsetY = 12 * (1 - value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: child,
          ),
        );
      },
    );
  }
}

/// Simple exit app dialog using the modern monochrome style.
Future<bool> showExitAppDialog(BuildContext context) async {
  final result = await showModernDialog(
    context: context,
    icon: LucideIcons.logOut,
    title: 'Keluar Aplikasi?',
    subtitle: 'Apakah Anda yakin ingin keluar dari aplikasi?',
    cancelText: 'Batal',
    confirmText: 'Keluar',
    isDanger: true,
  );
  return result ?? false;
}
