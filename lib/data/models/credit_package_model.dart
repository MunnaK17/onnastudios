class CreditPackageModel {
  const CreditPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.price,
    required this.bonusCredits,
    required this.isFeatured,
    required this.validDays,
  });

  final String id;
  final String name;
  final String description;
  final int credits;
  final double price;
  final int bonusCredits;
  final bool isFeatured;
  final int validDays;

  /// Total credits including bonus
  int get totalCredits => credits + bonusCredits;

  /// Formatted price string
  String get formattedPrice => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';

  factory CreditPackageModel.fromJson(Map<String, dynamic> json) {
    return CreditPackageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      credits: json['credits'] as int,
      price: (json['price'] as num).toDouble(),
      bonusCredits: (json['bonus_credits'] as int?) ?? 0,
      isFeatured: (json['is_featured'] as bool?) ?? false,
      validDays: (json['valid_days'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'credits': credits,
      'price': price,
      'bonus_credits': bonusCredits,
      'is_featured': isFeatured,
      'valid_days': validDays,
    };
  }
}
