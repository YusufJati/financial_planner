import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../datasources/local/database_service.dart';

class BackupRestoreService {
  final DatabaseService _db;

  BackupRestoreService(this._db);

  /// Export all data to JSON format
  Future<Map<String, dynamic>> exportToJson() async {
    final accounts = _db.accountBox.values
        .map((a) => {
              'id': a.id,
              'name': a.name,
              'typeIndex': a.typeIndex,
              'initialBalance': a.initialBalance,
              'icon': a.icon,
              'color': a.color,
              'isActive': a.isActive,
              'order': a.order,
              'createdAt': a.createdAt.toIso8601String(),
              'updatedAt': a.updatedAt.toIso8601String(),
            })
        .toList();

    final categories = _db.categoryBox.values
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'typeIndex': c.typeIndex,
              'icon': c.icon,
              'color': c.color,
              'parentId': c.parentId,
              'isDefault': c.isDefault,
              'order': c.order,
              'createdAt': c.createdAt.toIso8601String(),
              'updatedAt': c.updatedAt.toIso8601String(),
            })
        .toList();

    final transactions = _db.transactionBox.values
        .map((t) => {
              'id': t.id,
              'accountId': t.accountId,
              'toAccountId': t.toAccountId,
              'categoryId': t.categoryId,
              'amount': t.amount,
              'typeIndex': t.typeIndex,
              'date': t.date.toIso8601String(),
              'note': t.note,
              'attachmentPath': t.attachmentPath,
              'transferId': t.transferId,
              'recurringId': t.recurringId,
              'createdAt': t.createdAt.toIso8601String(),
              'updatedAt': t.updatedAt.toIso8601String(),
            })
        .toList();

    final budgets = _db.budgetBox.values
        .map((b) => {
              'id': b.id,
              'categoryId': b.categoryId,
              'amount': b.amount,
              'createdAt': b.createdAt.toIso8601String(),
              'updatedAt': b.updatedAt.toIso8601String(),
            })
        .toList();

    final goals = _db.goalBox.values
        .map((g) => {
              'id': g.id,
              'name': g.name,
              'description': g.description,
              'targetAmount': g.targetAmount,
              'currentAmount': g.currentAmount,
              'targetDate': g.targetDate?.toIso8601String(),
              'icon': g.icon,
              'color': g.color,
              'createdAt': g.createdAt.toIso8601String(),
              'updatedAt': g.updatedAt.toIso8601String(),
            })
        .toList();

    final recurring = _db.recurringBox.values
        .map((r) => {
              'id': r.id,
              'name': r.name,
              'amount': r.amount,
              'typeIndex': r.typeIndex,
              'categoryId': r.categoryId,
              'accountId': r.accountId,
              'toAccountId': r.toAccountId,
              'frequencyIndex': r.frequencyIndex,
              'startDate': r.startDate.toIso8601String(),
              'endDate': r.endDate?.toIso8601String(),
              'nextDueDate': r.nextDueDate.toIso8601String(),
              'isActive': r.isActive,
              'note': r.note,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
            })
        .toList();

    return {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'data': {
        'accounts': accounts,
        'categories': categories,
        'transactions': transactions,
        'budgets': budgets,
        'goals': goals,
        'recurring': recurring,
      },
    };
  }

  /// Save backup to file and return the file path
  Future<String> saveBackupToFile() async {
    final data = await exportToJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final fileName =
        'financial_planner_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// Get backup as JSON string for clipboard
  Future<String> getBackupAsString() async {
    final data = await exportToJson();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Copy backup to clipboard
  Future<void> copyToClipboard() async {
    final jsonString = await getBackupAsString();
    await Clipboard.setData(ClipboardData(text: jsonString));
  }
}
