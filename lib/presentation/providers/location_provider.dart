import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/studio_location_model.dart';
import '../../data/repositories/interfaces/location_repository.dart';
import '../../data/repositories/implementations/mock_location_repository.dart';

/// Provider for LocationRepository instance.
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return MockLocationRepository();
});

/// Provider for all locations.
final allLocationsProvider =
    FutureProvider<List<StudioLocationModel>>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.getAllLocations();
});

/// Provider for a single location by ID.
final locationByIdProvider =
    FutureProvider.family<StudioLocationModel?, String>((ref, id) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.getLocationById(id);
});

/// Provider for main location.
final mainLocationProvider =
    FutureProvider<StudioLocationModel?>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.getMainLocation();
});