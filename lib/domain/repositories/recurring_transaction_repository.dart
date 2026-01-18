import '../entities/recurring_transaction.dart';

abstract class RecurringTransactionRepository {
  Future<List<RecurringTransaction>> getAllRecurring();
  Future<List<RecurringTransaction>> getActiveRecurring();
  Future<List<RecurringTransaction>> getDueRecurring();
  Future<RecurringTransaction?> getRecurringById(String id);
  Future<void> createRecurring(RecurringTransaction recurring);
  Future<void> updateRecurring(RecurringTransaction recurring);
  Future<void> deleteRecurring(String id);
}
