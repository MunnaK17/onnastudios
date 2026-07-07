class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePhoto,
    required this.remainingCredits,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String profilePhoto;
  final int remainingCredits;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profilePhoto: json['profilePhoto'] as String,
      remainingCredits: json['remainingCredits'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profilePhoto': profilePhoto,
      'remainingCredits': remainingCredits,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profilePhoto,
    int? remainingCredits,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      remainingCredits: remainingCredits ?? this.remainingCredits,
    );
  }
}
