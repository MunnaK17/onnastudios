import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/mood_entry_model.dart';
import '../../data/models/yoga_class_model.dart';
import '../../data/models/app_enums.dart';
import '../../data/repositories/interfaces/mood_repository.dart';
import '../../data/repositories/implementations/local_mood_repository.dart';

/// Provider for MoodRepository instance.
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return LocalMoodRepository();
});

// ============ MOOD ENTRIES PROVIDERS ============

/// Provider for all mood entries.
final moodEntriesProvider = FutureProvider<List<MoodEntryModel>>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return repository.getAllMoodEntries();
});

/// Provider for today's mood entry.
final todayMoodEntryProvider = FutureProvider<MoodEntryModel?>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return repository.getTodayMoodEntry();
});

/// Provider for weekly mood entries.
final weeklyMoodEntriesProvider = FutureProvider<List<MoodEntryModel>>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return repository.getWeeklyMoodEntries();
});

/// Provider for monthly mood entries.
final monthlyMoodEntriesProvider = FutureProvider<List<MoodEntryModel>>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return repository.getMonthlyMoodEntries();
});

/// Provider for mood streak.
final moodStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return repository.getMoodStreak();
});

/// Provider for mood entries by date range.
final moodEntriesByDateRangeProvider = FutureProvider.family<List<MoodEntryModel>, ({DateTime start, DateTime end})>(
  (ref, range) async {
    final repository = ref.watch(moodRepositoryProvider);
    return repository.getMoodEntriesByDateRange(
      startDate: range.start,
      endDate: range.end,
    );
  },
);

// ============ MOOD TRACKER STATE ============

/// State class for mood tracker form.
class MoodTrackerState {
  const MoodTrackerState({
    this.mood,
    this.stressLevel,
    this.energyLevel,
    this.flexibility,
    this.mentalFocus,
    this.sleepQuality,
    this.tensionAreas,
    this.notes,
    this.isSubmitting = false,
    this.error,
  });

  final MoodType? mood;
  final StressLevel? stressLevel;
  final EnergyLevel? energyLevel;
  final FlexibilityLevel? flexibility;
  final MentalFocusLevel? mentalFocus;
  final SleepQuality? sleepQuality;
  final List<TensionArea>? tensionAreas;
  final String? notes;
  final bool isSubmitting;
  final String? error;

  bool get isValid =>
      mood != null &&
      stressLevel != null &&
      energyLevel != null &&
      flexibility != null &&
      mentalFocus != null;

  int get completedQuestions {
    int count = 0;
    if (mood != null) count++;
    if (stressLevel != null) count++;
    if (energyLevel != null) count++;
    if (flexibility != null) count++;
    if (mentalFocus != null) count++;
    return count;
  }

  MoodTrackerState copyWith({
    MoodType? mood,
    StressLevel? stressLevel,
    EnergyLevel? energyLevel,
    FlexibilityLevel? flexibility,
    MentalFocusLevel? mentalFocus,
    SleepQuality? sleepQuality,
    List<TensionArea>? tensionAreas,
    String? notes,
    bool? isSubmitting,
    String? error,
  }) {
    return MoodTrackerState(
      mood: mood ?? this.mood,
      stressLevel: stressLevel ?? this.stressLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      flexibility: flexibility ?? this.flexibility,
      mentalFocus: mentalFocus ?? this.mentalFocus,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      tensionAreas: tensionAreas ?? this.tensionAreas,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  MoodSummaryModel toSummary() {
    return MoodSummaryModel(
      mood: mood!,
      stressLevel: stressLevel!,
      energyLevel: energyLevel!,
      flexibility: flexibility!,
      mentalFocus: mentalFocus!,
      sleepQuality: sleepQuality,
      tensionAreas: tensionAreas,
      notes: notes,
    );
  }
}

/// Notifier for mood tracker form.
class MoodTrackerNotifier extends Notifier<MoodTrackerState> {
  @override
  MoodTrackerState build() => const MoodTrackerState();

  void setMood(MoodType mood) {
    state = state.copyWith(mood: mood);
  }

  void setStressLevel(StressLevel level) {
    state = state.copyWith(stressLevel: level);
  }

  void setEnergyLevel(EnergyLevel level) {
    state = state.copyWith(energyLevel: level);
  }

  void setFlexibility(FlexibilityLevel level) {
    state = state.copyWith(flexibility: level);
  }

  void setMentalFocus(MentalFocusLevel level) {
    state = state.copyWith(mentalFocus: level);
  }

  void setSleepQuality(SleepQuality? quality) {
    state = state.copyWith(sleepQuality: quality);
  }

  void setTensionAreas(List<TensionArea>? areas) {
    state = state.copyWith(tensionAreas: areas);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  void setSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = const MoodTrackerState();
  }

  Future<MoodEntryModel?> submit() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please complete all required questions');
      return null;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repository = ref.read(moodRepositoryProvider);
      final entry = await repository.createMoodEntry(
        summary: state.toSummary(),
      );

      // Refresh mood data providers
      ref.invalidate(moodEntriesProvider);
      ref.invalidate(todayMoodEntryProvider);
      ref.invalidate(weeklyMoodEntriesProvider);
      ref.invalidate(monthlyMoodEntriesProvider);
      ref.invalidate(moodStreakProvider);

      state = state.copyWith(isSubmitting: false);
      return entry;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to save mood entry: $e',
      );
      return null;
    }
  }
}

/// NotifierProvider for mood tracker form.
final moodTrackerProvider =
    NotifierProvider<MoodTrackerNotifier, MoodTrackerState>(() {
      return MoodTrackerNotifier();
    });

// ============ MOOD RECOMMENDATION ============

/// Recommendation result model.
class MoodRecommendation {
  const MoodRecommendation({
    required this.reason,
    required this.suggestedClasses,
    this.tip,
  });

  final String reason;
  final List<YogaClassModel> suggestedClasses;
  final String? tip;
}

/// Provider for mood-based class recommendations.
final moodRecommendationsProvider = FutureProvider<List<MoodRecommendation>>((ref) async {
  final todayMood = await ref.watch(todayMoodEntryProvider.future);

  if (todayMood == null) {
    return [];
  }

  return _generateRecommendations(todayMood);
});

/// Generate recommendations based on mood data.
List<MoodRecommendation> _generateRecommendations(MoodEntryModel mood) {
  final recommendations = <MoodRecommendation>[];

  // Rule 1: Stressed/Anxious + Low Energy → Restorative/Meditation
  if ((mood.mood == MoodType.stressedAnxious) && mood.energyLevel == EnergyLevel.low) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'You\'re feeling stressed with low energy. Gentle practices can help you unwind.',
        suggestedClasses: [], // Will be populated with classes from repository
        tip: 'Start with a 20-minute restorative session to release tension.',
      ),
    );
  }

  // Rule 2: Stressed/Anxious → Breathwork + Meditation
  if (mood.mood == MoodType.stressedAnxious) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'You\'re feeling stressed. Focus practices can help bring calm.',
        suggestedClasses: [],
        tip: 'Try breathwork exercises first to calm your nervous system.',
      ),
    );
  }

  // Rule 3: Feeling Stiff + Low Energy → Restorative Yoga
  if (mood.mood == MoodType.feelingStiff && mood.energyLevel == EnergyLevel.low) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'Your body feels stiff but low on energy. Gentle stretching is ideal.',
        suggestedClasses: [],
        tip: 'Hold poses longer with props for deep release.',
      ),
    );
  }

  // Rule 4: Happy/Positive + Determined + High Energy → Power/Advanced
  if ((mood.mood == MoodType.happyPositive || mood.mood == MoodType.feelingDetermined) &&
      mood.energyLevel == EnergyLevel.high) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'You\'re feeling great and determined! Perfect time for a challenging practice.',
        suggestedClasses: [],
        tip: 'Challenge yourself with strength and advanced poses.',
      ),
    );
  }

  // Rule 5: Low Energy / Tired → Gentle/Restorative
  if (mood.mood == MoodType.lowEnergy || mood.mood == MoodType.tiredLowEnergy) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'You might need some extra care today. Gentle practices can lift your mood.',
        suggestedClasses: [],
        tip: 'Be kind to yourself - it\'s okay to take it slow.',
      ),
    );
  }

  // Rule 6: Stressed + Feeling Stiff → Yoga Flow + Stretch
  if (mood.mood == MoodType.stressedAnxious || mood.mood == MoodType.feelingStiff) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'Stress and tension in your body? Movement can help release both.',
        suggestedClasses: [],
        tip: 'Focus on hip openers and back stretches to release stored tension.',
      ),
    );
  }

  // Rule 7: Ready to Learn + Determined → Strength + Vinyasa
  if (mood.mood == MoodType.readyToLearn || mood.mood == MoodType.feelingDetermined) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'Your mind and body are aligned. Great time for an active practice!',
        suggestedClasses: [],
        tip: 'Push your limits with strength training or advanced flows.',
      ),
    );
  }

  // Rule 8: Relaxed/Want to Chill → Meditation + Restorative
  if (mood.mood == MoodType.relaxedWantChill) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'You want to relax and unwind. Perfect for meditation and restorative yoga.',
        suggestedClasses: [],
        tip: 'Take this time to restore and rejuvenate.',
      ),
    );
  }

  // Rule 9: Default - balanced recommendation
  if (recommendations.isEmpty) {
    recommendations.add(
      const MoodRecommendation(
        reason: 'A balanced practice will help maintain your wellbeing.',
        suggestedClasses: [],
        tip: 'Mix of gentle and energizing exercises keeps you balanced.',
      ),
    );
  }

  return recommendations;
}

/// Get recommended class categories based on mood.
List<ClassCategory> getRecommendedCategories(MoodEntryModel mood) {
  final categories = <ClassCategory>[];

  // High stress → Meditation, Breathwork, Restorative
  if (mood.mood == MoodType.stressedAnxious || mood.stressLevel == StressLevel.high) {
    categories.add(ClassCategory.meditation);
    categories.add(ClassCategory.breathwork);
    categories.add(ClassCategory.restorative);
  }

  // Low energy → Restorative, Gentle
  if (mood.mood == MoodType.lowEnergy || mood.mood == MoodType.tiredLowEnergy || mood.energyLevel == EnergyLevel.low) {
    categories.add(ClassCategory.restorative);
  }

  // Feeling Stiff → Yoga Flow, Restorative
  if (mood.mood == MoodType.feelingStiff) {
    categories.add(ClassCategory.yogaFlow);
    categories.add(ClassCategory.restorative);
  }

  // Scattered focus → Meditation, Breathwork
  if (mood.mentalFocus == MentalFocusLevel.scattered) {
    categories.add(ClassCategory.meditation);
    categories.add(ClassCategory.breathwork);
  }

  // High energy + Determined → Strength, Vinyasa, Pilates
  if ((mood.mood == MoodType.feelingDetermined || mood.mood == MoodType.readyToLearn) &&
      mood.energyLevel == EnergyLevel.high) {
    categories.add(ClassCategory.strength);
    categories.add(ClassCategory.pilates);
    categories.add(ClassCategory.yogaFlow);
  }

  // Happy/Positive → All categories based on energy level
  if (mood.mood == MoodType.happyPositive) {
    categories.add(ClassCategory.yogaFlow);
    categories.add(ClassCategory.pilates);
    categories.add(ClassCategory.strength);
  }

  // Relaxed/Want to Chill → Meditation, Restorative
  if (mood.mood == MoodType.relaxedWantChill) {
    categories.add(ClassCategory.meditation);
    categories.add(ClassCategory.restorative);
    categories.add(ClassCategory.breathwork);
  }

  // Default fallback
  if (categories.isEmpty) {
    categories.add(ClassCategory.yogaFlow);
    categories.add(ClassCategory.meditation);
  }

  return categories.toSet().toList();
}
