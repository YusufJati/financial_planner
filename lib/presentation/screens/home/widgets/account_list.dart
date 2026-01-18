import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/radius.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../app/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/account.dart';
import '../../../widgets/common/common_widgets.dart';

/// Horizontal scrollable account list for home screen
class AccountListHorizontal extends StatelessWidget {
  final List<Account> accounts;
  final VoidCallback? onAddAccount;
  final Function(Account)? onAccountTap;

  const AccountListHorizontal({
    super.key,
    required this.accounts,
    this.onAddAccount,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: accounts.length + 1,
        itemBuilder: (context, index) {
          if (index == accounts.length) {
            return _buildAddButton();
          }
          return _buildAccountCard(context, accounts[index]);
        },
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
    final color = AppColors.toMonochrome(AppColors.fromHex(account.color));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMd,
          side: BorderSide(color: borderColor),
        ),
        elevation: 0,
        child: InkWell(
          onTap: () => onAccountTap?.call(account),
          borderRadius: AppRadius.radiusMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryIcon(
                  icon: account.icon,
                  color: color,
                  size: 36,
                ),
                const Spacer(),
                Text(
                  account.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  CurrencyFormatter.formatCompact(account.currentBalance),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: account.currentBalance >= 0
                        ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)
                        : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Material(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.radiusMd,
        child: InkWell(
          onTap: onAddAccount,
          borderRadius: AppRadius.radiusMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.plus,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
