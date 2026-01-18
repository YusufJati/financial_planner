import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../data/datasources/local/database_service.dart';

// Events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final String? accountId;

  const LoadTransactions({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.accountId,
  });

  @override
  List<Object?> get props => [startDate, endDate, categoryId, accountId];
}

class LoadFormData extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionType type;
  final double amount;
  final String categoryId;
  final String accountId;
  final String? toAccountId;
  final DateTime date;
  final String? note;

  const AddTransaction({
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [type, amount, categoryId, accountId, toAccountId, date, note];
}

class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

// State
class TransactionState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final List<Transaction> transactions;
  final List<Category> categories;
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;
  final List<Account> accounts;
  final Map<String, List<Transaction>> groupedTransactions;

  const TransactionState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.transactions = const [],
    this.categories = const [],
    this.expenseCategories = const [],
    this.incomeCategories = const [],
    this.accounts = const [],
    this.groupedTransactions = const {},
  });

  TransactionState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    List<Transaction>? transactions,
    List<Category>? categories,
    List<Category>? expenseCategories,
    List<Category>? incomeCategories,
    List<Account>? accounts,
    Map<String, List<Transaction>>? groupedTransactions,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      accounts: accounts ?? this.accounts,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        error,
        successMessage,
        transactions,
        categories,
        expenseCategories,
        incomeCategories,
        accounts,
        groupedTransactions,
      ];
}

// BLoC
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;
  final DatabaseService _databaseService;

  TransactionBloc({
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
    required AccountRepository accountRepository,
    required DatabaseService databaseService,
  })  : _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        _accountRepository = accountRepository,
        _databaseService = databaseService,
        super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadFormData>(_onLoadFormData);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      List<Transaction> transactions;

      if (event.startDate != null && event.endDate != null) {
        transactions = await _transactionRepository.getTransactionsByDateRange(
          event.startDate!,
          event.endDate!,
        );
      } else if (event.accountId != null) {
        transactions = await _transactionRepository.getTransactionsByAccount(
          event.accountId!,
        );
      } else if (event.categoryId != null) {
        transactions = await _transactionRepository.getTransactionsByCategory(
          event.categoryId!,
        );
      } else {
        transactions = await _transactionRepository.getAllTransactions();
      }

      // Group transactions by date
      final grouped = _groupTransactionsByDate(transactions);

      emit(state.copyWith(
        isLoading: false,
        transactions: transactions,
        groupedTransactions: grouped,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadFormData(
    LoadFormData event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await Future.wait([
        _categoryRepository.getAllCategories(),
        _categoryRepository.getCategoriesByType(CategoryType.expense),
        _categoryRepository.getCategoriesByType(CategoryType.income),
        _accountRepository.getAllAccounts(),
      ]);

      emit(state.copyWith(
        isLoading: false,
        categories: results[0] as List<Category>,
        expenseCategories: results[1] as List<Category>,
        incomeCategories: results[2] as List<Category>,
        accounts: results[3] as List<Account>,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));

    try {
      final now = DateTime.now();
      final id = _databaseService.generateId();

      if (event.type == TransactionType.transfer && event.toAccountId != null) {
        // Create transfer (2 linked transactions)
        final transferId = _databaseService.generateId();
        
        // Find transfer category
        final categories = await _categoryRepository.getAllCategories();
        final transferCategory = categories.firstWhere(
          (c) => c.name == 'Transfer',
          orElse: () => categories.first,
        );

        final fromTransaction = Transaction(
          id: id,
          accountId: event.accountId,
          toAccountId: event.toAccountId,
          categoryId: transferCategory.id,
          amount: event.amount,
          type: TransactionType.transfer,
          date: event.date,
          note: event.note,
          transferId: transferId,
          createdAt: now,
          updatedAt: now,
        );

        final toTransaction = Transaction(
          id: _databaseService.generateId(),
          accountId: event.toAccountId!,
          toAccountId: event.accountId,
          categoryId: transferCategory.id,
          amount: event.amount,
          type: TransactionType.transfer,
          date: event.date,
          note: event.note,
          transferId: transferId,
          createdAt: now,
          updatedAt: now,
        );

        await _transactionRepository.createTransfer(fromTransaction, toTransaction);
      } else {
        final transaction = Transaction(
          id: id,
          accountId: event.accountId,
          categoryId: event.categoryId,
          amount: event.amount,
          type: event.type,
          date: event.date,
          note: event.note,
          createdAt: now,
          updatedAt: now,
        );

        await _transactionRepository.createTransaction(transaction);
      }

      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Transaction added successfully',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null));

    try {
      final updated = event.transaction.copyWith(
        updatedAt: DateTime.now(),
      );
      await _transactionRepository.updateTransaction(updated);

      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Transaction updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null));

    try {
      await _transactionRepository.deleteTransaction(event.id);

      final updatedTransactions = state.transactions
          .where((t) => t.id != event.id)
          .toList();
      final grouped = _groupTransactionsByDate(updatedTransactions);

      emit(state.copyWith(
        isSaving: false,
        transactions: updatedTransactions,
        groupedTransactions: grouped,
        successMessage: 'Transaction deleted',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> grouped = {};
    
    for (final transaction in transactions) {
      final dateKey = _getDateKey(transaction.date);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transDate = DateTime(date.year, date.month, date.day);

    if (transDate == today) {
      return 'Today';
    } else if (transDate == yesterday) {
      return 'Yesterday';
    } else if (transDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return 'This Week';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
