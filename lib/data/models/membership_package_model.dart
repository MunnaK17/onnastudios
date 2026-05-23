class MembershipPackageModel {
  const MembershipPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.credits,
    required this.validityDays,
    required this.benefits,
    required this.isPopular,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final int? credits;
  final int validityDays;
  final List<String> benefits;
  final bool isPopular;

  bool get hasUnlimitedCredits => credits == null;

  factory MembershipPackageModel.fromJson(Map<String, dynamic> json) {
    return MembershipPackageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      credits: json['credits'] as int?,
      validityDays: json['validityDays'] as int,
      benefits: List<String>.from(json['benefits'] as List),
      isPopular: json['isPopular'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'credits': credits,
      'validityDays': validityDays,
      'benefits': benefits,
      'isPopular': isPopular,
    };
  }
}
