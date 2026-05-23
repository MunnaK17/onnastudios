class StudioLocationModel {
  const StudioLocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.openingHours,
  });

  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String phone;
  final String openingHours;

  factory StudioLocationModel.fromJson(Map<String, dynamic> json) {
    return StudioLocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      openingHours: json['openingHours'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'openingHours': openingHours,
    };
  }
}
