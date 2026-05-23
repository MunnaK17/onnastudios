import 'app_enums.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.classId,
    required this.status,
    required this.qrCodeValue,
    required this.bookedAt,
  });

  final String id;
  final String userId;
  final String scheduleId;
  final String classId;
  final BookingStatus status;
  final String qrCodeValue;
  final DateTime bookedAt;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      scheduleId: json['scheduleId'] as String,
      classId: json['classId'] as String,
      status: BookingStatus.values.byName(json['status'] as String),
      qrCodeValue: json['qrCodeValue'] as String,
      bookedAt: DateTime.parse(json['bookedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scheduleId': scheduleId,
      'classId': classId,
      'status': status.name,
      'qrCodeValue': qrCodeValue,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }
}
