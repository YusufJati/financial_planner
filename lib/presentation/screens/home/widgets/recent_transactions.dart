import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/radius.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../widgets/common/common_widgets.dart';

/// Single transaction item for list display
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;

    final color = transaction.category != null
        ? AppColors.fromHex(transaction.category!.color)
        : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            CategoryIcon(
              icon: transaction.category?.icon ?? 'more-horizontal',
              color: color,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category?.name ?? 'Unknown',
                    style: GoogleFonts.spaceMono(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    Text(
                      transaction.note!,
                      style: GoogleFonts.spaceMono(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              '${isExpense ? "-" : isTransfer ? "" : "+"}${CurrencyFormatter.format(transaction.amount)}',
              style: GoogleFonts.spaceMono(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isExpense
                    ? AppColors.expense
                    : isTransfer
                        ? AppColors.transfer
                        : AppColors.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of recent transactions
class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback? onSeeAll;
  final Function(Transaction)? onTransactionTap;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.onSeeAll,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Center(
          child: Text(
            'No transactions yet',
            style: GoogleFonts.spaceMono(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...transactions.map(
            (t) => TransactionItem(
              transaction: t,
              onTap: () => onTransactionTap?.call(t),
            ),
          ),
        ],
      ),
    );
  }
}
