import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/local/database_service.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final DatabaseService _databaseService;

  GoalRepositoryImpl(this._databaseService);

  @override
  Future<List<Goal>> getAllGoals() async {
    final goals = _databaseService.goalBox.values.toList();
    return goals.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<Goal>> getActiveGoals() async {
    final goals = _databaseService.goalBox.values
        .where((g) => g.statusIndex == GoalStatus.active.index)
        .toList();
    return goals.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<Goal>> getCompletedGoals() async {
    final goals = _databaseService.goalBox.values
        .where((g) => g.statusIndex == GoalStatus.completed.index)
        .toList();
    return goals.map(_mapModelToEntity).toList();
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    final model = _databaseService.goalBox.get(id);
    if (model == null) return null;
    return _mapModelToEntity(model);
  }

  @override
  Future<void> createGoal(Goal goal) async {
    final model = _mapEntityToModel(goal);
    await _databaseService.goalBox.put(goal.id, model);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final model = _mapEntityToModel(goal);
    await _databaseService.goalBox.put(goal.id, model);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _databaseService.goalBox.delete(id);
  }

  @override
  Future<void> deposit(String goalId, double amount) async {
    final model = _databaseService.goalBox.get(goalId);
    if (model == null) return;

    final newAmount = model.currentAmount + amount;
    final isCompleted = newAmount >= model.targetAmount;

    await _databaseService.goalBox.put(
      goalId,
      model.copyWith(
        currentAmount: newAmount,
        statusIndex:
            isCompleted ? GoalStatus.completed.index : model.statusIndex,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> withdraw(String goalId, double amount) async {
    final model = _databaseService.goalBox.get(goalId);
    if (model == null) return;

    final newAmount =
        (model.currentAmount - amount).clamp(0.0, double.infinity);

    await _databaseService.goalBox.put(
      goalId,
      model.copyWith(
        currentAmount: newAmount,
        statusIndex: GoalStatus.active.index, // Reactivate if was completed
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> markAsCompleted(String goalId) async {
    final model = _databaseService.goalBox.get(goalId);
    if (model == null) return;

    await _databaseService.goalBox.put(
      goalId,
      model.copyWith(
        statusIndex: GoalStatus.completed.index,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<double> getTotalSavings() async {
    final goals = await getActiveGoals();
    double total = 0;
    for (final goal in goals) {
      total += goal.currentAmount;
    }
    return total;
  }

  Goal _mapModelToEntity(GoalModel model) {
    return Goal(
      id: model.id,
      name: model.name,
      description: model.description,
      targetAmount: model.targetAmount,
      currentAmount: model.currentAmount,
      targetDate: model.targetDate,
      status: GoalStatus.values[model.statusIndex],
      icon: model.icon,
      color: model.color,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  GoalModel _mapEntityToModel(Goal entity) {
    return GoalModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      targetDate: entity.targetDate,
      statusIndex: entity.status.index,
      icon: entity.icon,
      color: entity.color,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
