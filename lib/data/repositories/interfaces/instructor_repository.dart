import '../../models/instructor_model.dart';

/// Repository interface for instructor operations.
abstract class InstructorRepository {
  /// Get all instructors.
  Future<List<InstructorModel>> getAllInstructors();

  /// Get an instructor by ID.
  Future<InstructorModel?> getInstructorById(String id);

  /// Search instructors by name or specialty.
  Future<List<InstructorModel>> searchInstructors(String query);

  /// Get instructors by specialty.
  Future<List<InstructorModel>> getInstructorsBySpecialty(String specialty);
}
