import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/credit_package_model.dart';
import '../../data/repositories/interfaces/package_repository.dart';
import '../../data/repositories/implementations/supabase_package_repository.dart';
import 'wallet_provider.dart';

/// Provider for PackageRepository instance.
final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  return SupabasePackageRepository();
});

/// Provider for all available credit packages.
final allPackagesProvider = FutureProvider<List<CreditPackageModel>>((ref) async {
  final repository = ref.watch(packageRepositoryProvider);
  return repository.getAllPackages();
});

/// Provider for featured credit packages.
final featuredPackagesProvider = FutureProvider<List<CreditPackageModel>>((ref) async {
  final repository = ref.watch(packageRepositoryProvider);
  return repository.getFeaturedPackages();
});

/// Provider for a single package by ID.
final packageByIdProvider = FutureProvider.family<CreditPackageModel?, String>((ref, id) async {
  final repository = ref.watch(packageRepositoryProvider);
  return repository.getPackageById(id);
});

/// Package purchase state notifier.
class PackagePurchaseNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> purchasePackage(String packageId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(packageRepositoryProvider);
      await repository.purchasePackage(packageId);

      // Refresh wallet data
      ref.invalidate(walletNotifierProvider);
      ref.invalidate(transactionHistoryProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(remainingCreditsProvider);
      ref.invalidate(walletSummaryProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// NotifierProvider for package purchase state.
final packagePurchaseNotifierProvider =
    NotifierProvider<PackagePurchaseNotifier, AsyncValue<void>>(() {
  return PackagePurchaseNotifier();
});
