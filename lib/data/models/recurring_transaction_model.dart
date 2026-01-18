import 'package:hive/hive.dart';

part 'recurring_transaction_model.g.dart';

@HiveType(typeId: 5)
class RecurringTransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final int typeIndex;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final String accountId;

  @HiveField(6)
  final String? toAccountId;

  @HiveField(7)
  final int frequencyIndex;

  @HiveField(8)
  final DateTime startDate;

  @HiveField(9)
  final DateTime? endDate;

  @HiveField(10)
  final DateTime nextDueDate;

  @HiveField(11)
  final bool isActive;

  @HiveField(12)
  final String? note;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  RecurringTransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.typeIndex,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.frequencyIndex,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.isActive = true,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
}
