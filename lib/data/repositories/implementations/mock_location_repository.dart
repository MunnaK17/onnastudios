import '../../models/studio_location_model.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/location_repository.dart';

/// Mock implementation of LocationRepository.
class MockLocationRepository implements LocationRepository {
  @override
  Future<List<StudioLocationModel>> getAllLocations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.studioLocations;
  }

  @override
  Future<StudioLocationModel?> getLocationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return MockOnnaData.studioLocations.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StudioLocationModel?> getMainLocation() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (MockOnnaData.studioLocations.isEmpty) return null;
    return MockOnnaData.studioLocations.first;
  }
}
