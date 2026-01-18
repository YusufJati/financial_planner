import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/category_repository.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadReport extends ReportEvent {
  final ReportPeriod period;

  const LoadReport({this.period = ReportPeriod.month});

  @override
  List<Object?> get props => [period];
}

class ChangePeriod extends ReportEvent {
  final ReportPeriod period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

// Period enum
enum ReportPeriod {
  week,
  month,
  year;

  String get displayName {
    switch (this) {
      case ReportPeriod.week:
        return 'This Week';
      case ReportPeriod.month:
        return 'This Month';
      case ReportPeriod.year:
        return 'This Year';
    }
  }
}

// Data classes
class DailyData {
  final DateTime date;
  final double income;
  final double expense;

  const DailyData({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class CategorySpending {
  final String categoryId;
  final String categoryName;
  final String categoryColor;
  final String categoryIcon;
  final double amount;
  final double percentage;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.amount,
    required this.percentage,
  });
}

// State
class ReportState extends Equatable {
  final bool isLoading;
  final String? error;
  final ReportPeriod period;
  final double totalIncome;
  final double totalExpense;
  final List<DailyData> dailyData;
  final List<CategorySpending> categorySpending;

  const ReportState({
    this.isLoading = false,
    this.error,
    this.period = ReportPeriod.month,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.dailyData = const [],
    this.categorySpending = const [],
  });

  double get netAmount => totalIncome - totalExpense;

  ReportState copyWith({
    bool? isLoading,
    String? error,
    ReportPeriod? period,
    double? totalIncome,
    double? totalExpense,
    List<DailyData>? dailyData,
    List<CategorySpending>? categorySpending,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      period: period ?? this.period,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      dailyData: dailyData ?? this.dailyData,
      categorySpending: categorySpending ?? this.categorySpending,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        period,
        totalIncome,
        totalExpense,
        dailyData,
        categorySpending,
      ];
}

// BLoC
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  ReportBloc({
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
  })  : _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        super(const ReportState()) {
    on<LoadReport>(_onLoadReport);
    on<ChangePeriod>(_onChangePeriod);
  }

  Future<void> _onLoadReport(
    LoadReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, period: event.period));

    try {
      await _loadData(emit, event.period);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, period: event.period));

    try {
      await _loadData(emit, event.period);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _loadData(
    Emitter<ReportState> emit,
    ReportPeriod period,
  ) async {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;

    switch (period) {
      case ReportPeriod.week:
        final weekday = now.weekday;
        start = DateTime(now.year, now.month, now.day - weekday + 1);
        end = start.add(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
        break;
      case ReportPeriod.year:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year + 1, 1, 1);
        break;
    }

    // Load data
    final results = await Future.wait([
      _transactionRepository.getTotalByType(TransactionType.income, start, end),
      _transactionRepository.getTotalByType(
          TransactionType.expense, start, end),
      _transactionRepository.getTransactionsByDateRange(start, end),
      _transactionRepository.getSpendingByCategory(start, end),
      _categoryRepository.getAllCategories(),
    ]);

    final totalIncome = results[0] as double;
    final totalExpense = results[1] as double;
    final transactions = results[2] as List<Transaction>;
    final spendingMap = results[3] as Map<String, double>;
    final categories = results[4] as List;

    // Build daily data
    final dailyData = _buildDailyData(transactions, start, end, period);

    // Build category spending
    final categorySpending =
        _buildCategorySpending(spendingMap, categories, totalExpense);

    emit(state.copyWith(
      isLoading: false,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      dailyData: dailyData,
      categorySpending: categorySpending,
    ));
  }

  List<DailyData> _buildDailyData(
    List<Transaction> transactions,
    DateTime start,
    DateTime end,
    ReportPeriod period,
  ) {
    final Map<String, DailyData> dataMap = {};

    // Initialize all days
    var current = start;
    while (current.isBefore(end)) {
      final key = '${current.year}-${current.month}-${current.day}';
      dataMap[key] = DailyData(
        date: current,
        income: 0,
        expense: 0,
      );
      current = current.add(const Duration(days: 1));
    }

    // Aggregate transactions
    for (final t in transactions) {
      final key = '${t.date.year}-${t.date.month}-${t.date.day}';
      if (dataMap.containsKey(key)) {
        final existing = dataMap[key]!;
        if (t.type == TransactionType.income) {
          dataMap[key] = DailyData(
            date: existing.date,
            income: existing.income + t.amount,
            expense: existing.expense,
          );
        } else if (t.type == TransactionType.expense) {
          dataMap[key] = DailyData(
            date: existing.date,
            income: existing.income,
            expense: existing.expense + t.amount,
          );
        }
      }
    }

    return dataMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CategorySpending> _buildCategorySpending(
    Map<String, double> spendingMap,
    List categories,
    double totalExpense,
  ) {
    final result = <CategorySpending>[];

    for (final entry in spendingMap.entries) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => null,
      );

      if (category != null) {
        result.add(CategorySpending(
          categoryId: entry.key,
          categoryName: category.name,
          categoryColor: category.color,
          categoryIcon: category.icon,
          amount: entry.value,
          percentage: totalExpense > 0 ? entry.value / totalExpense : 0,
        ));
      }
    }

    // Sort by amount descending
    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }
}
