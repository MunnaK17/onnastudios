import 'app_enums.dart';
import 'schedule_model.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.classId,
    required this.status,
    required this.qrCodeValue,
    required this.bookedAt,
    this.checkedIn = false,
    this.checkedInAt,
    this.schedule,
  });

  final String id;
  final String userId;
  final String scheduleId;
  final String classId;
  final BookingStatus status;
  final String qrCodeValue;
  final DateTime bookedAt;
  final bool checkedIn;
  final DateTime? checkedInAt;

  /// Optional schedule model for convenience (loaded from provider).
  final ScheduleModel? schedule;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      scheduleId: json['scheduleId'] as String,
      classId: json['classId'] as String,
      status: BookingStatus.values.byName(json['status'] as String),
      qrCodeValue: json['qrCodeValue'] as String,
      bookedAt: DateTime.parse(json['bookedAt'] as String),
      checkedIn: json['checked_in'] as bool? ?? false,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'] as String)
          : null,
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
      'checked_in': checkedIn,
      if (checkedInAt != null) 'checked_in_at': checkedInAt!.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? scheduleId,
    String? classId,
    BookingStatus? status,
    String? qrCodeValue,
    DateTime? bookedAt,
    bool? checkedIn,
    DateTime? checkedInAt,
    ScheduleModel? schedule,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scheduleId: scheduleId ?? this.scheduleId,
      classId: classId ?? this.classId,
      status: status ?? this.status,
      qrCodeValue: qrCodeValue ?? this.qrCodeValue,
      bookedAt: bookedAt ?? this.bookedAt,
      checkedIn: checkedIn ?? this.checkedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      schedule: schedule ?? this.schedule,
    );
  }

  /// Check if the booking can be checked in.
  /// Can check in 30 minutes before class starts and until 30 minutes after.
  bool get canCheckIn {
    if (checkedIn) return false;
    if (status != BookingStatus.upcoming) return false;
    if (schedule == null) return false;
    // Can check in if schedule is not expired
    return !schedule!.isExpired;
  }

  /// Check if the booking is still upcoming (not completed, cancelled, etc).
  bool get isUpcoming => status == BookingStatus.upcoming;

  /// Get booking status text
  String get statusText {
    if (checkedIn) {
      return 'Checked In';
    }
    switch (status) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.expired:
        return 'Expired';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }

  /// Get booking status color/text for UI
  String get statusLabel {
    if (checkedIn) {
      return 'Checked In';
    }
    switch (status) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.expired:
        return 'Expired';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }
}
