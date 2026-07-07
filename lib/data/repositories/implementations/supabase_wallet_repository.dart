import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_enums.dart';
import '../../models/wallet_transaction_model.dart';
import '../interfaces/wallet_repository.dart';

class SupabaseWalletRepository implements WalletRepository {
  SupabaseWalletRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }
    return user.id;
  }

  WalletTransactionModel _mapTransaction(Map<String, dynamic> data) {
    return WalletTransactionModel(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      type: WalletTransactionType.values.byName(data['type'] as String),
      amount: data['amount'] as int,
      description: (data['description'] as String?) ?? '',
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  bool _isMissingTransactionsTable(Object error) {
    return error is PostgrestException &&
        (error.code == '42P01' ||
            error.message.contains('wallet_transactions'));
  }

  @override
  Future<int> getRemainingCredits() async {
    final userId = _currentUserId;
    final data = await _client
        .from('profiles')
        .select('remaining_credits')
        .eq('id', userId)
        .single()
        .timeout(const Duration(seconds: 10));

    return (data['remaining_credits'] as int?) ?? 0;
  }

  @override
  Future<List<WalletTransactionModel>> getTransactionHistory() async {
    try {
      final userId = _currentUserId;
      final data = await _client
          .from('wallet_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      return data.map(_mapTransaction).toList();
    } catch (error) {
      if (_isMissingTransactionsTable(error)) return const [];
      rethrow;
    }
  }

  @override
  Future<List<WalletTransactionModel>> getRecentTransactions({
    int limit = 5,
  }) async {
    try {
      final userId = _currentUserId;
      final data = await _client
          .from('wallet_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit)
          .timeout(const Duration(seconds: 10));

      return data.map(_mapTransaction).toList();
    } catch (error) {
      if (_isMissingTransactionsTable(error)) return const [];
      rethrow;
    }
  }

  @override
  Future<void> addCredits(int amount, String description) async {
    final userId = _currentUserId;
    final credits = await getRemainingCredits();
    await _client
        .from('profiles')
        .update({'remaining_credits': credits + amount})
        .eq('id', userId);
    await _insertTransaction(
      userId: userId,
      type: WalletTransactionType.credit,
      amount: amount,
      description: description,
    );
  }

  @override
  Future<void> deductCredits(int amount, String description) async {
    final userId = _currentUserId;
    final credits = await getRemainingCredits();
    if (credits < amount) {
      throw Exception('Insufficient credits.');
    }

    await _client
        .from('profiles')
        .update({'remaining_credits': credits - amount})
        .eq('id', userId);
    await _insertTransaction(
      userId: userId,
      type: WalletTransactionType.debit,
      amount: amount,
      description: description,
    );
  }

  Future<void> _insertTransaction({
    required String userId,
    required WalletTransactionType type,
    required int amount,
    required String description,
  }) async {
    try {
      await _client.from('wallet_transactions').insert({
        'user_id': userId,
        'type': type.name,
        'amount': amount,
        'description': description,
      });
    } catch (error) {
      if (_isMissingTransactionsTable(error)) return;
      rethrow;
    }
  }

  @override
  Future<bool> hasEnoughCredits(int amount) async {
    final credits = await getRemainingCredits();
    return credits >= amount;
  }
}
