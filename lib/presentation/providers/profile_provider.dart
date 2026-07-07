import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/interfaces/profile_repository.dart';
import '../../data/repositories/implementations/supabase_profile_repository.dart';

/// Provider for ProfileRepository instance.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository();
});

/// Provider for current user profile.
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile();
});

/// Profile state notifier using Riverpod 3.x Notifier.
class ProfileNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() {
    Future.microtask(loadProfile);
    return const AsyncValue.loading();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? profilePhoto,
  }) async {
    try {
      final updatedProfile = await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            fullName: fullName,
            email: email,
            phone: phone,
            profilePhoto: profilePhoto,
          );
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      await ref.read(profileRepositoryProvider).updateProfilePhoto(photoUrl);
      await loadProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// NotifierProvider for profile state.
final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, AsyncValue<UserModel?>>(() {
      return ProfileNotifier();
    });
