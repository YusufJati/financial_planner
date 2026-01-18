import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int typeIndex; // CategoryType enum index

  @HiveField(3)
  late String icon;

  @HiveField(4)
  late String color;

  @HiveField(5)
  String? parentId;

  @HiveField(6)
  late bool isDefault;

  @HiveField(7)
  late int order;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.typeIndex,
    required this.icon,
    required this.color,
    this.parentId,
    this.isDefault = false,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    int? typeIndex,
    String? icon,
    String? color,
    String? parentId,
    bool? isDefault,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      typeIndex: typeIndex ?? this.typeIndex,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      isDefault: isDefault ?? this.isDefault,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
