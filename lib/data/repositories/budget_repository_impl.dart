import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/local/database_service.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final DatabaseService _databaseService;

  BudgetRepositoryImpl(this._databaseService);

  @override
  Future<List<Budget>> getAllBudgets() async {
    final budgets = _databaseService.budgetBox.values.toList();
    final result = <Budget>[];

    for (final model in budgets) {
      final budget = await _mapModelToEntity(model);
      result.add(budget);
    }

    return result;
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    final budgets =
        _databaseService.budgetBox.values.where((b) => b.isActive).toList();
    final result = <Budget>[];

    for (final model in budgets) {
      final budget = await _mapModelToEntity(model);
      result.add(budget);
    }

    return result;
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final model = _databaseService.budgetBox.get(id);
    if (model == null) return null;
    return _mapModelToEntity(model);
  }

  @override
  Future<Budget?> getBudgetByCategory(
      String categoryId, BudgetPeriod period) async {
    final budgets = _databaseService.budgetBox.values
        .where((b) =>
            b.categoryId == categoryId &&
            b.periodType == period.index &&
            b.isActive)
        .toList();

    if (budgets.isEmpty) return null;
    return _mapModelToEntity(budgets.first);
  }

  @override
  Future<void> createBudget(Budget budget) async {
    final model = _mapEntityToModel(budget);
    await _databaseService.budgetBox.put(budget.id, model);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final model = _mapEntityToModel(budget);
    await _databaseService.budgetBox.put(budget.id, model);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _databaseService.budgetBox.delete(id);
  }

  @override
  Future<double> getTotalBudgetAmount() async {
    final budgets = await getActiveBudgets();
    double total = 0;
    for (final b in budgets) {
      total += b.amount;
    }
    return total;
  }

  @override
  Future<double> getTotalSpentAmount() async {
    final budgets = await getActiveBudgets();
    double total = 0;
    for (final b in budgets) {
      total += b.spentAmount;
    }
    return total;
  }

  @override
  Future<double> calculateSpentAmount(
      String categoryId, BudgetPeriod period) async {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;

    switch (period) {
      case BudgetPeriod.weekly:
        // Start from beginning of current week (Monday)
        final weekday = now.weekday;
        start = DateTime(now.year, now.month, now.day - weekday + 1);
        end = start.add(const Duration(days: 7));
        break;
      case BudgetPeriod.monthly:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
        break;
      case BudgetPeriod.yearly:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year + 1, 1, 1);
        break;
    }

    // Get transactions for the category in the date range
    final transactions = _databaseService.transactionBox.values
        .where((t) =>
            t.categoryId == categoryId &&
            t.typeIndex == TransactionType.expense.index &&
            t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end))
        .toList();

    double total = 0;
    for (final t in transactions) {
      total += t.amount;
    }
    return total;
  }

  Future<Budget> _mapModelToEntity(BudgetModel model) async {
    // Get category
    final categoryModel = _databaseService.categoryBox.get(model.categoryId);
    Category? category;
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

    // Calculate spent amount
    final period = BudgetPeriod.values[model.periodType];
    final spentAmount = await calculateSpentAmount(model.categoryId, period);

    return Budget(
      id: model.id,
      categoryId: model.categoryId,
      amount: model.amount,
      period: period,
      month: model.month,
      year: model.year,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      spentAmount: spentAmount,
      category: category,
    );
  }

  BudgetModel _mapEntityToModel(Budget entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      periodType: entity.period.index,
      month: entity.month,
      year: entity.year,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
