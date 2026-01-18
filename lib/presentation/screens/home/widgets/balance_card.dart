import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/radius.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../app/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Monochrome balance card with dot grid texture for the tech aesthetic.
class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusSm,
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusSm,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(
                  color: borderColor.withAlpha(60),
                  spacing: 10,
                  radius: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      'TOTAL BALANCE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.surface,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    CurrencyFormatter.format(totalBalance),
                    style: AppTextStyles.amountLarge.copyWith(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      _buildStat(
                        context,
                        'INCOME',
                        monthlyIncome,
                        LucideIcons.arrowDown,
                        AppColors.income,
                        mutedText,
                      ),
                      const SizedBox(width: AppSpacing.s32),
                      _buildStat(
                        context,
                        'EXPENSE',
                        monthlyExpense,
                        LucideIcons.arrowUp,
                        AppColors.expense,
                        mutedText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color iconColor,
    Color mutedText,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm - 2),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(28),
              borderRadius: AppRadius.radiusSm,
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: mutedText,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double radius;

  _DotGridPainter({
    required this.color,
    this.spacing = 8,
    this.radius = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double y = 0; y <= size.height; y += spacing) {
      for (double x = 0; x <= size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.radius != radius;
  }
}
