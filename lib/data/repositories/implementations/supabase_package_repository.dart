import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/credit_package_model.dart';
import '../interfaces/package_repository.dart';

class SupabasePackageRepository implements PackageRepository {
  SupabasePackageRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  CreditPackageModel _mapPackage(Map<String, dynamic> data) {
    return CreditPackageModel(
      id: data['id'] as String,
      name: data['name'] as String,
      description: (data['description'] as String?) ?? '',
      credits: data['credits'] as int,
      price: (data['price'] as num).toDouble(),
      bonusCredits: (data['bonus_credits'] as int?) ?? 0,
      isFeatured: (data['is_featured'] as bool?) ?? false,
      validDays: (data['valid_days'] as int?) ?? 0,
    );
  }

  @override
  Future<List<CreditPackageModel>> getAllPackages() async {
    final data = await _client
        .from('credit_packages')
        .select()
        .eq('is_active', true)
        .order('price');
    return data.map(_mapPackage).toList();
  }

  @override
  Future<List<CreditPackageModel>> getFeaturedPackages() async {
    final data = await _client
        .from('credit_packages')
        .select()
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('price');
    return data.map(_mapPackage).toList();
  }

  @override
  Future<CreditPackageModel?> getPackageById(String id) async {
    final data = await _client
        .from('credit_packages')
        .select()
        .eq('id', id)
        .eq('is_active', true)
        .maybeSingle();
    return data == null ? null : _mapPackage(data);
  }

  @override
  Future<void> purchasePackage(String packageId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    // Use server-side function for atomic purchase
    await _client.rpc('purchase_credit_package', params: {'p_package_id': packageId});
  }

}
