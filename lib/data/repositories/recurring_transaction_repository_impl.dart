import '../../core/constants/app_constants.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../datasources/local/database_service.dart';
import '../models/recurring_transaction_model.dart';

class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  final DatabaseService _db;

  RecurringTransactionRepositoryImpl(this._db);

  @override
  Future<List<RecurringTransaction>> getAllRecurring() async {
    final box = _db.recurringBox;
    final models = box.values.toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<RecurringTransaction>> getActiveRecurring() async {
    final box = _db.recurringBox;
    final models = box.values.where((r) => r.isActive).toList();
    models.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<RecurringTransaction>> getDueRecurring() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final box = _db.recurringBox;
    final models = box.values.where((r) {
      if (!r.isActive) return false;
      final due =
          DateTime(r.nextDueDate.year, r.nextDueDate.month, r.nextDueDate.day);
      return due.isAtSameMomentAs(today) || due.isBefore(today);
    }).toList();

    models.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return models.map(_toEntity).toList();
  }

  @override
  Future<RecurringTransaction?> getRecurringById(String id) async {
    final model = _db.recurringBox.get(id);
    if (model == null) return null;
    return _toEntity(model);
  }

  @override
  Future<void> createRecurring(RecurringTransaction recurring) async {
    final model = _toModel(recurring);
    await _db.recurringBox.put(model.id, model);
  }

  @override
  Future<void> updateRecurring(RecurringTransaction recurring) async {
    final model = _toModel(recurring);
    await _db.recurringBox.put(model.id, model);
  }

  @override
  Future<void> deleteRecurring(String id) async {
    await _db.recurringBox.delete(id);
  }

  RecurringTransaction _toEntity(RecurringTransactionModel model) {
    return RecurringTransaction(
      id: model.id,
      name: model.name,
      amount: model.amount,
      type: TransactionType.values[model.typeIndex],
      categoryId: model.categoryId,
      accountId: model.accountId,
      toAccountId: model.toAccountId,
      frequency: RecurringFrequency.values[model.frequencyIndex],
      startDate: model.startDate,
      endDate: model.endDate,
      nextDueDate: model.nextDueDate,
      isActive: model.isActive,
      note: model.note,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  RecurringTransactionModel _toModel(RecurringTransaction entity) {
    return RecurringTransactionModel(
      id: entity.id,
      name: entity.name,
      amount: entity.amount,
      typeIndex: entity.type.index,
      categoryId: entity.categoryId,
      accountId: entity.accountId,
      toAccountId: entity.toAccountId,
      frequencyIndex: entity.frequency.index,
      startDate: entity.startDate,
      endDate: entity.endDate,
      nextDueDate: entity.nextDueDate,
      isActive: entity.isActive,
      note: entity.note,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
