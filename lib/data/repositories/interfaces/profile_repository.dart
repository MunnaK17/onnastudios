import '../../models/user_model.dart';

/// Repository interface for user profile operations.
abstract class ProfileRepository {
  /// Get current user profile.
  Future<UserModel?> getProfile();

  /// Update user profile.
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? profilePhoto,
  });

  /// Update profile photo.
  Future<String> updateProfilePhoto(String photoUrl);

  /// Delete user account.
  Future<void> deleteAccount();
}
