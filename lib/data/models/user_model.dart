class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePhoto,
    required this.activeMembershipId,
    required this.remainingCredits,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String profilePhoto;
  final String? activeMembershipId;
  final int remainingCredits;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profilePhoto: json['profilePhoto'] as String,
      activeMembershipId: json['activeMembershipId'] as String?,
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
      'activeMembershipId': activeMembershipId,
      'remainingCredits': remainingCredits,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profilePhoto,
    String? activeMembershipId,
    int? remainingCredits,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      activeMembershipId: activeMembershipId ?? this.activeMembershipId,
      remainingCredits: remainingCredits ?? this.remainingCredits,
    );
  }
}
