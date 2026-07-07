import 'app_enums.dart';

class MoodEntryModel {
  const MoodEntryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.stressLevel,
    required this.energyLevel,
    required this.flexibility,
    required this.mentalFocus,
    this.sleepQuality,
    this.tensionAreas,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final DateTime date;
  final MoodType mood;
  final StressLevel stressLevel;
  final EnergyLevel energyLevel;
  final FlexibilityLevel flexibility;
  final MentalFocusLevel mentalFocus;
  final SleepQuality? sleepQuality;
  final List<TensionArea>? tensionAreas;
  final String? notes;
  final DateTime createdAt;

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) {
    return MoodEntryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: MoodType.values.byName(json['mood'] as String),
      stressLevel: StressLevel.values.byName(json['stressLevel'] as String),
      energyLevel: EnergyLevel.values.byName(json['energyLevel'] as String),
      flexibility: FlexibilityLevel.values.byName(json['flexibility'] as String),
      mentalFocus: MentalFocusLevel.values.byName(json['mentalFocus'] as String),
      sleepQuality: json['sleepQuality'] != null
          ? SleepQuality.values.byName(json['sleepQuality'] as String)
          : null,
      tensionAreas: json['tensionAreas'] != null
          ? (json['tensionAreas'] as List)
              .map((e) => TensionArea.values.byName(e as String))
              .toList()
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String().split('T').first,
      'mood': mood.name,
      'stressLevel': stressLevel.name,
      'energyLevel': energyLevel.name,
      'flexibility': flexibility.name,
      'mentalFocus': mentalFocus.name,
      if (sleepQuality != null) 'sleepQuality': sleepQuality!.name,
      if (tensionAreas != null)
        'tensionAreas': tensionAreas!.map((e) => e.name).toList(),
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MoodEntryModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MoodType? mood,
    StressLevel? stressLevel,
    EnergyLevel? energyLevel,
    FlexibilityLevel? flexibility,
    MentalFocusLevel? mentalFocus,
    SleepQuality? sleepQuality,
    List<TensionArea>? tensionAreas,
    String? notes,
    DateTime? createdAt,
  }) {
    return MoodEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      stressLevel: stressLevel ?? this.stressLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      flexibility: flexibility ?? this.flexibility,
      mentalFocus: mentalFocus ?? this.mentalFocus,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      tensionAreas: tensionAreas ?? this.tensionAreas,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MoodSummaryModel {
  const MoodSummaryModel({
    required this.mood,
    required this.stressLevel,
    required this.energyLevel,
    required this.flexibility,
    required this.mentalFocus,
    this.sleepQuality,
    this.tensionAreas,
    this.notes,
  });

  final MoodType mood;
  final StressLevel stressLevel;
  final EnergyLevel energyLevel;
  final FlexibilityLevel flexibility;
  final MentalFocusLevel mentalFocus;
  final SleepQuality? sleepQuality;
  final List<TensionArea>? tensionAreas;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'mood': mood.name,
      'stressLevel': stressLevel.name,
      'energyLevel': energyLevel.name,
      'flexibility': flexibility.name,
      'mentalFocus': mentalFocus.name,
      if (sleepQuality != null) 'sleepQuality': sleepQuality!.name,
      if (tensionAreas != null)
        'tensionAreas': tensionAreas!.map((e) => e.name).toList(),
      if (notes != null) 'notes': notes,
    };
  }

  factory MoodSummaryModel.fromJson(Map<String, dynamic> json) {
    return MoodSummaryModel(
      mood: MoodType.values.byName(json['mood'] as String),
      stressLevel: StressLevel.values.byName(json['stressLevel'] as String),
      energyLevel: EnergyLevel.values.byName(json['energyLevel'] as String),
      flexibility: FlexibilityLevel.values.byName(json['flexibility'] as String),
      mentalFocus: MentalFocusLevel.values.byName(json['mentalFocus'] as String),
      sleepQuality: json['sleepQuality'] != null
          ? SleepQuality.values.byName(json['sleepQuality'] as String)
          : null,
      tensionAreas: json['tensionAreas'] != null
          ? (json['tensionAreas'] as List)
              .map((e) => TensionArea.values.byName(e as String))
              .toList()
          : null,
      notes: json['notes'] as String?,
    );
  }
}
