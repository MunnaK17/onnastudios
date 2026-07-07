import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/instructor_model.dart';
import '../interfaces/instructor_repository.dart';

class SupabaseInstructorRepository implements InstructorRepository {
  SupabaseInstructorRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  InstructorModel _mapInstructor(Map<String, dynamic> data) {
    return InstructorModel(
      id: data['id'] as String,
      name: data['name'] as String,
      photoUrl: (data['photo_url'] as String?) ?? '',
      specialty: (data['specialty'] as String?) ?? '',
      bio: (data['bio'] as String?) ?? '',
      classIds: List<String>.from((data['class_ids'] as List?) ?? const []),
    );
  }

  @override
  Future<List<InstructorModel>> getAllInstructors() async {
    final data = await _client.from('instructors').select().order('name');
    return data.map(_mapInstructor).toList();
  }

  @override
  Future<InstructorModel?> getInstructorById(String id) async {
    final data = await _client
        .from('instructors')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data == null ? null : _mapInstructor(data);
  }

  @override
  Future<List<InstructorModel>> searchInstructors(String query) async {
    final data = await _client
        .from('instructors')
        .select()
        .or('name.ilike.%$query%,specialty.ilike.%$query%')
        .order('name');
    return data.map(_mapInstructor).toList();
  }

  @override
  Future<List<InstructorModel>> getInstructorsBySpecialty(
    String specialty,
  ) async {
    final data = await _client
        .from('instructors')
        .select()
        .ilike('specialty', '%$specialty%')
        .order('name');
    return data.map(_mapInstructor).toList();
  }
}
