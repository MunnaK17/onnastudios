import '../../models/membership_package_model.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/membership_repository.dart';

/// Mock implementation of MembershipRepository.
class MockMembershipRepository implements MembershipRepository {
  String? _activeMembershipId = MockOnnaData.sampleUser.activeMembershipId;

  @override
  Future<List<MembershipPackageModel>> getAllPackages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.membershipPackages;
  }

  @override
  Future<MembershipPackageModel?> getPackageById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return MockOnnaData.membershipPackages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<MembershipPackageModel?> getPopularPackage() async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return MockOnnaData.membershipPackages
          .firstWhere((p) => p.isPopular);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> purchasePackage(String packageId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _activeMembershipId = packageId;
  }

  @override
  Future<MembershipPackageModel?> getActiveMembership() async {
    if (_activeMembershipId == null) return null;
    return getPackageById(_activeMembershipId!);
  }
}