import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/colors.dart';
import '../../../domain/entities/diary_entry.dart';
import '../../blocs/diary/diary_bloc.dart';
import '../../widgets/common/stylish_header.dart';
import '../../widgets/common/common_widgets.dart';
import 'widgets/cashflow_summary_row.dart';
import 'widgets/cashflow_donut_chart.dart';
import 'widgets/category_breakdown_item.dart';
import 'widgets/daily_trend_chart.dart';
import 'widgets/diary_entry_item.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data
    final now = DateTime.now();
    context.read<DiaryBloc>().add(LoadDiaryData(month: now.month, year: now.year));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<DiaryBloc, DiaryState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const StylishHeader(
                title: 'Catatan Finansial',
                subtitle: 'Ringkasan keuangan',
                showBackArrow: true,
              ),
              // Month Selector
              _buildMonthSelector(context, state, isDark),
              // Tab Bar
              _buildTabBar(isDark),
              // Content
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCashflowTab(context, state, isDark),
                          _buildNotesTab(context, state, isDark),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMonthSelector(
      BuildContext context, DiaryState state, bool isDark) {
    final monthName = DateFormat('MMMM yyyy')
        .format(DateTime(state.selectedYear, state.selectedMonth));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _changeMonth(context, state, -1),
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _showMonthPicker(context, state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Text(
                monthName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _changeMonth(context, state, 1),
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        unselectedLabelColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Cashflow'),
          Tab(text: 'Catatan'),
        ],
      ),
    );
  }

  Widget _buildCashflowTab(
      BuildContext context, DiaryState state, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DiaryBloc>().add(
              LoadDiaryData(
                month: state.selectedMonth,
                year: state.selectedYear,
              ),
            );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Row
            CashflowSummaryRow(
              income: state.totalIncome,
              expense: state.totalExpense,
              net: state.netCashflow,
            ),
            const SizedBox(height: 16),
            // Donut Chart
            CashflowDonutChart(
              categoryData: state.currentCategoryData,
              total: state.currentTotal,
              showExpense: state.showExpense,
              onToggle: (showExpense) {
                context.read<DiaryBloc>().add(ToggleCashflowType(showExpense));
              },
            ),
            const SizedBox(height: 16),
            // Category Breakdown
            CategoryBreakdownList(
              categories: state.currentCategoryData,
              showExpense: state.showExpense,
            ),
            const SizedBox(height: 16),
            // Daily Trend
            DailyTrendChart(dailyData: state.dailyCashflows),
            const SizedBox(height: 80), // FAB space
          ],
        ),
      ),
    );
  }

  Widget _buildNotesTab(BuildContext context, DiaryState state, bool isDark) {
    // Get all days in the selected month that have either cashflow or diary
    final daysInMonth =
        DateTime(state.selectedYear, state.selectedMonth + 1, 0).day;
    final days = <DateTime>[];

    for (int i = daysInMonth; i >= 1; i--) {
      days.add(DateTime(state.selectedYear, state.selectedMonth, i));
    }

    // Filter to show only days with activity or recent days
    final activeDays = days.where((date) {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final hasDiary = state.diariesByDate.containsKey(dateKey);
      final cashflow = state.dailyCashflows.firstWhere(
        (c) => c.dateKey == dateKey,
        orElse: () => DailyCashflow(date: DateTime(2000), income: 0, expense: 0),
      );
      final hasCashflow = cashflow.income > 0 || cashflow.expense > 0;

      // Show if has diary, has cashflow, or is today/yesterday
      final now = DateTime.now();
      final isRecent = date.isAfter(now.subtract(const Duration(days: 7)));

      return hasDiary || hasCashflow || isRecent;
    }).toList();

    if (activeDays.isEmpty) {
      return const EmptyState(
        icon: Icons.note_alt_outlined,
        title: 'Belum ada catatan',
        subtitle: 'Ketuk + untuk menambah catatan harian',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DiaryBloc>().add(
              LoadDiaryData(
                month: state.selectedMonth,
                year: state.selectedYear,
              ),
            );
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: activeDays.length,
        itemBuilder: (context, index) {
          final date = activeDays[index];
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final entry = state.diariesByDate[dateKey];
          final cashflow = state.dailyCashflows.firstWhere(
            (c) => c.dateKey == dateKey,
            orElse: () => DailyCashflow(date: date, income: 0, expense: 0),
          );

          return DiaryEntryItem(
            date: date,
            entry: entry,
            cashflow: cashflow,
            onTap: () => _editNote(context, date, entry),
          );
        },
      ),
    );
  }

  void _changeMonth(BuildContext context, DiaryState state, int delta) {
    var newMonth = state.selectedMonth + delta;
    var newYear = state.selectedYear;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    context.read<DiaryBloc>().add(ChangeMonth(month: newMonth, year: newYear));
  }

  void _showMonthPicker(BuildContext context, DiaryState state) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(state.selectedYear, state.selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (selected != null && context.mounted) {
      context
          .read<DiaryBloc>()
          .add(ChangeMonth(month: selected.month, year: selected.year));
    }
  }

  void _addNote(BuildContext context) {
    final today = DateTime.now();
    context.push('/diary/entry', extra: {
      'date': DateTime(today.year, today.month, today.day),
      'entry': null,
    });
  }

  void _editNote(BuildContext context, DateTime date, DiaryEntry? entry) {
    context.push('/diary/entry', extra: {
      'date': date,
      'entry': entry,
    });
  }
}
