import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/recurring_transaction.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/recurring_transaction_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../domain/entities/transaction.dart' as trans;
import '../../../data/datasources/local/database_service.dart';

// Events
abstract class RecurringEvent extends Equatable {
  const RecurringEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecurring extends RecurringEvent {}

class CreateRecurring extends RecurringEvent {
  final String name;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final String? toAccountId;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? note;

  const CreateRecurring({
    required this.name,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.note,
  });

  @override
  List<Object?> get props =>
      [name, amount, type, categoryId, accountId, frequency, startDate];
}

class ExecuteRecurring extends RecurringEvent {
  final String id;
  const ExecuteRecurring(this.id);

  @override
  List<Object?> get props => [id];
}

class SkipRecurring extends RecurringEvent {
  final String id;
  const SkipRecurring(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleRecurringStatus extends RecurringEvent {
  final String id;
  const ToggleRecurringStatus(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteRecurring extends RecurringEvent {
  final String id;
  const DeleteRecurring(this.id);

  @override
  List<Object?> get props => [id];
}

// State
class RecurringState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final List<RecurringTransaction> dueToday;
  final List<RecurringTransaction> active;
  final List<RecurringTransaction> paused;
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;
  final List<Account> accounts;

  const RecurringState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.dueToday = const [],
    this.active = const [],
    this.paused = const [],
    this.expenseCategories = const [],
    this.incomeCategories = const [],
    this.accounts = const [],
  });

  RecurringState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    List<RecurringTransaction>? dueToday,
    List<RecurringTransaction>? active,
    List<RecurringTransaction>? paused,
    List<Category>? expenseCategories,
    List<Category>? incomeCategories,
    List<Account>? accounts,
  }) {
    return RecurringState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      dueToday: dueToday ?? this.dueToday,
      active: active ?? this.active,
      paused: paused ?? this.paused,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      accounts: accounts ?? this.accounts,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        successMessage,
        dueToday,
        active,
        paused,
        expenseCategories,
        incomeCategories,
        accounts,
      ];
}

// BLoC
class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final RecurringTransactionRepository _recurringRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;
  final DatabaseService _databaseService;

  RecurringBloc({
    required RecurringTransactionRepository recurringRepository,
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
    required AccountRepository accountRepository,
    required DatabaseService databaseService,
  })  : _recurringRepository = recurringRepository,
        _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        _accountRepository = accountRepository,
        _databaseService = databaseService,
        super(const RecurringState()) {
    on<LoadRecurring>(_onLoadRecurring);
    on<CreateRecurring>(_onCreateRecurring);
    on<ExecuteRecurring>(_onExecuteRecurring);
    on<SkipRecurring>(_onSkipRecurring);
    on<ToggleRecurringStatus>(_onToggleStatus);
    on<DeleteRecurring>(_onDeleteRecurring);
  }

  Future<void> _onLoadRecurring(
    LoadRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final all = await _recurringRepository.getAllRecurring();
      final expenseCategories =
          await _categoryRepository.getCategoriesByType(CategoryType.expense);
      final incomeCategories =
          await _categoryRepository.getCategoriesByType(CategoryType.income);
      final accounts = await _accountRepository.getAllAccounts();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final dueToday = all.where((r) {
        if (!r.isActive) return false;
        final due = DateTime(
            r.nextDueDate.year, r.nextDueDate.month, r.nextDueDate.day);
        return due.isAtSameMomentAs(today) || due.isBefore(today);
      }).toList();

      final active = all.where((r) {
        if (!r.isActive) return false;
        final due = DateTime(
            r.nextDueDate.year, r.nextDueDate.month, r.nextDueDate.day);
        return due.isAfter(today);
      }).toList();

      final paused = all.where((r) => !r.isActive).toList();

      emit(state.copyWith(
        isLoading: false,
        dueToday: dueToday,
        active: active,
        paused: paused,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        accounts: accounts,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateRecurring(
    CreateRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final now = DateTime.now();
      final recurring = RecurringTransaction(
        id: _databaseService.generateId(),
        name: event.name,
        amount: event.amount,
        type: event.type,
        categoryId: event.categoryId,
        accountId: event.accountId,
        toAccountId: event.toAccountId,
        frequency: event.frequency,
        startDate: event.startDate,
        endDate: event.endDate,
        nextDueDate: event.startDate,
        isActive: true,
        note: event.note,
        createdAt: now,
        updatedAt: now,
      );

      await _recurringRepository.createRecurring(recurring);
      emit(state.copyWith(successMessage: 'Recurring transaction created'));
      add(LoadRecurring());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onExecuteRecurring(
    ExecuteRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    try {
      final recurring = await _recurringRepository.getRecurringById(event.id);
      if (recurring == null) return;

      // Create transaction
      final now = DateTime.now();
      final transaction = trans.Transaction(
        id: _databaseService.generateId(),
        accountId: recurring.accountId,
        toAccountId: recurring.toAccountId,
        categoryId: recurring.categoryId,
        amount: recurring.amount,
        type: recurring.type,
        date: now,
        note: '${recurring.name} (Recurring)',
        recurringId: recurring.id,
        createdAt: now,
        updatedAt: now,
      );
      await _transactionRepository.createTransaction(transaction);

      // Update next due date
      final updated = recurring.copyWith(
        nextDueDate: recurring.calculateNextDueDate(),
        updatedAt: DateTime.now(),
      );
      await _recurringRepository.updateRecurring(updated);

      emit(state.copyWith(successMessage: 'Transaction recorded'));
      add(LoadRecurring());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSkipRecurring(
    SkipRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    try {
      final recurring = await _recurringRepository.getRecurringById(event.id);
      if (recurring == null) return;

      final updated = recurring.copyWith(
        nextDueDate: recurring.calculateNextDueDate(),
        updatedAt: DateTime.now(),
      );
      await _recurringRepository.updateRecurring(updated);

      emit(state.copyWith(successMessage: 'Skipped to next occurrence'));
      add(LoadRecurring());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onToggleStatus(
    ToggleRecurringStatus event,
    Emitter<RecurringState> emit,
  ) async {
    try {
      final recurring = await _recurringRepository.getRecurringById(event.id);
      if (recurring == null) return;

      final updated = recurring.copyWith(
        isActive: !recurring.isActive,
        updatedAt: DateTime.now(),
      );
      await _recurringRepository.updateRecurring(updated);

      final message = updated.isActive ? 'Activated' : 'Paused';
      emit(state.copyWith(successMessage: message));
      add(LoadRecurring());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteRecurring(
    DeleteRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    try {
      await _recurringRepository.deleteRecurring(event.id);
      emit(state.copyWith(successMessage: 'Deleted'));
      add(LoadRecurring());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
