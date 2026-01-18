import '../entities/transaction.dart';
import '../../core/constants/app_constants.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<List<Transaction>> getTransactionsByAccount(String accountId);
  Future<List<Transaction>> getTransactionsByCategory(String categoryId);
  Future<Transaction?> getTransactionById(String id);
  Future<void> createTransaction(Transaction transaction);
  Future<void> createTransfer(Transaction fromTransaction, Transaction toTransaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<double> getTotalByType(TransactionType type, DateTime start, DateTime end);
  Future<Map<String, double>> getSpendingByCategory(DateTime start, DateTime end);
  Future<List<Transaction>> getRecentTransactions(int limit);
}
