import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/radius.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/diary_entry.dart';

/// Financial Diary Widget - Figma-style design
class FinancialDiaryWidget extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final List<CategoryCashflow> expenseByCategory;
  final int selectedMonth;
  final int selectedYear;
  final bool isLoading;

  const FinancialDiaryWidget({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
    required this.selectedMonth,
    required this.selectedYear,
    this.isLoading = false,
  });

  double get netCashflow => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    final monthName =
        DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));

    return GestureDetector(
      onTap: () => context.push('/diary'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surfaceDark, AppColors.backgroundDark],
          ),
          borderRadius: AppRadius.radiusLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(90),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: isLoading
            ? _buildLoadingState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(monthName),
                  _buildCashflowSummary(),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    height: 1,
                    color: Colors.white.withAlpha(38),
                  ),
                  _buildDonutChartSection(),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildHeader(String monthName) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(24),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: const Icon(
                  LucideIcons.bookOpen,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Finansial',
                    style: GoogleFonts.spaceMono(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    monthName,
                    style: GoogleFonts.spaceMono(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: AppRadius.radiusFull,
            ),
            child: Row(
              children: [
                Text(
                  'Lihat Detail',
                  style: GoogleFonts.spaceMono(
                    color: Colors.white.withAlpha(230),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  LucideIcons.arrowRight,
                  color: Colors.white.withAlpha(230),
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashflowSummary() {
    final isPositive = netCashflow >= 0;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _CashflowItem(
              icon: LucideIcons.arrowDown,
              label: 'Pemasukan',
              amount: totalIncome,
              iconColor: AppColors.income,
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.white.withAlpha(38),
          ),
          Expanded(
            child: _CashflowItem(
              icon: LucideIcons.arrowUp,
              label: 'Pengeluaran',
              amount: totalExpense,
              iconColor: AppColors.expense,
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.white.withAlpha(38),
          ),
          Expanded(
            child: _CashflowItem(
              icon:
                  isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
              label: 'Selisih',
              amount: netCashflow,
              iconColor: isPositive ? AppColors.income : AppColors.expense,
              showSign: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartSection() {
    final topCategories = expenseByCategory.take(5).toList();

    if (topCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            'Belum ada pengeluaran bulan ini',
            style: GoogleFonts.spaceMono(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: _buildPieSections(topCategories),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.formatCompact(totalExpense),
                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengeluaran per Kategori',
                  style: GoogleFonts.spaceMono(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...topCategories
                    .map((category) => _CategoryLegendItem(category: category)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      List<CategoryCashflow> categories) {
    return categories.asMap().entries.map((entry) {
      final data = entry.value;
      final color = AppColors.fromHex(data.categoryColor);

      return PieChartSectionData(
        color: color,
        value: data.amount,
        title: '',
        radius: 18,
        titleStyle: GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _CashflowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color iconColor;
  final bool showSign;

  const _CashflowItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.iconColor,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayAmount = showSign && amount >= 0
        ? '+${CurrencyFormatter.formatCompact(amount)}'
        : CurrencyFormatter.formatCompact(amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm - 2),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(24),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: AppSpacing.sm - 2),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.xs / 2),
          Text(
            displayAmount,
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryLegendItem extends StatelessWidget {
  final CategoryCashflow category;

  const _CategoryLegendItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.fromHex(category.categoryColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm - 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              category.categoryName,
              style: GoogleFonts.spaceMono(
                color: Colors.white,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${category.percentage.toStringAsFixed(0)}%',
            style: GoogleFonts.spaceMono(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
