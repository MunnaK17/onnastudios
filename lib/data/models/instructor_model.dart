class InstructorModel {
  const InstructorModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.specialty,
    required this.bio,
    required this.classIds,
  });

  final String id;
  final String name;
  final String photoUrl;
  final String specialty;
  final String bio;
  final List<String> classIds;

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String,
      specialty: json['specialty'] as String,
      bio: json['bio'] as String,
      classIds: List<String>.from(json['classIds'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'specialty': specialty,
      'bio': bio,
      'classIds': classIds,
    };
  }
}
