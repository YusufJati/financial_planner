import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final String icon;
  final String color;
  final String? parentId;
  final bool isDefault;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.parentId,
    this.isDefault = false,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    String? parentId,
    bool? isDefault,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      isDefault: isDefault ?? this.isDefault,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        icon,
        color,
        parentId,
        isDefault,
        order,
        createdAt,
        updatedAt,
      ];
}
