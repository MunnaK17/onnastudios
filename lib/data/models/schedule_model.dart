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
}
