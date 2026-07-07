import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/interfaces/auth_repository.dart';
import '../../data/repositories/implementations/supabase_auth_repository.dart';
import '../../data/models/user_model.dart';
import 'wallet_provider.dart';
import 'booking_provider.dart';
import 'profile_provider.dart';
import 'notification_provider.dart';

/// Provider for AuthRepository — now backed by Supabase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

/// Provides the current logged-in user (or null).
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// Provides whether a valid Supabase session exists.
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.isLoggedIn();
});

// ──────────────────────────────────────────────
// Auth state notifier
// ──────────────────────────────────────────────

/// Represents the auth state: true = logged in, false = logged out.
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Initialise from real Supabase session on cold start.
    ref.read(isLoggedInProvider.future).then((loggedIn) {
      if (state != loggedIn) state = loggedIn;
    });
    return false;
  }

  /// Invalidate all user-specific providers to ensure fresh data
  /// after login, logout, or account switch.
  void _invalidateAllUserProviders() {
    // Wallet providers
    ref.invalidate(walletNotifierProvider);
    ref.invalidate(transactionHistoryProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(remainingCreditsProvider);
    ref.invalidate(walletSummaryProvider);

    // Booking providers
    ref.invalidate(bookingNotifierProvider);
    ref.invalidate(userBookingsProvider);
    ref.invalidate(upcomingBookingsProvider);
    ref.invalidate(pastBookingsProvider);

    // Profile providers
    ref.invalidate(profileNotifierProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(currentUserProvider);

    // Notification providers
    ref.invalidate(notificationNotifierProvider);
    ref.invalidate(allNotificationsProvider);
    ref.invalidate(unreadNotificationsProvider);
    ref.invalidate(unreadCountProvider);
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = true;
      // Invalidate all user-specific providers to load new user's data
      _invalidateAllUserProviders();
    } catch (e) {
      // Reset state on login failure
      state = false;
      rethrow; // Re-throw to let UI handle the error
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            fullName: fullName,
            email: email,
            phone: phone,
            password: password,
          );
      state = true;
      // Invalidate all user-specific providers to load new user's data
      _invalidateAllUserProviders();
    } catch (e) {
      // Reset state on registration failure
      state = false;
      rethrow; // Re-throw to let UI handle the error
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = false;
    // Invalidate all user-specific providers to clear old user's data
    _invalidateAllUserProviders();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
