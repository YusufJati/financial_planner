import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class Account extends Equatable {
  final String id;
  final String name;
  final AccountType type;
  final double initialBalance;
  final String icon;
  final String color;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed property - will be set by repository
  final double currentBalance;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.initialBalance = 0,
    required this.icon,
    required this.color,
    this.isActive = true,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
    this.currentBalance = 0,
  });

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? initialBalance,
    String? icon,
    String? color,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? currentBalance,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        initialBalance,
        icon,
        color,
        isActive,
        order,
        createdAt,
        updatedAt,
        currentBalance,
      ];
}
