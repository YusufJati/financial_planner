import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 0)
class AccountModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int typeIndex; // AccountType enum index

  @HiveField(3)
  late double initialBalance;

  @HiveField(4)
  late String icon;

  @HiveField(5)
  late String color;

  @HiveField(6)
  late bool isActive;

  @HiveField(7)
  late int order;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.typeIndex,
    this.initialBalance = 0,
    required this.icon,
    required this.color,
    this.isActive = true,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  AccountModel copyWith({
    String? id,
    String? name,
    int? typeIndex,
    double? initialBalance,
    String? icon,
    String? color,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      typeIndex: typeIndex ?? this.typeIndex,
      initialBalance: initialBalance ?? this.initialBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
