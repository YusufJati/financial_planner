import '../entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>> getAllDiaries();
  Future<List<DiaryEntry>> getDiariesByDateRange(DateTime start, DateTime end);
  Future<DiaryEntry?> getDiaryByDate(DateTime date);
  Future<DiaryEntry?> getDiaryById(String id);
  Future<void> createDiary(DiaryEntry diary);
  Future<void> updateDiary(DiaryEntry diary);
  Future<void> deleteDiary(String id);
  Future<List<DiaryEntry>> searchDiaries(String query);
}
