import '../../models/yoga_class_model.dart';
import '../../models/app_enums.dart';

/// Repository interface for yoga class operations.
abstract class ClassRepository {
  /// Get all available classes.
  Future<List<YogaClassModel>> getAllClasses();

  /// Get a class by its ID.
  Future<YogaClassModel?> getClassById(String id);

  /// Search classes by query.
  Future<List<YogaClassModel>> searchClasses(String query);

  /// Filter classes by category.
  Future<List<YogaClassModel>> getClassesByCategory(ClassCategory category);

  /// Filter classes by intensity.
  Future<List<YogaClassModel>> getClassesByIntensity(ClassIntensity intensity);

  /// Get featured/recommended classes.
  Future<List<YogaClassModel>> getFeaturedClasses();

  /// Filter classes by instructor ID.
  Future<List<YogaClassModel>> getClassesByInstructorId(String instructorId);
}
