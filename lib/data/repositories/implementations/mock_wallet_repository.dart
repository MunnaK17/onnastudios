import '../../models/wallet_transaction_model.dart';
import '../../models/app_enums.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/wallet_repository.dart';

/// Mock implementation of WalletRepository.
class MockWalletRepository implements WalletRepository {
  int _credits = MockOnnaData.sampleUser.remainingCredits;
  final List<WalletTransactionModel> _transactions =
      List<WalletTransactionModel>.from(MockOnnaData.walletTransactions);

  @override
  Future<int> getRemainingCredits() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _credits;
  }

  @override
  Future<List<WalletTransactionModel>> getTransactionHistory() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List<WalletTransactionModel>.from(_transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<WalletTransactionModel>> getRecentTransactions({
    int limit = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final sorted = List<WalletTransactionModel>.from(_transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  @override
  Future<void> addCredits(int amount, String description) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _credits += amount;
    _transactions.insert(
      0,
      WalletTransactionModel(
        id: 'wallet-${DateTime.now().millisecondsSinceEpoch}',
        userId: MockOnnaData.sampleUser.id,
        type: WalletTransactionType.credit,
        amount: amount,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deductCredits(int amount, String description) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _credits -= amount;
    _transactions.insert(
      0,
      WalletTransactionModel(
        id: 'wallet-${DateTime.now().millisecondsSinceEpoch}',
        userId: MockOnnaData.sampleUser.id,
        type: WalletTransactionType.debit,
        amount: amount,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<bool> hasEnoughCredits(int amount) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _credits >= amount;
  }
}