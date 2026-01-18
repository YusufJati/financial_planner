import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../datasources/local/database_service.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseService _db;

  TransactionRepositoryImpl(this._db);

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final box = _db.transactionBox;
    final models = box.values.toList();
    models.sort((a, b) => b.date.compareTo(a.date));
    return Future.wait(models.map(_toEntityWithRelations));
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final box = _db.transactionBox;
    final models = box.values.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
    models.sort((a, b) => b.date.compareTo(a.date));
    return Future.wait(models.map(_toEntityWithRelations));
  }

  @override
  Future<List<Transaction>> getTransactionsByAccount(String accountId) async {
    final box = _db.transactionBox;
    final models = box.values
        .where((t) => t.accountId == accountId || t.toAccountId == accountId)
        .toList();
    models.sort((a, b) => b.date.compareTo(a.date));
    return Future.wait(models.map(_toEntityWithRelations));
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    final box = _db.transactionBox;
    final models = box.values
        .where((t) => t.categoryId == categoryId)
        .toList();
    models.sort((a, b) => b.date.compareTo(a.date));
    return Future.wait(models.map(_toEntityWithRelations));
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final model = _db.transactionBox.get(id);
    if (model == null) return null;
    return _toEntityWithRelations(model);
  }

  @override
  Future<void> createTransaction(Transaction transaction) async {
    final model = _toModel(transaction);
    await _db.transactionBox.put(model.id, model);
  }

  @override
  Future<void> createTransfer(
    Transaction fromTransaction,
    Transaction toTransaction,
  ) async {
    final fromModel = _toModel(fromTransaction);
    final toModel = _toModel(toTransaction);
    await _db.transactionBox.put(fromModel.id, fromModel);
    await _db.transactionBox.put(toModel.id, toModel);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = _toModel(transaction);
    await _db.transactionBox.put(model.id, model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final box = _db.transactionBox;
    final transaction = box.get(id);
    if (transaction != null && transaction.transferId != null) {
      final linkedTransactions = box.values
          .where((t) => t.transferId == transaction.transferId && t.id != id);
      for (final linked in linkedTransactions) {
        await box.delete(linked.id);
      }
    }
    await box.delete(id);
  }

  @override
  Future<double> getTotalByType(
    TransactionType type,
    DateTime start,
    DateTime end,
  ) async {
    final box = _db.transactionBox;
    final transactions = box.values.where((t) {
      return t.typeIndex == type.index &&
          t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(seconds: 1)));
    });

    double total = 0;
    for (final t in transactions) {
      total += t.amount;
    }
    return total;
  }

  @override
  Future<Map<String, double>> getSpendingByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final box = _db.transactionBox;
    final transactions = box.values.where((t) {
      return t.typeIndex == TransactionType.expense.index &&
          t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(seconds: 1)));
    });

    final Map<String, double> spending = {};
    for (final t in transactions) {
      spending[t.categoryId] = (spending[t.categoryId] ?? 0) + t.amount;
    }
    return spending;
  }

  @override
  Future<List<Transaction>> getRecentTransactions(int limit) async {
    final box = _db.transactionBox;
    final models = box.values.toList();
    models.sort((a, b) => b.date.compareTo(a.date));
    final limited = models.take(limit).toList();
    return Future.wait(limited.map(_toEntityWithRelations));
  }

  Future<Transaction> _toEntityWithRelations(TransactionModel model) async {
    Account? account;
    Account? toAccount;
    Category? category;

    final accountModel = _db.accountBox.get(model.accountId);
    if (accountModel != null) {
      account = Account(
        id: accountModel.id,
        name: accountModel.name,
        type: AccountType.values[accountModel.typeIndex],
        initialBalance: accountModel.initialBalance,
        icon: accountModel.icon,
        color: accountModel.color,
        isActive: accountModel.isActive,
        order: accountModel.order,
        createdAt: accountModel.createdAt,
        updatedAt: accountModel.updatedAt,
      );
    }

    if (model.toAccountId != null) {
      final toAccountModel = _db.accountBox.get(model.toAccountId!);
      if (toAccountModel != null) {
        toAccount = Account(
          id: toAccountModel.id,
          name: toAccountModel.name,
          type: AccountType.values[toAccountModel.typeIndex],
          initialBalance: toAccountModel.initialBalance,
          icon: toAccountModel.icon,
          color: toAccountModel.color,
          isActive: toAccountModel.isActive,
          order: toAccountModel.order,
          createdAt: toAccountModel.createdAt,
          updatedAt: toAccountModel.updatedAt,
        );
      }
    }

    final categoryModel = _db.categoryBox.get(model.categoryId);
    if (categoryModel != null) {
      category = Category(
        id: categoryModel.id,
        name: categoryModel.name,
        type: CategoryType.values[categoryModel.typeIndex],
        icon: categoryModel.icon,
        color: categoryModel.color,
        parentId: categoryModel.parentId,
        isDefault: categoryModel.isDefault,
        order: categoryModel.order,
        createdAt: categoryModel.createdAt,
        updatedAt: categoryModel.updatedAt,
      );
    }

    return Transaction(
      id: model.id,
      accountId: model.accountId,
      toAccountId: model.toAccountId,
      categoryId: model.categoryId,
      amount: model.amount,
      type: TransactionType.values[model.typeIndex],
      date: model.date,
      note: model.note,
      attachmentPath: model.attachmentPath,
      transferId: model.transferId,
      recurringId: model.recurringId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      account: account,
      toAccount: toAccount,
      category: category,
    );
  }

  TransactionModel _toModel(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      accountId: entity.accountId,
      toAccountId: entity.toAccountId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      typeIndex: entity.type.index,
      date: entity.date,
      note: entity.note,
      attachmentPath: entity.attachmentPath,
      transferId: entity.transferId,
      recurringId: entity.recurringId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
