import '../../models/credit_package_model.dart';

/// Repository interface for credit packages.
abstract class PackageRepository {
  /// Get all available credit packages.
  Future<List<CreditPackageModel>> getAllPackages();

  /// Get featured credit packages only.
  Future<List<CreditPackageModel>> getFeaturedPackages();

  /// Get a single package by ID.
  Future<CreditPackageModel?> getPackageById(String id);

  /// Purchase a credit package (adds credits to user wallet).
  Future<void> purchasePackage(String packageId);
}
