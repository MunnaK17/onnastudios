import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/mood_entry_model.dart';
import '../interfaces/mood_repository.dart';

/// Local in-memory implementation of MoodRepository.
/// Replace with Supabase implementation when backend is ready.
class LocalMoodRepository implements MoodRepository {
  LocalMoodRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  // In-memory storage for mood entries (for MVP)
  static final List<MoodEntryModel> _moodEntries = [];

  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }
    return user.id;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Future<List<MoodEntryModel>> getAllMoodEntries() async {
    final userId = _currentUserId;
    return _moodEntries.where((e) => e.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = _currentUserId;
    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate).add(const Duration(days: 1));
    return _moodEntries
        .where((e) =>
            e.userId == userId &&
            e.date.isAfter(start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<MoodEntryModel?> getMoodEntryByDate(DateTime date) async {
    final userId = _currentUserId;
    final targetDate = _dateOnly(date);
    try {
      return _moodEntries.firstWhere(
        (e) =>
            e.userId == userId &&
            _dateOnly(e.date) == targetDate,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<MoodEntryModel?> getTodayMoodEntry() async {
    return getMoodEntryByDate(DateTime.now());
  }

  @override
  Future<MoodEntryModel> createMoodEntry({
    required MoodSummaryModel summary,
  }) async {
    final userId = _currentUserId;
    final now = DateTime.now();
    final today = _dateOnly(now);

    // Check if entry already exists for today
    final existing = await getMoodEntryByDate(today);
    if (existing != null) {
      return updateMoodEntry(entryId: existing.id, summary: summary);
    }

    final entry = MoodEntryModel(
      id: '${userId}_${today.toIso8601String()}',
      userId: userId,
      date: today,
      mood: summary.mood,
      stressLevel: summary.stressLevel,
      energyLevel: summary.energyLevel,
      flexibility: summary.flexibility,
      mentalFocus: summary.mentalFocus,
      sleepQuality: summary.sleepQuality,
      tensionAreas: summary.tensionAreas,
      notes: summary.notes,
      createdAt: now,
    );

    _moodEntries.add(entry);
    return entry;
  }

  @override
  Future<MoodEntryModel> updateMoodEntry({
    required String entryId,
    required MoodSummaryModel summary,
  }) async {
    final index = _moodEntries.indexWhere((e) => e.id == entryId);
    if (index == -1) {
      throw Exception('Mood entry not found');
    }

    final existing = _moodEntries[index];
    final updated = existing.copyWith(
      mood: summary.mood,
      stressLevel: summary.stressLevel,
      energyLevel: summary.energyLevel,
      flexibility: summary.flexibility,
      mentalFocus: summary.mentalFocus,
      sleepQuality: summary.sleepQuality,
      tensionAreas: summary.tensionAreas,
      notes: summary.notes,
    );

    _moodEntries[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteMoodEntry(String entryId) async {
    _moodEntries.removeWhere((e) => e.id == entryId);
  }

  @override
  Future<List<MoodEntryModel>> getWeeklyMoodEntries() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getMoodEntriesByDateRange(startDate: weekAgo, endDate: now);
  }

  @override
  Future<List<MoodEntryModel>> getMonthlyMoodEntries() async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return getMoodEntriesByDateRange(startDate: monthAgo, endDate: now);
  }

  @override
  Future<int> getMoodStreak() async {
    final entries = await getAllMoodEntries();
    if (entries.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = _dateOnly(DateTime.now());

    // Check if there's an entry for today
    final hasToday = entries.any(
      (e) => _dateOnly(e.date) == checkDate,
    );

    if (!hasToday) {
      // Check yesterday
      checkDate = checkDate.subtract(const Duration(days: 1));
      final hasYesterday = entries.any(
        (e) => _dateOnly(e.date) == checkDate,
      );
      if (!hasYesterday) return 0;
    }

    // Count consecutive days
    while (entries.any((e) => _dateOnly(e.date) == checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
