import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/local/database_service.dart';
import '../models/diary_entry_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DatabaseService _databaseService;

  DiaryRepositoryImpl(this._databaseService);

  @override
  Future<List<DiaryEntry>> getAllDiaries() async {
    final diaries = _databaseService.diaryBox.values.toList();
    diaries.sort((a, b) => b.date.compareTo(a.date));
    return diaries.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<DiaryEntry>> getDiariesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final diaries = _databaseService.diaryBox.values.where((d) {
      return d.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          d.date.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    diaries.sort((a, b) => b.date.compareTo(a.date));
    return diaries.map(_mapModelToEntity).toList();
  }

  @override
  Future<DiaryEntry?> getDiaryByDate(DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);

    final diary = _databaseService.diaryBox.values.cast<DiaryEntryModel?>().firstWhere(
      (d) {
        if (d == null) return false;
        final diaryDate = DateTime(d.date.year, d.date.month, d.date.day);
        return diaryDate == targetDate;
      },
      orElse: () => null,
    );

    if (diary == null) return null;
    return _mapModelToEntity(diary);
  }

  @override
  Future<DiaryEntry?> getDiaryById(String id) async {
    final model = _databaseService.diaryBox.get(id);
    if (model == null) return null;
    return _mapModelToEntity(model);
  }

  @override
  Future<void> createDiary(DiaryEntry diary) async {
    final model = _mapEntityToModel(diary);
    await _databaseService.diaryBox.put(diary.id, model);
  }

  @override
  Future<void> updateDiary(DiaryEntry diary) async {
    final model = _mapEntityToModel(diary);
    await _databaseService.diaryBox.put(diary.id, model);
  }

  @override
  Future<void> deleteDiary(String id) async {
    await _databaseService.diaryBox.delete(id);
  }

  @override
  Future<List<DiaryEntry>> searchDiaries(String query) async {
    final lowerQuery = query.toLowerCase();
    final diaries = _databaseService.diaryBox.values.where((d) {
      return d.title.toLowerCase().contains(lowerQuery) ||
          d.content.toLowerCase().contains(lowerQuery) ||
          d.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();

    diaries.sort((a, b) => b.date.compareTo(a.date));
    return diaries.map(_mapModelToEntity).toList();
  }

  DiaryEntry _mapModelToEntity(DiaryEntryModel model) {
    return DiaryEntry(
      id: model.id,
      date: model.date,
      title: model.title,
      content: model.content,
      mood: model.mood,
      tags: List<String>.from(model.tags),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  DiaryEntryModel _mapEntityToModel(DiaryEntry entity) {
    return DiaryEntryModel(
      id: entity.id,
      date: entity.date,
      title: entity.title,
      content: entity.content,
      mood: entity.mood,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
