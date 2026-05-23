import '../../models/wallet_transaction_model.dart';

/// Repository interface for wallet/credit operations.
abstract class WalletRepository {
  /// Get remaining credits for current user.
  Future<int> getRemainingCredits();

  /// Get transaction history.
  Future<List<WalletTransactionModel>> getTransactionHistory();

  /// Get recent transactions.
  Future<List<WalletTransactionModel>> getRecentTransactions({int limit = 5});

  /// Add credits to wallet (after package purchase).
  Future<void> addCredits(int amount, String description);

  /// Deduct credits (after booking).
  Future<void> deductCredits(int amount, String description);

  /// Check if user has enough credits.
  Future<bool> hasEnoughCredits(int amount);
}