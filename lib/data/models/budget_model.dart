import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late int periodType; // 0: weekly, 1: monthly, 2: yearly

  @HiveField(4)
  late int? month; // 1-12 for monthly budgets

  @HiveField(5)
  late int? year;

  @HiveField(6)
  late bool isActive;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.periodType,
    this.month,
    this.year,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    int? periodType,
    int? month,
    int? year,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      periodType: periodType ?? this.periodType,
      month: month ?? this.month,
      year: year ?? this.year,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
