import 'package:equatable/equatable.dart';
import '../entities/category.dart';

/// Budget period type
enum BudgetPeriod {
  weekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  int get daysCount {
    switch (this) {
      case BudgetPeriod.weekly:
        return 7;
      case BudgetPeriod.monthly:
        return 30;
      case BudgetPeriod.yearly:
        return 365;
    }
  }
}

/// Budget entity for tracking spending limits per category
class Budget extends Equatable {
  final String id;
  final String categoryId;
  final double amount;
  final BudgetPeriod period;
  final int? month; // For monthly budgets (1-12)
  final int? year;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed fields (populated by repository)
  final double spentAmount;
  final Category? category;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    this.month,
    this.year,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.spentAmount = 0,
    this.category,
  });

  /// Remaining budget amount
  double get remainingAmount => amount - spentAmount;

  /// Progress percentage (0.0 to 1.0+)
  double get progress => amount > 0 ? spentAmount / amount : 0;

  /// Whether budget is exceeded
  bool get isOverBudget => spentAmount > amount;

  /// Budget status for color coding
  BudgetStatus get status {
    if (progress >= 1.0) return BudgetStatus.exceeded;
    if (progress >= 0.8) return BudgetStatus.warning;
    return BudgetStatus.normal;
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    double? amount,
    BudgetPeriod? period,
    int? month,
    int? year,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? spentAmount,
    Category? category,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      month: month ?? this.month,
      year: year ?? this.year,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      spentAmount: spentAmount ?? this.spentAmount,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        amount,
        period,
        month,
        year,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Budget status for UI color coding
enum BudgetStatus {
  normal, // Green - under 80%
  warning, // Yellow - 80-100%
  exceeded, // Red - over 100%
}
