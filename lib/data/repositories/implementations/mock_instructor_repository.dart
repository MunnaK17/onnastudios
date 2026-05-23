import '../../models/instructor_model.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/instructor_repository.dart';

/// Mock implementation of InstructorRepository.
class MockInstructorRepository implements InstructorRepository {
  @override
  Future<List<InstructorModel>> getAllInstructors() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.instructors;
  }

  @override
  Future<InstructorModel?> getInstructorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return MockOnnaData.instructors.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<InstructorModel>> searchInstructors(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    return MockOnnaData.instructors.where((i) {
      return i.name.toLowerCase().contains(lowerQuery) ||
          i.specialty.toLowerCase().contains(lowerQuery) ||
          i.bio.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<InstructorModel>> getInstructorsBySpecialty(
    String specialty,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.instructors
        .where(
          (i) => i.specialty.toLowerCase().contains(specialty.toLowerCase()),
        )
        .toList();
  }
}
