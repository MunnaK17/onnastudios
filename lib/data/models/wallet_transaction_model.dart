import 'app_enums.dart';

class WalletTransactionModel {
  const WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final WalletTransactionType type;
  final int amount;
  final String description;
  final DateTime createdAt;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: WalletTransactionType.values.byName(json['type'] as String),
      amount: json['amount'] as int,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
