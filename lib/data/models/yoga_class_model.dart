import 'app_enums.dart';

class YogaClassModel {
  const YogaClassModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.durationMinutes,
    required this.intensity,
    required this.creditCost,
    required this.instructorId,
    required this.benefits,
    this.suitableMoods = const [],
  });

  final String id;
  final String title;
  final ClassCategory category;
  final String description;
  final String imageUrl;
  final int durationMinutes;
  final ClassIntensity intensity;
  final int creditCost;
  final String instructorId;
  final List<String> benefits;
  /// Moods that this class is suitable for
  /// Example: ["feelingStiff", "lowEnergy", "stressedAnxious"]
  final List<String> suitableMoods;

  factory YogaClassModel.fromJson(Map<String, dynamic> json) {
    return YogaClassModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: ClassCategory.values.byName(json['category'] as String),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? json['duration_minutes'] as int,
      intensity: ClassIntensity.values.byName(json['intensity'] as String),
      creditCost: json['creditCost'] as int? ?? json['credit_cost'] as int,
      instructorId: json['instructorId'] as String? ?? json['instructor_id'] as String,
      benefits: List<String>.from(json['benefits'] as List? ?? []),
      suitableMoods: json['suitable_moods'] != null
          ? List<String>.from(json['suitable_moods'] as List)
          : (json['suitableMoods'] != null
              ? List<String>.from(json['suitableMoods'] as List)
              : []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'description': description,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
      'intensity': intensity.name,
      'creditCost': creditCost,
      'instructorId': instructorId,
      'benefits': benefits,
      'suitableMoods': suitableMoods,
    };
  }

  YogaClassModel copyWith({
    String? id,
    String? title,
    ClassCategory? category,
    String? description,
    String? imageUrl,
    int? durationMinutes,
    ClassIntensity? intensity,
    int? creditCost,
    String? instructorId,
    List<String>? benefits,
    List<String>? suitableMoods,
  }) {
    return YogaClassModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      creditCost: creditCost ?? this.creditCost,
      instructorId: instructorId ?? this.instructorId,
      benefits: benefits ?? this.benefits,
      suitableMoods: suitableMoods ?? this.suitableMoods,
    );
  }
}
