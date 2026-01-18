import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';
import 'account.dart';
import 'category.dart';

class Transaction extends Equatable {
  final String id;
  final String accountId;
  final String? toAccountId;
  final String categoryId;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;
  final String? attachmentPath;
  final String? transferId;
  final String? recurringId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations (populated by repository)
  final Account? account;
  final Account? toAccount;
  final Category? category;

  const Transaction({
    required this.id,
    required this.accountId,
    this.toAccountId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.attachmentPath,
    this.transferId,
    this.recurringId,
    required this.createdAt,
    required this.updatedAt,
    this.account,
    this.toAccount,
    this.category,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  Transaction copyWith({
    String? id,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? note,
    String? attachmentPath,
    String? transferId,
    String? recurringId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Account? account,
    Account? toAccount,
    Category? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      transferId: transferId ?? this.transferId,
      recurringId: recurringId ?? this.recurringId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      account: account ?? this.account,
      toAccount: toAccount ?? this.toAccount,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        accountId,
        toAccountId,
        categoryId,
        amount,
        type,
        date,
        note,
        attachmentPath,
        transferId,
        recurringId,
        createdAt,
        updatedAt,
      ];
}
