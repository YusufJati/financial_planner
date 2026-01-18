import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/report/report_bloc.dart';
import '../../widgets/common/stylish_header.dart';
import '../../widgets/common/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load initial data
    context.read<ReportBloc>().add(const LoadReport(period: ReportPeriod.month));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Auto-refresh when app resumes
      final currentPeriod = context.read<ReportBloc>().state.period;
      context.read<ReportBloc>().add(LoadReport(period: currentPeriod));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const StylishHeader(
            title: 'Financial Reports',
            subtitle: 'Analyze your stats',
            showBackArrow: true,
          ),
          Expanded(
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state.isLoading && state.dailyData.isEmpty) {
                  return const ShimmerScreen(cardCount: 2, listItemCount: 3);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ReportBloc>()
                        .add(LoadReport(period: state.period));
                  },
                  child: ListView(
                    children: [
                      // Period Filter
                      _PeriodFilter(
                        selectedPeriod: state.period,
                        onChanged: (period) {
                          context.read<ReportBloc>().add(ChangePeriod(period));
                        },
                      ),

                      // Summary Cards
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                title: 'Income',
                                amount: state.totalIncome,
                                icon: Icons.arrow_downward_rounded,
                                color: AppColors.income,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Expense',
                                amount: state.totalExpense,
                                icon: Icons.arrow_upward_rounded,
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Net Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _NetCard(
                          netAmount: state.netAmount,
                          income: state.totalIncome,
                          expense: state.totalExpense,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Line Chart Section
                      if (state.dailyData.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Daily Trend',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _LineChartCard(
                            dailyData: state.dailyData,
                            period: state.period,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Pie Chart Section
                      if (state.categorySpending.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Expense by Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child:
                              _PieChartCard(spending: state.categorySpending),
                        ),

                        const SizedBox(height: 24),

                        // Category Breakdown
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Category Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...state.categorySpending.map((category) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: _CategoryBreakdownItem(category: category),
                            )),
                      ],

                      if (state.categorySpending.isEmpty &&
                          state.dailyData.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: EmptyState(
                            icon: Icons.bar_chart_outlined,
                            title: 'No data yet',
                            subtitle: 'Add some transactions to see reports',
                          ),
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final ValueChanged<ReportPeriod> onChanged;

  const _PeriodFilter({
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ReportPeriod.values.map((period) {
          final isSelected = selectedPeriod == period;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: period != ReportPeriod.year ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  period.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetCard extends StatelessWidget {
  final double netAmount;
  final double income;
  final double expense;

  const _NetCard({
    required this.netAmount,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = netAmount >= 0;
    final color = isPositive ? AppColors.income : AppColors.expense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPositive ? 'Net Savings' : 'Net Loss',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(netAmount.abs()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  final List<DailyData> dailyData;
  final ReportPeriod period;

  const _LineChartCard({
    required this.dailyData,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get max value for Y axis
    double maxY = 0;
    for (final data in dailyData) {
      if (data.income > maxY) maxY = data.income;
      if (data.expense > maxY) maxY = data.expense;
    }
    maxY = maxY > 0 ? maxY * 1.2 : 1000000;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getInterval(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dailyData.length) {
                    final label = _getAxisLabel(dailyData[index].date);

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: period == ReportPeriod.year ? -0.5 : 0,
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontSize: period == ReportPeriod.year ? 9 : 10,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (dailyData.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            // Income line
            LineChartBarData(
              spots: dailyData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.income);
              }).toList(),
              isCurved: true,
              color: AppColors.income,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.income.withOpacity(0.1),
              ),
            ),
            // Expense line
            LineChartBarData(
              spots: dailyData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.expense);
              }).toList(),
              isCurved: true,
              color: AppColors.expense,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.expense.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAxisLabel(DateTime date) {
    switch (period) {
      case ReportPeriod.week:
        // Show weekday abbreviation (Mon, Tue, etc)
        return DateFormat('E').format(date);
      case ReportPeriod.month:
        // Show day number (1, 2, 3, etc)
        return DateFormat('d').format(date);
      case ReportPeriod.year:
        // Show month abbreviation (Jan, Feb, Mar, etc)
        return DateFormat('MMM').format(date);
    }
  }

  double _getInterval() {
    switch (period) {
      case ReportPeriod.week:
        return 1; // Show all days in a week
      case ReportPeriod.month:
        return dailyData.length > 15 ? 7 : 3; // Show every 3-7 days
      case ReportPeriod.year:
        // Calculate interval to show approximately monthly
        final daysInYear = dailyData.length;
        return (daysInYear / 12)
            .roundToDouble()
            .clamp(1, daysInYear.toDouble());
    }
  }
}

class _PieChartCard extends StatelessWidget {
  final List<CategorySpending> spending;

  const _PieChartCard({required this.spending});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            child: SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: spending.take(5).map((cat) {
                    final color = AppColors.fromHex(cat.categoryColor);
                    return PieChartSectionData(
                      color: color,
                      value: cat.amount,
                      title: '',
                      radius: 30,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: spending.take(5).map((cat) {
                final color = AppColors.fromHex(cat.categoryColor);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.categoryName,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(cat.percentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownItem extends StatelessWidget {
  final CategorySpending category;

  const _CategoryBreakdownItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.fromHex(category.categoryColor);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(category.categoryIcon),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: category.percentage,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCompact(category.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(category.percentage * 100).toInt()}%',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    final iconMap = {
      'utensils': Icons.restaurant,
      'car': Icons.directions_car,
      'shopping-bag': Icons.shopping_bag,
      'file-text': Icons.receipt,
      'heart-pulse': Icons.medical_services,
      'gamepad-2': Icons.sports_esports,
      'graduation-cap': Icons.school,
      'more-horizontal': Icons.more_horiz,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
