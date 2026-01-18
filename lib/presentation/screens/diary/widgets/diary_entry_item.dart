import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/diary_entry.dart';

class DiaryEntryItem extends StatelessWidget {
  final DateTime date;
  final DiaryEntry? entry;
  final DailyCashflow? cashflow;
  final VoidCallback onTap;

  const DiaryEntryItem({
    super.key,
    required this.date,
    this.entry,
    this.cashflow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasEntry = entry != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header with cashflow
            Row(
              children: [
                // Date
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('d MMM').format(date),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      if (entry?.mood != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          entry!.mood!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ],
                  ),
                ),
                // Mini cashflow
                if (cashflow != null) _buildMiniCashflow(isDark),
              ],
            ),
            const SizedBox(height: 12),
            // Content or placeholder
            if (hasEntry) ...[
              if (entry!.title.isNotEmpty)
                Text(
                  entry!.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (entry!.title.isNotEmpty) const SizedBox(height: 4),
              Text(
                entry!.content,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry!.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: entry!.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah catatan',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCashflow(bool isDark) {
    final income = cashflow?.income ?? 0;
    final expense = cashflow?.expense ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (income > 0) ...[
          const Icon(Icons.arrow_downward, size: 12, color: AppColors.income),
          const SizedBox(width: 2),
          Text(
            CurrencyFormatter.formatCompact(income),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.income,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (income > 0 && expense > 0)
          Text(
            '  |  ',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
        if (expense > 0) ...[
          const Icon(Icons.arrow_upward, size: 12, color: AppColors.expense),
          const SizedBox(width: 2),
          Text(
            CurrencyFormatter.formatCompact(expense),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.expense,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
