import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/repositories/budget_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../data/datasources/local/database_service.dart';

// Events
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class RefreshBudgets extends BudgetEvent {}

class CreateBudget extends BudgetEvent {
  final String categoryId;
  final double amount;
  final BudgetPeriod period;

  const CreateBudget({
    required this.categoryId,
    required this.amount,
    required this.period,
  });

  @override
  List<Object?> get props => [categoryId, amount, period];
}

class UpdateBudget extends BudgetEvent {
  final Budget budget;

  const UpdateBudget(this.budget);

  @override
  List<Object?> get props => [budget];
}

class DeleteBudget extends BudgetEvent {
  final String id;

  const DeleteBudget(this.id);

  @override
  List<Object?> get props => [id];
}

// State
class BudgetState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<Budget> budgets;
  final List<Category> expenseCategories;
  final double totalBudget;
  final double totalSpent;

  const BudgetState({
    this.isLoading = false,
    this.error,
    this.budgets = const [],
    this.expenseCategories = const [],
    this.totalBudget = 0,
    this.totalSpent = 0,
  });

  double get totalRemaining => totalBudget - totalSpent;
  double get overallProgress => totalBudget > 0 ? totalSpent / totalBudget : 0;

  BudgetState copyWith({
    bool? isLoading,
    String? error,
    List<Budget>? budgets,
    List<Category>? expenseCategories,
    double? totalBudget,
    double? totalSpent,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      budgets: budgets ?? this.budgets,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        budgets,
        expenseCategories,
        totalBudget,
        totalSpent,
      ];
}

// BLoC
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;
  final DatabaseService _databaseService;

  BudgetBloc({
    required BudgetRepository budgetRepository,
    required CategoryRepository categoryRepository,
    required DatabaseService databaseService,
  })  : _budgetRepository = budgetRepository,
        _categoryRepository = categoryRepository,
        _databaseService = databaseService,
        super(const BudgetState()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<RefreshBudgets>(_onRefreshBudgets);
    on<CreateBudget>(_onCreateBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRefreshBudgets(
    RefreshBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _loadData(Emitter<BudgetState> emit) async {
    final results = await Future.wait([
      _budgetRepository.getActiveBudgets(),
      _categoryRepository.getCategoriesByType(CategoryType.expense),
      _budgetRepository.getTotalBudgetAmount(),
      _budgetRepository.getTotalSpentAmount(),
    ]);

    final budgets = results[0] as List<Budget>;
    final categories = results[1] as List<Category>;
    final totalBudget = results[2] as double;
    final totalSpent = results[3] as double;

    emit(state.copyWith(
      isLoading: false,
      budgets: budgets,
      expenseCategories: categories,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
    ));
  }

  Future<void> _onCreateBudget(
    CreateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final now = DateTime.now();
      final budget = Budget(
        id: _databaseService.generateId(),
        categoryId: event.categoryId,
        amount: event.amount,
        period: event.period,
        month: now.month,
        year: now.year,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await _budgetRepository.createBudget(budget);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _budgetRepository.updateBudget(event.budget.copyWith(
        updatedAt: DateTime.now(),
      ));
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _budgetRepository.deleteBudget(event.id);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
