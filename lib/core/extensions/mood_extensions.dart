import '../../data/models/app_enums.dart';

// ============ MOOD TYPE EXTENSIONS ============

extension MoodTypeExtension on MoodType {
  /// Convert mood to a numerical value (1-5) for analytics/recommendations
  int toNumber() {
    switch (this) {
      case MoodType.feelingStiff:
        return 2;
      case MoodType.readyToLearn:
        return 5;
      case MoodType.lowEnergy:
        return 2;
      case MoodType.stressedAnxious:
        return 2;
      case MoodType.relaxedWantChill:
        return 4;
      case MoodType.happyPositive:
        return 5;
      case MoodType.tiredLowEnergy:
        return 1;
      case MoodType.feelingDetermined:
        return 5;
    }
  }

  /// Emoji representation of the mood
  String get emoji {
    switch (this) {
      case MoodType.feelingStiff:
        return '🧘';
      case MoodType.readyToLearn:
        return '📚';
      case MoodType.lowEnergy:
        return '😴';
      case MoodType.stressedAnxious:
        return '😰';
      case MoodType.relaxedWantChill:
        return '😌';
      case MoodType.happyPositive:
        return '😊';
      case MoodType.tiredLowEnergy:
        return '🥱';
      case MoodType.feelingDetermined:
        return '💪';
    }
  }

  /// Display label for the mood
  String get label {
    switch (this) {
      case MoodType.feelingStiff:
        return 'Feeling Stiff';
      case MoodType.readyToLearn:
        return 'Ready to Learn';
      case MoodType.lowEnergy:
        return 'Low Energy';
      case MoodType.stressedAnxious:
        return 'Stressed / Anxious';
      case MoodType.relaxedWantChill:
        return 'Relaxed';
      case MoodType.happyPositive:
        return 'Happy / Positive';
      case MoodType.tiredLowEnergy:
        return 'Tired';
      case MoodType.feelingDetermined:
        return 'Feeling Determined';
    }
  }

  /// Short description for the mood
  String get description {
    switch (this) {
      case MoodType.feelingStiff:
        return 'Body feels tight or inflexible';
      case MoodType.readyToLearn:
        return 'Eager to learn and improve';
      case MoodType.lowEnergy:
        return 'Lacking motivation or energy';
      case MoodType.stressedAnxious:
        return 'Feeling worried or tense';
      case MoodType.relaxedWantChill:
        return 'Calm and want to relax';
      case MoodType.happyPositive:
        return 'Feeling good and positive';
      case MoodType.tiredLowEnergy:
        return 'Physical exhaustion';
      case MoodType.feelingDetermined:
        return 'Motivated and focused';
    }
  }

  /// Color associated with the mood (can be used for UI)
  String get colorHex {
    switch (this) {
      case MoodType.feelingStiff:
        return '#9E9E9E'; // Grey
      case MoodType.readyToLearn:
        return '#4CAF50'; // Green
      case MoodType.lowEnergy:
        return '#FF9800'; // Orange
      case MoodType.stressedAnxious:
        return '#F44336'; // Red
      case MoodType.relaxedWantChill:
        return '#2196F3'; // Blue
      case MoodType.happyPositive:
        return '#FFEB3B'; // Yellow
      case MoodType.tiredLowEnergy:
        return '#795548'; // Brown
      case MoodType.feelingDetermined:
        return '#9C27B0'; // Purple
    }
  }

  /// Category of the mood for grouping
  MoodCategory get category {
    switch (this) {
      case MoodType.feelingStiff:
        return MoodCategory.physical;
      case MoodType.readyToLearn:
        return MoodCategory.mindset;
      case MoodType.lowEnergy:
        return MoodCategory.energy;
      case MoodType.stressedAnxious:
        return MoodCategory.stress;
      case MoodType.relaxedWantChill:
        return MoodCategory.stress;
      case MoodType.happyPositive:
        return MoodCategory.emotional;
      case MoodType.tiredLowEnergy:
        return MoodCategory.energy;
      case MoodType.feelingDetermined:
        return MoodCategory.mindset;
    }
  }
}

/// Category for grouping moods
enum MoodCategory {
  physical,
  mental,
  emotional,
  energy,
  stress,
  mindset,
}

extension MoodCategoryExtension on MoodCategory {
  String get label {
    switch (this) {
      case MoodCategory.physical:
        return 'Physical';
      case MoodCategory.mental:
        return 'Mental';
      case MoodCategory.emotional:
        return 'Emotional';
      case MoodCategory.energy:
        return 'Energy';
      case MoodCategory.stress:
        return 'Stress';
      case MoodCategory.mindset:
        return 'Mindset';
    }
  }
}

extension StressLevelExtension on StressLevel {
  int toNumber() {
    switch (this) {
      case StressLevel.low:
        return 1;
      case StressLevel.medium:
        return 2;
      case StressLevel.high:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case StressLevel.low:
        return 'Low';
      case StressLevel.medium:
        return 'Medium';
      case StressLevel.high:
        return 'High';
    }
  }
}

extension EnergyLevelExtension on EnergyLevel {
  int toNumber() {
    switch (this) {
      case EnergyLevel.low:
        return 1;
      case EnergyLevel.medium:
        return 2;
      case EnergyLevel.high:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case EnergyLevel.low:
        return 'Low';
      case EnergyLevel.medium:
        return 'Medium';
      case EnergyLevel.high:
        return 'High';
    }
  }
}

extension FlexibilityLevelExtension on FlexibilityLevel {
  int toNumber() {
    switch (this) {
      case FlexibilityLevel.tight:
        return 1;
      case FlexibilityLevel.moderate:
        return 2;
      case FlexibilityLevel.flexible:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case FlexibilityLevel.tight:
        return 'Tight';
      case FlexibilityLevel.moderate:
        return 'Moderate';
      case FlexibilityLevel.flexible:
        return 'Flexible';
    }
  }
}

extension MentalFocusLevelExtension on MentalFocusLevel {
  int toNumber() {
    switch (this) {
      case MentalFocusLevel.scattered:
        return 1;
      case MentalFocusLevel.moderate:
        return 2;
      case MentalFocusLevel.focused:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case MentalFocusLevel.scattered:
        return 'Scattered';
      case MentalFocusLevel.moderate:
        return 'Moderate';
      case MentalFocusLevel.focused:
        return 'Focused';
    }
  }
}

// ============ MOOD HELPERS ============

/// Try to parse a MoodType from a string (for suitableMoods)
MoodType? tryParseMoodType(String? value) {
  if (value == null) return null;
  try {
    return MoodType.values.byName(value);
  } catch (_) {
    return null;
  }
}

/// Get emoji for a mood string
String getMoodEmoji(String? moodString) {
  final mood = tryParseMoodType(moodString);
  return mood?.emoji ?? '🧘';
}

/// Get label for a mood string
String getMoodLabel(String? moodString) {
  final mood = tryParseMoodType(moodString);
  return mood?.label ?? 'General';
}
