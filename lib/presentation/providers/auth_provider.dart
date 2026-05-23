import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/interfaces/auth_repository.dart';
import '../../data/repositories/implementations/mock_auth_repository.dart';

/// Provider for AuthRepository instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

/// Provider for checking if user is logged in.
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.isLoggedIn();
});

/// Provider for current user.
final currentUserProvider = FutureProvider((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// Auth state notifier using Riverpod 3.x Notifier.
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> login({required String email, required String password}) async {
    state = true;
    await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
  }

  Future<void> logout() async {
    state = false;
    await ref.read(authRepositoryProvider).logout();
  }
}

/// NotifierProvider for auth state.
final authNotifierProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
