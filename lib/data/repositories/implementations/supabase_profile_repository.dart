import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_model.dart';
import '../interfaces/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  User get _currentUser {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }
    return user;
  }

  UserModel _mapProfile(Map<String, dynamic> data, String email) {
    return UserModel(
      id: data['id'] as String,
      fullName: (data['full_name'] as String?) ?? '',
      email: email,
      phone: (data['phone'] as String?) ?? '',
      profilePhoto: (data['profile_photo'] as String?) ?? '',
      remainingCredits: (data['remaining_credits'] as int?) ?? 0,
    );
  }

  @override
  Future<UserModel?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single()
        .timeout(const Duration(seconds: 10));

    return _mapProfile(data, user.email ?? '');
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? profilePhoto,
  }) async {
    final user = _currentUser;
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (profilePhoto != null) updates['profile_photo'] = profilePhoto;

    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', user.id);
    }

    if (email != null && email != user.email) {
      await _client.auth.updateUser(UserAttributes(email: email));
    }

    final updated = await getProfile();
    if (updated == null) {
      throw Exception('Profile not found.');
    }
    return updated;
  }

  @override
  Future<String> updateProfilePhoto(String photoUrl) async {
    final user = _currentUser;
    await _client
        .from('profiles')
        .update({'profile_photo': photoUrl})
        .eq('id', user.id);
    return photoUrl;
  }

  @override
  Future<void> deleteAccount() async {
    throw UnimplementedError('Account deletion requires a server-side action.');
  }
}
