import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/wallet_transaction_model.dart';
import '../../data/repositories/interfaces/wallet_repository.dart';
import '../../data/repositories/implementations/mock_wallet_repository.dart';

/// Provider for WalletRepository instance.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return MockWalletRepository();
});

/// Provider for remaining credits.
final remainingCreditsProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getRemainingCredits();
});

/// Provider for transaction history.
final transactionHistoryProvider =
    FutureProvider<List<WalletTransactionModel>>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getTransactionHistory();
});

/// Provider for recent transactions with limit.
final recentTransactionsProvider =
    FutureProvider.family<List<WalletTransactionModel>, int>(
        (ref, limit) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getRecentTransactions(limit: limit);
});

/// Wallet summary state.
class WalletSummary {
  final int remainingCredits;
  final List<WalletTransactionModel> recentTransactions;
  final bool hasEnoughCredits;

  const WalletSummary({
    required this.remainingCredits,
    required this.recentTransactions,
    required this.hasEnoughCredits,
  });
}

/// Provider for wallet summary.
final walletSummaryProvider = FutureProvider<WalletSummary>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  final credits = await repository.getRemainingCredits();
  final transactions = await repository.getRecentTransactions(limit: 5);

  return WalletSummary(
    remainingCredits: credits,
    recentTransactions: transactions,
    hasEnoughCredits: credits > 0,
  );
});

/// Wallet state notifier using Riverpod 3.x Notifier.
class WalletNotifier extends Notifier<AsyncValue<WalletSummary>> {
  @override
  AsyncValue<WalletSummary> build() => const AsyncValue.loading();

  Future<void> loadWallet() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(walletRepositoryProvider);
      final credits = await repository.getRemainingCredits();
      final transactions = await repository.getRecentTransactions(limit: 5);

      state = AsyncValue.data(WalletSummary(
        remainingCredits: credits,
        recentTransactions: transactions,
        hasEnoughCredits: credits > 0,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deductCredits(int amount, String description) async {
    try {
      await ref.read(walletRepositoryProvider).deductCredits(amount, description);
      await loadWallet();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCredits(int amount, String description) async {
    try {
      await ref.read(walletRepositoryProvider).addCredits(amount, description);
      await loadWallet();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// NotifierProvider for wallet state.
final walletNotifierProvider =
    NotifierProvider<WalletNotifier, AsyncValue<WalletSummary>>(() {
  return WalletNotifier();
});