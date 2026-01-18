import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/radius.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/utils/currency_formatter.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> spendingByCategory;
  final Map<String, String> categoryNames;
  final Map<String, String> categoryColors;

  const ExpensePieChart({
    super.key,
    required this.spendingByCategory,
    required this.categoryNames,
    required this.categoryColors,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.spendingByCategory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.radiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'No expenses this month',
              style: GoogleFonts.spaceMono(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final total = widget.spendingByCategory.values.fold(0.0, (a, b) => a + b);
    final sortedEntries = widget.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
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
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                sections: _buildSections(sortedEntries, total),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildLegend(sortedEntries, total),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    List<MapEntry<String, double>> entries,
    double total,
  ) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryId = entry.value.key;
      final amount = entry.value.value;
      final percentage = (amount / total) * 100;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 55.0 : 45.0;

      final colorHex = widget.categoryColors[categoryId] ?? '#6B7280';
      final color = AppColors.fromHex(colorHex);

      return PieChartSectionData(
        color: color,
        value: amount,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: GoogleFonts.spaceMono(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(
    List<MapEntry<String, double>> entries,
    double total,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topEntries = entries.take(5);

    return Column(
      children: topEntries.map((entry) {
        final categoryId = entry.key;
        final amount = entry.value;
        final percentage = (amount / total) * 100;
        final name = widget.categoryNames[categoryId] ?? 'Unknown';
        final colorHex = widget.categoryColors[categoryId] ?? '#6B7280';
        final color = AppColors.fromHex(colorHex);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                CurrencyFormatter.formatCompact(amount),
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
