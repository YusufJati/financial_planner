import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/account.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/category_repository.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

// State
class HomeState extends Equatable {
  final bool isLoading;
  final String? error;
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<Account> accounts;
  final List<Transaction> recentTransactions;
  final Map<String, double> spendingByCategory;
  final Map<String, String> categoryNames;
  final Map<String, String> categoryColors;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.accounts = const [],
    this.recentTransactions = const [],
    this.spendingByCategory = const {},
    this.categoryNames = const {},
    this.categoryColors = const {},
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    List<Account>? accounts,
    List<Transaction>? recentTransactions,
    Map<String, double>? spendingByCategory,
    Map<String, String>? categoryNames,
    Map<String, String>? categoryColors,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      accounts: accounts ?? this.accounts,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      spendingByCategory: spendingByCategory ?? this.spendingByCategory,
      categoryNames: categoryNames ?? this.categoryNames,
      categoryColors: categoryColors ?? this.categoryColors,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        totalBalance,
        monthlyIncome,
        monthlyExpense,
        accounts,
        recentTransactions,
        spendingByCategory,
        categoryNames,
        categoryColors,
      ];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  HomeBloc({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
  })  : _accountRepository = accountRepository,
        _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    final now = DateTime.now();
    final monthStart = app_date.DateUtils.startOfMonth(now);
    final monthEnd = app_date.DateUtils.endOfMonth(now);

    // Load all data in parallel
    final results = await Future.wait([
      _accountRepository.getAllAccounts(),
      _accountRepository.getTotalBalance(),
      _transactionRepository.getTotalByType(
        TransactionType.income,
        monthStart,
        monthEnd,
      ),
      _transactionRepository.getTotalByType(
        TransactionType.expense,
        monthStart,
        monthEnd,
      ),
      _transactionRepository.getRecentTransactions(5),
      _transactionRepository.getSpendingByCategory(monthStart, monthEnd),
      _categoryRepository.getAllCategories(),
    ]);

    final accounts = results[0] as List<Account>;
    final totalBalance = results[1] as double;
    final monthlyIncome = results[2] as double;
    final monthlyExpense = results[3] as double;
    final recentTransactions = results[4] as List<Transaction>;
    final spendingByCategory = results[5] as Map<String, double>;
    final categories = results[6] as List;

    // Build category lookup maps
    final categoryNames = <String, String>{};
    final categoryColors = <String, String>{};
    for (final cat in categories) {
      categoryNames[cat.id] = cat.name;
      categoryColors[cat.id] = cat.color;
    }

    emit(state.copyWith(
      isLoading: false,
      accounts: accounts,
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      recentTransactions: recentTransactions,
      spendingByCategory: spendingByCategory,
      categoryNames: categoryNames,
      categoryColors: categoryColors,
    ));
  }
}
