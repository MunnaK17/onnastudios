import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_model.dart';
import '../interfaces/auth_repository.dart';

/// Live implementation of [AuthRepository] backed by Supabase Auth
/// and the public.profiles table.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  /// Fetch the profiles row for [userId] and map it to [UserModel].
  /// Returns null if profile doesn't exist yet.
  Future<UserModel?> _fetchProfile(String userId, String email) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (data == null) {
        // Profile doesn't exist yet, return user data from auth
        return UserModel(
          id: userId,
          fullName: email.split('@').first, // Fallback to email prefix
          email: email,
          phone: '',
          profilePhoto: '',
          remainingCredits: 0,
        );
      }

      return UserModel(
        id: userId,
        fullName: (data['full_name'] as String?) ?? email.split('@').first,
        email: email,
        phone: (data['phone'] as String?) ?? '',
        profilePhoto: (data['profile_photo'] as String?) ?? '',
        remainingCredits: (data['remaining_credits'] as int?) ?? 0,
      );
    } catch (e) {
      // If fetching profile fails, return user from auth session
      final authUser = _client.auth.currentUser;
      if (authUser != null) {
        return UserModel(
          id: authUser.id,
          fullName: (authUser.userMetadata?['full_name'] as String?) ?? email.split('@').first,
          email: email,
          phone: (authUser.userMetadata?['phone'] as String?) ?? '',
          profilePhoto: '',
          remainingCredits: 0,
        );
      }
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // AuthRepository interface
  // ──────────────────────────────────────────────

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return await _fetchProfile(user.id, user.email ?? '');
  }

  @override
  Future<bool> isLoggedIn() async {
    final session = _client.auth.currentSession;
    if (session == null) return false;
    // Also check if user data exists
    return _client.auth.currentUser != null;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Login failed: no user returned.');
      }

      // Small delay to ensure session is established
      await Future.delayed(const Duration(milliseconds: 500));

      final profile = await _fetchProfile(user.id, user.email ?? email);
      if (profile == null) {
        throw Exception('Login failed: unable to fetch user profile.');
      }

      return profile;
    } on AuthException catch (e) {
      throw Exception(_friendlyAuthError(e.message));
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );

      final user = response.user;
      if (user == null) {
        throw Exception(
          'Registration failed. Please try again.',
        );
      }

      // Small delay to ensure session is established
      await Future.delayed(const Duration(milliseconds: 500));

      // Try to fetch the profile (may be created by trigger)
      var profile = await _fetchProfile(user.id, email);

      // If profile doesn't exist or doesn't have proper name, create/update it
      if (profile == null || profile.fullName == email.split('@').first) {
        try {
          // Try to insert first (in case trigger didn't create it)
          await _client.from('profiles').insert({
            'id': user.id,
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'remaining_credits': 10, // Welcome bonus
          });

          profile = UserModel(
            id: user.id,
            fullName: fullName,
            email: email,
            phone: phone,
            profilePhoto: '',
            remainingCredits: 10,
          );
        } catch (insertError) {
          // If insert fails (profile already exists), try to update
          try {
            await _client
                .from('profiles')
                .update({
                  'full_name': fullName,
                  'phone': phone,
                })
                .eq('id', user.id);
          } catch (_) {
            // Ignore update errors
          }

          profile = UserModel(
            id: user.id,
            fullName: fullName,
            email: email,
            phone: phone,
            profilePhoto: '',
            remainingCredits: 0,
          );
        }
      }

      return profile;
    } on AuthException catch (e) {
      throw Exception(_friendlyAuthError(e.message));
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(_friendlyAuthError(e.message));
    }
  }

  // ──────────────────────────────────────────────
  // Error messages
  // ──────────────────────────────────────────────

  String _friendlyAuthError(String raw) {
    // Convert Supabase error codes to friendly messages
    if (raw.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials.';
    }
    if (raw.contains('User already registered')) {
      return 'This email is already registered. Try signing in instead.';
    }
    if (raw.contains('Password should be at least')) {
      return 'Password must be at least 6 characters.';
    }
    if (raw.contains('Unable to validate email address')) {
      return 'Please enter a valid email address.';
    }
    if (raw.contains('Email not confirmed')) {
      return 'Please check your email and confirm your account, or contact support.';
    }
    // Return original message if no match
    return raw;
  }
}
