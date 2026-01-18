import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String accountId;

  @HiveField(2)
  String? toAccountId; // For transfers

  @HiveField(3)
  late String categoryId;

  @HiveField(4)
  late double amount; // Always positive

  @HiveField(5)
  late int typeIndex; // TransactionType enum index

  @HiveField(6)
  late DateTime date;

  @HiveField(7)
  String? note;

  @HiveField(8)
  String? attachmentPath;

  @HiveField(9)
  String? transferId; // Links two transfer transactions

  @HiveField(10)
  String? recurringId;

  @HiveField(11)
  late DateTime createdAt;

  @HiveField(12)
  late DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.accountId,
    this.toAccountId,
    required this.categoryId,
    required this.amount,
    required this.typeIndex,
    required this.date,
    this.note,
    this.attachmentPath,
    this.transferId,
    this.recurringId,
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionModel copyWith({
    String? id,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    double? amount,
    int? typeIndex,
    DateTime? date,
    String? note,
    String? attachmentPath,
    String? transferId,
    String? recurringId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      typeIndex: typeIndex ?? this.typeIndex,
      date: date ?? this.date,
      note: note ?? this.note,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      transferId: transferId ?? this.transferId,
      recurringId: recurringId ?? this.recurringId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
