import '../../models/studio_location_model.dart';

/// Repository interface for studio location operations.
abstract class LocationRepository {
  /// Get all studio locations.
  Future<List<StudioLocationModel>> getAllLocations();

  /// Get a location by ID.
  Future<StudioLocationModel?> getLocationById(String id);

  /// Get the main/primary studio location.
  Future<StudioLocationModel?> getMainLocation();
}
