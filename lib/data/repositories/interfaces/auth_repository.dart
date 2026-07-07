import '../../models/user_model.dart';

/// Repository interface for authentication and user operations.
abstract class AuthRepository {
  /// Get the currently logged-in user.
  Future<UserModel?> getCurrentUser();

  /// Login with email and password.
  Future<UserModel> login({required String email, required String password});

  /// Register a new user.
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  /// Logout the current user.
  Future<void> logout();

  /// Send a password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Check if user is logged in.
  Future<bool> isLoggedIn();
}
