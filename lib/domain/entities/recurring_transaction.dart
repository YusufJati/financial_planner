import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class RecurringTransaction extends Equatable {
  final String id;
  final String name;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final String? toAccountId; // For transfers
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final bool isActive;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.isActive = true,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringTransaction copyWith({
    String? id,
    String? name,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? isActive,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if this recurring transaction is due today
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    return due.isAtSameMomentAs(today) || due.isBefore(today);
  }

  /// Check if this recurring transaction is overdue
  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    return due.isBefore(today);
  }

  /// Calculate the next due date after execution
  DateTime calculateNextDueDate() {
    switch (frequency) {
      case RecurringFrequency.daily:
        return nextDueDate.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return nextDueDate.add(const Duration(days: 7));
      case RecurringFrequency.biweekly:
        return nextDueDate.add(const Duration(days: 14));
      case RecurringFrequency.monthly:
        return DateTime(
          nextDueDate.year,
          nextDueDate.month + 1,
          nextDueDate.day,
        );
      case RecurringFrequency.yearly:
        return DateTime(
          nextDueDate.year + 1,
          nextDueDate.month,
          nextDueDate.day,
        );
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        type,
        categoryId,
        accountId,
        toAccountId,
        frequency,
        startDate,
        endDate,
        nextDueDate,
        isActive,
        note,
        createdAt,
        updatedAt,
      ];
}
