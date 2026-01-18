import '../entities/budget.dart';

abstract class BudgetRepository {
  /// Get all budgets with spent amounts calculated
  Future<List<Budget>> getAllBudgets();

  /// Get active budgets for current period
  Future<List<Budget>> getActiveBudgets();

  /// Get budget by ID
  Future<Budget?> getBudgetById(String id);

  /// Get budget for specific category and period
  Future<Budget?> getBudgetByCategory(String categoryId, BudgetPeriod period);

  /// Create new budget
  Future<void> createBudget(Budget budget);

  /// Update existing budget
  Future<void> updateBudget(Budget budget);

  /// Delete budget
  Future<void> deleteBudget(String id);

  /// Get total budget amount for period
  Future<double> getTotalBudgetAmount();

  /// Get total spent amount for all budgets
  Future<double> getTotalSpentAmount();

  /// Calculate spent amount for a budget
  Future<double> calculateSpentAmount(String categoryId, BudgetPeriod period);
}
