import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_enums.dart';
import '../../models/yoga_class_model.dart';
import '../interfaces/class_repository.dart';

class SupabaseClassRepository implements ClassRepository {
  SupabaseClassRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  YogaClassModel _mapClass(Map<String, dynamic> data) {
    return YogaClassModel(
      id: data['id'] as String,
      title: data['title'] as String,
      category: ClassCategory.values.byName(data['category'] as String),
      description: (data['description'] as String?) ?? '',
      imageUrl: (data['image_url'] as String?) ?? '',
      durationMinutes: (data['duration_minutes'] as int?) ?? 0,
      intensity: ClassIntensity.values.byName(data['intensity'] as String),
      creditCost: (data['credit_cost'] as int?) ?? 1,
      instructorId: data['instructor_id'] as String,
      benefits: List<String>.from((data['benefits'] as List?) ?? const []),
      suitableMoods: List<String>.from((data['suitable_moods'] as List?) ?? const []),
    );
  }

  @override
  Future<List<YogaClassModel>> getAllClasses() async {
    final data = await _client.from('classes').select().order('title');
    return data.map(_mapClass).toList();
  }

  @override
  Future<YogaClassModel?> getClassById(String id) async {
    final data = await _client
        .from('classes')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data == null ? null : _mapClass(data);
  }

  @override
  Future<List<YogaClassModel>> searchClasses(String query) async {
    final data = await _client
        .from('classes')
        .select()
        .or('title.ilike.%$query%,description.ilike.%$query%')
        .order('title');
    return data.map(_mapClass).toList();
  }

  @override
  Future<List<YogaClassModel>> getClassesByCategory(
    ClassCategory category,
  ) async {
    final data = await _client
        .from('classes')
        .select()
        .eq('category', category.name)
        .order('title');
    return data.map(_mapClass).toList();
  }

  @override
  Future<List<YogaClassModel>> getClassesByIntensity(
    ClassIntensity intensity,
  ) async {
    final data = await _client
        .from('classes')
        .select()
        .eq('intensity', intensity.name)
        .order('title');
    return data.map(_mapClass).toList();
  }

  @override
  Future<List<YogaClassModel>> getFeaturedClasses() async {
    final data = await _client
        .from('classes')
        .select()
        .order('is_featured', ascending: false)
        .order('title')
        .limit(4);
    return data.map(_mapClass).toList();
  }

  @override
  Future<List<YogaClassModel>> getClassesByInstructorId(
    String instructorId,
  ) async {
    final data = await _client
        .from('classes')
        .select()
        .eq('instructor_id', instructorId)
        .order('title');
    return data.map(_mapClass).toList();
  }
}
