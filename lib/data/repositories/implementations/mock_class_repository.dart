import '../../models/yoga_class_model.dart';
import '../../models/app_enums.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/class_repository.dart';

/// Mock implementation of ClassRepository.
class MockClassRepository implements ClassRepository {
  @override
  Future<List<YogaClassModel>> getAllClasses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.yogaClasses;
  }

  @override
  Future<YogaClassModel?> getClassById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return MockOnnaData.yogaClasses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<YogaClassModel>> searchClasses(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    return MockOnnaData.yogaClasses.where((c) {
      return c.title.toLowerCase().contains(lowerQuery) ||
          c.category.name.toLowerCase().contains(lowerQuery) ||
          c.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<YogaClassModel>> getClassesByCategory(
    ClassCategory category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.yogaClasses
        .where((c) => c.category == category)
        .toList();
  }

  @override
  Future<List<YogaClassModel>> getClassesByIntensity(
    ClassIntensity intensity,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.yogaClasses
        .where((c) => c.intensity == intensity)
        .toList();
  }

  @override
  Future<List<YogaClassModel>> getFeaturedClasses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Return first 4 classes as featured
    return MockOnnaData.yogaClasses.take(4).toList();
  }
}