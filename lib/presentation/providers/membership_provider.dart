import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/membership_package_model.dart';
import '../../data/repositories/interfaces/membership_repository.dart';
import '../../data/repositories/implementations/mock_membership_repository.dart';

/// Provider for MembershipRepository instance.
final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  return MockMembershipRepository();
});

/// Provider for all packages.
final allPackagesProvider = FutureProvider<List<MembershipPackageModel>>((
  ref,
) async {
  final repository = ref.watch(membershipRepositoryProvider);
  return repository.getAllPackages();
});

/// Provider for a single package by ID.
final packageByIdProvider =
    FutureProvider.family<MembershipPackageModel?, String>((ref, id) async {
      final repository = ref.watch(membershipRepositoryProvider);
      return repository.getPackageById(id);
    });

/// Provider for popular package.
final popularPackageProvider = FutureProvider<MembershipPackageModel?>((
  ref,
) async {
  final repository = ref.watch(membershipRepositoryProvider);
  return repository.getPopularPackage();
});

/// Provider for active membership.
final activeMembershipProvider = FutureProvider<MembershipPackageModel?>((
  ref,
) async {
  final repository = ref.watch(membershipRepositoryProvider);
  return repository.getActiveMembership();
});

/// Membership state notifier using Riverpod 3.x Notifier.
class MembershipNotifier
    extends Notifier<AsyncValue<List<MembershipPackageModel>>> {
  @override
  AsyncValue<List<MembershipPackageModel>> build() =>
      const AsyncValue.loading();

  Future<void> loadPackages() async {
    state = const AsyncValue.loading();
    try {
      final packages = await ref
          .read(membershipRepositoryProvider)
          .getAllPackages();
      state = AsyncValue.data(packages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> purchasePackage(String packageId) async {
    try {
      await ref.read(membershipRepositoryProvider).purchasePackage(packageId);
      await loadPackages();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// NotifierProvider for membership state.
final membershipNotifierProvider =
    NotifierProvider<
      MembershipNotifier,
      AsyncValue<List<MembershipPackageModel>>
    >(() {
      return MembershipNotifier();
    });
