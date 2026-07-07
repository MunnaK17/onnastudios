import '../../models/mood_entry_model.dart';

/// Repository interface for mood tracker operations.
abstract class MoodRepository {
  /// Get all mood entries for the current user.
  Future<List<MoodEntryModel>> getAllMoodEntries();

  /// Get mood entries for a specific date range.
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get mood entry for a specific date.
  Future<MoodEntryModel?> getMoodEntryByDate(DateTime date);

  /// Get today's mood entry if exists.
  Future<MoodEntryModel?> getTodayMoodEntry();

  /// Create a new mood entry.
  Future<MoodEntryModel> createMoodEntry({
    required MoodSummaryModel summary,
  });

  /// Update an existing mood entry.
  Future<MoodEntryModel> updateMoodEntry({
    required String entryId,
    required MoodSummaryModel summary,
  });

  /// Delete a mood entry.
  Future<void> deleteMoodEntry(String entryId);

  /// Get weekly mood summary (last 7 days).
  Future<List<MoodEntryModel>> getWeeklyMoodEntries();

  /// Get monthly mood summary (last 30 days).
  Future<List<MoodEntryModel>> getMonthlyMoodEntries();

  /// Get mood streak (consecutive days with entries).
  Future<int> getMoodStreak();
}
