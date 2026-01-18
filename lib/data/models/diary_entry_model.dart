import 'package:hive/hive.dart';

part 'diary_entry_model.g.dart';

@HiveType(typeId: 6)
class DiaryEntryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String content;

  @HiveField(4)
  String? mood;

  @HiveField(5)
  late List<String> tags;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late DateTime updatedAt;

  DiaryEntryModel({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.mood,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  DiaryEntryModel copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    String? mood,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntryModel(
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
}
