import '../../models/schedule_model.dart';

/// Repository interface for schedule operations.
abstract class ScheduleRepository {
  /// Get all schedules.
  Future<List<ScheduleModel>> getAllSchedules();

  /// Get a schedule by ID.
  Future<ScheduleModel?> getScheduleById(String id);

  /// Get schedules by date.
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date);

  /// Get schedules by class ID.
  Future<List<ScheduleModel>> getSchedulesByClassId(String classId);

  /// Get schedules by instructor ID.
  Future<List<ScheduleModel>> getSchedulesByInstructorId(String instructorId);

  /// Get schedules within a date range.
  Future<List<ScheduleModel>> getSchedulesInRange(DateTime start, DateTime end);

  /// Get available schedules (slots > 0).
  Future<List<ScheduleModel>> getAvailableSchedules();
}
