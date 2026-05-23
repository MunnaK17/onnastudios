import '../../models/user_model.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/auth_repository.dart';

/// Mock implementation of AuthRepository.
class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser ?? MockOnnaData.sampleUser;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = MockOnnaData.sampleUser;
    _isLoggedIn = true;
    return _currentUser!;
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = MockOnnaData.sampleUser.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
    );
    _isLoggedIn = true;
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _isLoggedIn = false;
  }

  @override
  Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _isLoggedIn || _currentUser != null;
  }
}
