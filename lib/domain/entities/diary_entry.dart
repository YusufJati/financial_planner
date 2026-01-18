import 'package:equatable/equatable.dart';

class DiaryEntry extends Equatable {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final String? mood;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiaryEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.mood,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    String? mood,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        date,
        title,
        content,
        mood,
        tags,
        createdAt,
        updatedAt,
      ];
}

class DailyCashflow {
  final DateTime date;
  final double income;
  final double expense;

  const DailyCashflow({
    required this.date,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;

  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class CategoryCashflow {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double amount;
  final double percentage;

  const CategoryCashflow({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.percentage,
  });
}
