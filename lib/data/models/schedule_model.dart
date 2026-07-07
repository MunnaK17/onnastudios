class ScheduleModel {
  const ScheduleModel({
    required this.id,
    required this.classId,
    required this.instructorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.availableSlots,
    required this.totalSlots,
    required this.studioRoom,
  });

  final String id;
  final String classId;
  final String instructorId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int availableSlots;
  final int totalSlots;
  final String studioRoom;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      classId: json['classId'] as String,
      instructorId: json['instructorId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      availableSlots: json['availableSlots'] as int,
      totalSlots: json['totalSlots'] as int,
      studioRoom: json['studioRoom'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'instructorId': instructorId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'availableSlots': availableSlots,
      'totalSlots': totalSlots,
      'studioRoom': studioRoom,
    };
  }

  /// Check if this schedule's date has passed (based on date only, not time).
  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDate = DateTime(date.year, date.month, date.day);
    return scheduleDate.isBefore(today);
  }

  /// Check if this schedule is today.
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get the full DateTime of when this schedule starts.
  DateTime get startDateTime {
    final timeParts = startTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  /// Check if this schedule has expired (30 minutes after start time).
  bool get isExpired {
    final now = DateTime.now();
    final expirationTime = startDateTime.add(const Duration(minutes: 30));
    return now.isAfter(expirationTime);
  }

  /// Check if this schedule is currently available for booking/check-in.
  /// Available if: not past AND not expired (within 30 min of start time).
  bool get isBookable {
    if (isPast) return false;
    if (isExpired) return false;
    return true;
  }
}
