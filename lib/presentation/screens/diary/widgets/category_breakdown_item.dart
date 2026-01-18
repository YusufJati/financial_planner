import 'package:flutter/material.dart';
import '../../../../app/themes/colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/diary_entry.dart';
import '../../../widgets/common/common_widgets.dart';

class CategoryBreakdownList extends StatelessWidget {
  final List<CategoryCashflow> categories;
  final bool showExpense;

  const CategoryBreakdownList({
    super.key,
    required this.categories,
    required this.showExpense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            'Belum ada ${showExpense ? 'pengeluaran' : 'pemasukan'}',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Breakdown ${showExpense ? 'Pengeluaran' : 'Pemasukan'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
          ...categories.take(5).map((category) => CategoryBreakdownItem(
                category: category,
                isDark: isDark,
              )),
          if (categories.length > 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '+${categories.length - 5} kategori lainnya',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CategoryBreakdownItem extends StatelessWidget {
  final CategoryCashflow category;
  final bool isDark;

  const CategoryBreakdownItem({
    super.key,
    required this.category,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(category.categoryColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              CategoryIcon(
                icon: category.categoryIcon,
                color: color,
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.categoryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(category.amount),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: category.percentage / 100,
              backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
