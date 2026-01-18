import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/diary_entry.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/diary_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../data/datasources/local/database_service.dart';

// Events
abstract class DiaryEvent extends Equatable {
  const DiaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadDiaryData extends DiaryEvent {
  final int month;
  final int year;

  const LoadDiaryData({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class ChangeMonth extends DiaryEvent {
  final int month;
  final int year;

  const ChangeMonth({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class CreateDiaryEntry extends DiaryEvent {
  final DateTime date;
  final String title;
  final String content;
  final String? mood;
  final List<String>? tags;

  const CreateDiaryEntry({
    required this.date,
    required this.title,
    required this.content,
    this.mood,
    this.tags,
  });

  @override
  List<Object?> get props => [date, title, content, mood, tags];
}

class UpdateDiaryEntry extends DiaryEvent {
  final DiaryEntry entry;

  const UpdateDiaryEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DeleteDiaryEntry extends DiaryEvent {
  final String id;

  const DeleteDiaryEntry(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleCashflowType extends DiaryEvent {
  final bool showExpense;

  const ToggleCashflowType(this.showExpense);

  @override
  List<Object?> get props => [showExpense];
}

// State
class DiaryState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  // Period
  final int selectedMonth;
  final int selectedYear;

  // Diary entries
  final List<DiaryEntry> diaries;
  final Map<String, DiaryEntry> diariesByDate;

  // Cashflow data
  final double totalIncome;
  final double totalExpense;
  final List<DailyCashflow> dailyCashflows;
  final List<CategoryCashflow> expenseByCategory;
  final List<CategoryCashflow> incomeByCategory;

  // UI state
  final bool showExpense;

  const DiaryState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.selectedMonth = 1,
    this.selectedYear = 2026,
    this.diaries = const [],
    this.diariesByDate = const {},
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.dailyCashflows = const [],
    this.expenseByCategory = const [],
    this.incomeByCategory = const [],
    this.showExpense = true,
  });

  double get netCashflow => totalIncome - totalExpense;

  List<CategoryCashflow> get currentCategoryData =>
      showExpense ? expenseByCategory : incomeByCategory;

  double get currentTotal => showExpense ? totalExpense : totalIncome;

  DiaryState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    int? selectedMonth,
    int? selectedYear,
    List<DiaryEntry>? diaries,
    Map<String, DiaryEntry>? diariesByDate,
    double? totalIncome,
    double? totalExpense,
    List<DailyCashflow>? dailyCashflows,
    List<CategoryCashflow>? expenseByCategory,
    List<CategoryCashflow>? incomeByCategory,
    bool? showExpense,
  }) {
    return DiaryState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      diaries: diaries ?? this.diaries,
      diariesByDate: diariesByDate ?? this.diariesByDate,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      dailyCashflows: dailyCashflows ?? this.dailyCashflows,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      incomeByCategory: incomeByCategory ?? this.incomeByCategory,
      showExpense: showExpense ?? this.showExpense,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        error,
        successMessage,
        selectedMonth,
        selectedYear,
        diaries,
        diariesByDate,
        totalIncome,
        totalExpense,
        dailyCashflows,
        expenseByCategory,
        incomeByCategory,
        showExpense,
      ];
}

// BLoC
class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final DiaryRepository _diaryRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final DatabaseService _databaseService;

  DiaryBloc({
    required DiaryRepository diaryRepository,
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
    required DatabaseService databaseService,
  })  : _diaryRepository = diaryRepository,
        _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        _databaseService = databaseService,
        super(DiaryState(
          selectedMonth: DateTime.now().month,
          selectedYear: DateTime.now().year,
        )) {
    on<LoadDiaryData>(_onLoadDiaryData);
    on<ChangeMonth>(_onChangeMonth);
    on<CreateDiaryEntry>(_onCreateDiaryEntry);
    on<UpdateDiaryEntry>(_onUpdateDiaryEntry);
    on<DeleteDiaryEntry>(_onDeleteDiaryEntry);
    on<ToggleCashflowType>(_onToggleCashflowType);
  }

  Future<void> _onLoadDiaryData(
    LoadDiaryData event,
    Emitter<DiaryState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      selectedMonth: event.month,
      selectedYear: event.year,
    ));

    try {
      await _loadData(emit, event.month, event.year);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<DiaryState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      selectedMonth: event.month,
      selectedYear: event.year,
    ));

    try {
      await _loadData(emit, event.month, event.year);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateDiaryEntry(
    CreateDiaryEntry event,
    Emitter<DiaryState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));

    try {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: _databaseService.generateId(),
        date: DateTime(event.date.year, event.date.month, event.date.day),
        title: event.title,
        content: event.content,
        mood: event.mood,
        tags: event.tags ?? [],
        createdAt: now,
        updatedAt: now,
      );

      await _diaryRepository.createDiary(entry);

      // Reload data
      await _loadData(emit, state.selectedMonth, state.selectedYear);

      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Catatan berhasil disimpan',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateDiaryEntry(
    UpdateDiaryEntry event,
    Emitter<DiaryState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));

    try {
      final updated = event.entry.copyWith(updatedAt: DateTime.now());
      await _diaryRepository.updateDiary(updated);

      // Reload data
      await _loadData(emit, state.selectedMonth, state.selectedYear);

      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Catatan berhasil diperbarui',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteDiaryEntry(
    DeleteDiaryEntry event,
    Emitter<DiaryState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));

    try {
      await _diaryRepository.deleteDiary(event.id);

      // Reload data
      await _loadData(emit, state.selectedMonth, state.selectedYear);

      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Catatan berhasil dihapus',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  void _onToggleCashflowType(
    ToggleCashflowType event,
    Emitter<DiaryState> emit,
  ) {
    emit(state.copyWith(showExpense: event.showExpense));
  }

  Future<void> _loadData(
    Emitter<DiaryState> emit,
    int month,
    int year,
  ) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    // Load data in parallel
    final results = await Future.wait([
      _diaryRepository.getDiariesByDateRange(start, end),
      _transactionRepository.getTotalByType(TransactionType.income, start, end),
      _transactionRepository.getTotalByType(
          TransactionType.expense, start, end),
      _transactionRepository.getTransactionsByDateRange(start, end),
      _transactionRepository.getSpendingByCategory(start, end),
      _categoryRepository.getAllCategories(),
    ]);

    final diaries = results[0] as List<DiaryEntry>;
    final totalIncome = results[1] as double;
    final totalExpense = results[2] as double;
    final transactions = results[3] as List<Transaction>;
    final spendingMap = results[4] as Map<String, double>;
    final categories = results[5] as List;

    // Build diaries by date map
    final diariesByDate = <String, DiaryEntry>{};
    for (final diary in diaries) {
      diariesByDate[diary.dateKey] = diary;
    }

    // Build daily cashflow
    final dailyCashflows = _buildDailyCashflows(transactions, start, end);

    // Build expense by category
    final expenseByCategory = _buildCategoryBreakdown(
      spendingMap,
      categories,
      totalExpense,
      CategoryType.expense,
    );

    // Build income by category
    final incomeByCategory = _buildIncomeCategoryBreakdown(
      transactions,
      categories,
      totalIncome,
    );

    emit(state.copyWith(
      isLoading: false,
      diaries: diaries,
      diariesByDate: diariesByDate,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      dailyCashflows: dailyCashflows,
      expenseByCategory: expenseByCategory,
      incomeByCategory: incomeByCategory,
    ));
  }

  List<DailyCashflow> _buildDailyCashflows(
    List<Transaction> transactions,
    DateTime start,
    DateTime end,
  ) {
    final Map<String, DailyCashflow> dataMap = {};

    // Initialize all days in the month
    var current = start;
    while (!current.isAfter(end)) {
      final key =
          '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      dataMap[key] = DailyCashflow(
        date: current,
        income: 0,
        expense: 0,
      );
      current = current.add(const Duration(days: 1));
    }

    // Aggregate transactions
    for (final t in transactions) {
      final key =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      if (dataMap.containsKey(key)) {
        final existing = dataMap[key]!;
        if (t.type == TransactionType.income) {
          dataMap[key] = DailyCashflow(
            date: existing.date,
            income: existing.income + t.amount,
            expense: existing.expense,
          );
        } else if (t.type == TransactionType.expense) {
          dataMap[key] = DailyCashflow(
            date: existing.date,
            income: existing.income,
            expense: existing.expense + t.amount,
          );
        }
      }
    }

    return dataMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CategoryCashflow> _buildCategoryBreakdown(
    Map<String, double> spendingMap,
    List categories,
    double total,
    CategoryType type,
  ) {
    final result = <CategoryCashflow>[];

    for (final entry in spendingMap.entries) {
      try {
        final category = categories.firstWhere(
          (c) => c.id == entry.key,
        );

        result.add(CategoryCashflow(
          categoryId: entry.key,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryColor: category.color,
          amount: entry.value,
          percentage: total > 0 ? (entry.value / total) * 100 : 0,
        ));
      } catch (_) {
        // Category not found, skip this entry
      }
    }

    // Sort by amount descending
    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  List<CategoryCashflow> _buildIncomeCategoryBreakdown(
    List<Transaction> transactions,
    List categories,
    double totalIncome,
  ) {
    final incomeMap = <String, double>{};

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        incomeMap[t.categoryId] = (incomeMap[t.categoryId] ?? 0) + t.amount;
      }
    }

    final result = <CategoryCashflow>[];

    for (final entry in incomeMap.entries) {
      try {
        final category = categories.firstWhere(
          (c) => c.id == entry.key,
        );

        result.add(CategoryCashflow(
          categoryId: entry.key,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryColor: category.color,
          amount: entry.value,
          percentage: totalIncome > 0 ? (entry.value / totalIncome) * 100 : 0,
        ));
      } catch (_) {
        // Category not found, skip this entry
      }
    }

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }
}
