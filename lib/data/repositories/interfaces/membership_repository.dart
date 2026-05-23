import '../../models/membership_package_model.dart';

/// Repository interface for membership package operations.
abstract class MembershipRepository {
  /// Get all available membership packages.
  Future<List<MembershipPackageModel>> getAllPackages();

  /// Get a package by ID.
  Future<MembershipPackageModel?> getPackageById(String id);

  /// Get the popular/recommended package.
  Future<MembershipPackageModel?> getPopularPackage();

  /// Purchase a package.
  Future<void> purchasePackage(String packageId);

  /// Get active membership for current user.
  Future<MembershipPackageModel?> getActiveMembership();
}