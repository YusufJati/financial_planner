import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 4)
class GoalModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late double targetAmount;

  @HiveField(4)
  late double currentAmount;

  @HiveField(5)
  DateTime? targetDate;

  @HiveField(6)
  late int statusIndex; // 0: active, 1: completed, 2: cancelled

  @HiveField(7)
  late String icon;

  @HiveField(8)
  late String color;

  @HiveField(9)
  late DateTime createdAt;

  @HiveField(10)
  late DateTime updatedAt;

  GoalModel({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    this.statusIndex = 0,
    this.icon = 'target',
    this.color = '#2563EB',
    required this.createdAt,
    required this.updatedAt,
  });

  GoalModel copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    int? statusIndex,
    String? icon,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      statusIndex: statusIndex ?? this.statusIndex,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
