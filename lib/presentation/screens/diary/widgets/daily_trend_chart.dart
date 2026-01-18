import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/themes/colors.dart';
import '../../../../domain/entities/diary_entry.dart';

class DailyTrendChart extends StatelessWidget {
  final List<DailyCashflow> dailyData;

  const DailyTrendChart({
    super.key,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          Text(
            'Trend Harian',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendItem(
                color: AppColors.income,
                label: 'Pemasukan',
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: AppColors.expense,
                label: 'Pengeluaran',
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: dailyData.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getInterval(),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: _getXInterval(),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= dailyData.length) {
                                return const SizedBox();
                              }
                              final date = dailyData[index].date;
                              return Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        _buildLineData(
                          dailyData.map((d) => d.income).toList(),
                          AppColors.income,
                        ),
                        _buildLineData(
                          dailyData.map((d) => d.expense).toList(),
                          AppColors.expense,
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final isIncome = spot.barIndex == 0;
                              return LineTooltipItem(
                                '${isIncome ? 'In' : 'Out'}: ${_formatCompact(spot.y)}',
                                TextStyle(
                                  color: spot.bar.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _getInterval() {
    final maxIncome = dailyData.isEmpty
        ? 0.0
        : dailyData.map((d) => d.income).reduce((a, b) => a > b ? a : b);
    final maxExpense = dailyData.isEmpty
        ? 0.0
        : dailyData.map((d) => d.expense).reduce((a, b) => a > b ? a : b);
    final max = maxIncome > maxExpense ? maxIncome : maxExpense;
    if (max <= 0) return 1;
    return max / 3;
  }

  double _getXInterval() {
    if (dailyData.length <= 7) return 1;
    if (dailyData.length <= 15) return 2;
    return 5;
  }

  LineChartBarData _buildLineData(List<double> values, Color color) {
    return LineChartBarData(
      spots: values.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value);
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withAlpha(26),
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
