import 'package:equatable/equatable.dart';

/// Goal status
enum GoalStatus {
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Goal entity for savings tracking
class Goal extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final GoalStatus status;
  final String icon;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    this.status = GoalStatus.active,
    this.icon = 'target',
    this.color = '#2563EB',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Progress percentage (0.0 to 1.0)
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  /// Remaining amount to reach goal
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0, double.infinity);

  /// Whether goal is achieved
  bool get isAchieved => currentAmount >= targetAmount;

  /// Days remaining until target date
  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  /// Daily savings needed to reach goal
  double? get dailySavingsNeeded {
    if (targetDate == null || remainingAmount <= 0) return null;
    final days = daysRemaining;
    if (days == null || days <= 0) return remainingAmount;
    return remainingAmount / days;
  }

  Goal copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    GoalStatus? status,
    String? icon,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        targetAmount,
        currentAmount,
        targetDate,
        status,
        icon,
        color,
        createdAt,
        updatedAt,
      ];
}
