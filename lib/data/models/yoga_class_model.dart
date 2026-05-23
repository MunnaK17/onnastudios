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

  factory YogaClassModel.fromJson(Map<String, dynamic> json) {
    return YogaClassModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: ClassCategory.values.byName(json['category'] as String),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      durationMinutes: json['durationMinutes'] as int,
      intensity: ClassIntensity.values.byName(json['intensity'] as String),
      creditCost: json['creditCost'] as int,
      instructorId: json['instructorId'] as String,
      benefits: List<String>.from(json['benefits'] as List),
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
    };
  }
}
