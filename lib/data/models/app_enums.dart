enum ClassCategory {
  yogaFlow,
  pilates,
  meditation,
  breathwork,
  strength,
  restorative,
}

enum ClassIntensity { low, medium, high }

enum BookingStatus { upcoming, completed, cancelled, expired, noShow }

enum WalletTransactionType { credit, debit }

enum NotificationType {
  classReminder,
  bookingConfirmed,
  creditRunningLow,
  promotion,
  scheduleUpdate,
}

// ============ MOOD TRACKER ENUMS ============

/// Main mood options for the mood tracker feature
/// These moods are designed to capture the user's state before/during/after yoga class
enum MoodType {
  /// Feeling Stiff - Body feels tight or inflexible
  feelingStiff,

  /// Ready to Learn - Eager to learn and improve
  readyToLearn,

  /// Low Energy / Unmotivated - Feeling tired or lacking motivation
  lowEnergy,

  /// Stressed / Anxious - Feeling worried or tense
  stressedAnxious,

  /// Relaxed / Want to Chill - Feeling calm and relaxed
  relaxedWantChill,

  /// Happy / Positive Mood - Feeling good and positive
  happyPositive,

  /// Tired / Low Energy - Physical exhaustion
  tiredLowEnergy,

  /// Feeling Determined - Motivated and focused
  feelingDetermined,
}

enum StressLevel { low, medium, high }

enum EnergyLevel { low, medium, high }

enum FlexibilityLevel { tight, moderate, flexible }

enum MentalFocusLevel { scattered, moderate, focused }

enum SleepQuality { poor, fair, good }

enum TensionArea {
  neck,
  shoulders,
  upperBack,
  lowerBack,
  hips,
  legs,
  fullBody,
}
