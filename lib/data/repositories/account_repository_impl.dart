import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/account_repository.dart';
import '../datasources/local/database_service.dart';
import '../models/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final DatabaseService _db;

  AccountRepositoryImpl(this._db);

  @override
  Future<List<Account>> getAllAccounts() async {
    final box = _db.accountBox;
    final models = box.values.where((a) => a.isActive).toList();
    models.sort((a, b) => a.order.compareTo(b.order));

    final accounts = <Account>[];
    for (final model in models) {
      final balance = await getAccountBalance(model.id);
      accounts.add(_toEntity(model, balance));
    }
    return accounts;
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final model = _db.accountBox.get(id);
    if (model == null) return null;
    final balance = await getAccountBalance(id);
    return _toEntity(model, balance);
  }

  @override
  Future<void> createAccount(Account account) async {
    final model = _toModel(account);
    await _db.accountBox.put(model.id, model);
  }

  @override
  Future<void> updateAccount(Account account) async {
    final model = _toModel(account);
    await _db.accountBox.put(model.id, model);
  }

  @override
  Future<void> deleteAccount(String id) async {
    final model = _db.accountBox.get(id);
    if (model != null) {
      model.isActive = false;
      model.updatedAt = DateTime.now();
      await model.save();
    }
  }

  @override
  Future<double> getAccountBalance(String accountId) async {
    final account = _db.accountBox.get(accountId);
    if (account == null) return 0;

    double balance = account.initialBalance;

    final transactionBox = _db.transactionBox;
    final transactions = transactionBox.values
        .where((t) => t.accountId == accountId || t.toAccountId == accountId);

    for (final t in transactions) {
      final type = TransactionType.values[t.typeIndex];

      if (t.accountId == accountId) {
        if (type == TransactionType.income) {
          balance += t.amount;
        } else if (type == TransactionType.expense) {
          balance -= t.amount;
        } else if (type == TransactionType.transfer) {
          balance -= t.amount;
        }
      } else if (t.toAccountId == accountId) {
        balance += t.amount;
      }
    }

    return balance;
  }

  @override
  Future<double> getTotalBalance() async {
    double total = 0;
    final accounts = await getAllAccounts();
    for (final account in accounts) {
      total += account.currentBalance;
    }
    return total;
  }

  Account _toEntity(AccountModel model, double balance) {
    return Account(
      id: model.id,
      name: model.name,
      type: AccountType.values[model.typeIndex],
      initialBalance: model.initialBalance,
      icon: model.icon,
      color: model.color,
      isActive: model.isActive,
      order: model.order,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      currentBalance: balance,
    );
  }

  AccountModel _toModel(Account entity) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      typeIndex: entity.type.index,
      initialBalance: entity.initialBalance,
      icon: entity.icon,
      color: entity.color,
      isActive: entity.isActive,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
