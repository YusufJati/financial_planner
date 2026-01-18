import '../entities/goal.dart';

abstract class GoalRepository {
  /// Get all goals
  Future<List<Goal>> getAllGoals();

  /// Get active goals
  Future<List<Goal>> getActiveGoals();

  /// Get completed goals
  Future<List<Goal>> getCompletedGoals();

  /// Get goal by ID
  Future<Goal?> getGoalById(String id);

  /// Create new goal
  Future<void> createGoal(Goal goal);

  /// Update goal
  Future<void> updateGoal(Goal goal);

  /// Delete goal
  Future<void> deleteGoal(String id);

  /// Add money to goal
  Future<void> deposit(String goalId, double amount);

  /// Withdraw money from goal
  Future<void> withdraw(String goalId, double amount);

  /// Mark goal as completed
  Future<void> markAsCompleted(String goalId);

  /// Get total savings across all goals
  Future<double> getTotalSavings();
}
