import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../data/datasources/local/database_service.dart';

// Events
abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountEvent {}

class AddAccount extends AccountEvent {
  final String name;
  final AccountType type;
  final double initialBalance;
  final String icon;
  final String color;

  const AddAccount({
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [name, type, initialBalance, icon, color];
}

class UpdateAccount extends AccountEvent {
  final Account account;

  const UpdateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class DeleteAccount extends AccountEvent {
  final String id;

  const DeleteAccount(this.id);

  @override
  List<Object?> get props => [id];
}

// State
class AccountState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final List<Account> accounts;
  final double totalBalance;

  const AccountState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.accounts = const [],
    this.totalBalance = 0,
  });

  AccountState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    List<Account>? accounts,
    double? totalBalance,
  }) {
    return AccountState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      accounts: accounts ?? this.accounts,
      totalBalance: totalBalance ?? this.totalBalance,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        error,
        successMessage,
        accounts,
        totalBalance,
      ];
}

// BLoC
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _accountRepository;
  final DatabaseService _databaseService;

  AccountBloc({
    required AccountRepository accountRepository,
    required DatabaseService databaseService,
  })  : _accountRepository = accountRepository,
        _databaseService = databaseService,
        super(const AccountState()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();

      emit(state.copyWith(
        isLoading: false,
        accounts: accounts,
        totalBalance: totalBalance,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddAccount(
    AddAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));

    try {
      final now = DateTime.now();
      final account = Account(
        id: _databaseService.generateId(),
        name: event.name,
        type: event.type,
        initialBalance: event.initialBalance,
        icon: event.icon,
        color: event.color,
        isActive: true,
        order: state.accounts.length,
        createdAt: now,
        updatedAt: now,
      );

      await _accountRepository.createAccount(account);

      // Reload accounts
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();

      emit(state.copyWith(
        isSaving: false,
        accounts: accounts,
        totalBalance: totalBalance,
        successMessage: 'Account created successfully',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));

    try {
      final updated = event.account.copyWith(
        updatedAt: DateTime.now(),
      );
      await _accountRepository.updateAccount(updated);

      // Reload accounts
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();

      emit(state.copyWith(
        isSaving: false,
        accounts: accounts,
        totalBalance: totalBalance,
        successMessage: 'Account updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));

    try {
      await _accountRepository.deleteAccount(event.id);

      // Reload accounts
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();

      emit(state.copyWith(
        isSaving: false,
        accounts: accounts,
        totalBalance: totalBalance,
        successMessage: 'Account deleted',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }
}
