import '../../models/user_model.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/profile_repository.dart';

/// Mock implementation of ProfileRepository.
class MockProfileRepository implements ProfileRepository {
  UserModel _user = MockOnnaData.sampleUser;

  @override
  Future<UserModel?> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _user;
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? profilePhoto,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _user = _user.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      profilePhoto: profilePhoto,
    );
    return _user;
  }

  @override
  Future<String> updateProfilePhoto(String photoUrl) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _user = _user.copyWith(profilePhoto: photoUrl);
    return photoUrl;
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = MockOnnaData.sampleUser;
  }
}
