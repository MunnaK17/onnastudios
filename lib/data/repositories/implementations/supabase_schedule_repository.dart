import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/schedule_model.dart';
import '../interfaces/schedule_repository.dart';

class SupabaseScheduleRepository implements ScheduleRepository {
  SupabaseScheduleRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  ScheduleModel _mapSchedule(Map<String, dynamic> data) {
    return ScheduleModel(
      id: data['id'] as String,
      classId: data['class_id'] as String,
      instructorId: data['instructor_id'] as String,
      date: _parseDate(data['date']),
      startTime: data['start_time'] as String,
      endTime: data['end_time'] as String,
      availableSlots: (data['available_slots'] as int?) ?? 0,
      totalSlots: (data['total_slots'] as int?) ?? 0,
      studioRoom: (data['studio_room'] as String?) ?? '',
    );
  }

  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      // Handle ISO 8601 format with timezone
      if (dateValue.contains('T')) {
        return DateTime.parse(dateValue);
      }
      // Handle date-only format "YYYY-MM-DD"
      final parts = dateValue.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }
    return DateTime.now();
  }

  String _dateOnly(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Future<List<ScheduleModel>> getAllSchedules() async {
    final todayStr = _dateOnly(DateTime.now());
    final now = DateTime.now();
    final cutoffTime = now.subtract(const Duration(minutes: 30));
    final cutoffTimeStr = _formatTime(cutoffTime);

    final data = await _client
        .from('schedules')
        .select()
        .gte('date', todayStr)
        .order('date', ascending: true)
        .order('start_time', ascending: true);

    // Filter out expired schedules (client-side for flexibility)
    final schedules = data.map(_mapSchedule).toList();
    return schedules.where((s) => !_isScheduleExpired(s, now, cutoffTimeStr)).toList();
  }

  @override
  Future<ScheduleModel?> getScheduleById(String id) async {
    final data = await _client
        .from('schedules')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data == null ? null : _mapSchedule(data);
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date) async {
    final todayStr = _dateOnly(DateTime.now());
    final dateStr = _dateOnly(date);
    final now = DateTime.now();
    final cutoffTime = now.subtract(const Duration(minutes: 30));
    final cutoffTimeStr = _formatTime(cutoffTime);

    // If requested date is in the past, return empty list
    if (dateStr.compareTo(todayStr) < 0) {
      return [];
    }

    final data = await _client
        .from('schedules')
        .select()
        .eq('date', dateStr)
        .order('start_time', ascending: true);

    // Filter out expired schedules
    final schedules = data.map(_mapSchedule).toList();
    return schedules.where((s) => !_isScheduleExpired(s, now, cutoffTimeStr)).toList();
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByClassId(String classId) async {
    final todayStr = _dateOnly(DateTime.now());
    final now = DateTime.now();
    final cutoffTime = now.subtract(const Duration(minutes: 30));
    final cutoffTimeStr = _formatTime(cutoffTime);

    final data = await _client
        .from('schedules')
        .select()
        .eq('class_id', classId)
        .gte('date', todayStr)
        .order('date', ascending: true)
        .order('start_time', ascending: true);

    // Filter out expired schedules
    final schedules = data.map(_mapSchedule).toList();
    return schedules.where((s) => !_isScheduleExpired(s, now, cutoffTimeStr)).toList();
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByInstructorId(
    String instructorId,
  ) async {
    final todayStr = _dateOnly(DateTime.now());
    final now = DateTime.now();
    final cutoffTime = now.subtract(const Duration(minutes: 30));
    final cutoffTimeStr = _formatTime(cutoffTime);

    final data = await _client
        .from('schedules')
        .select()
        .eq('instructor_id', instructorId)
        .gte('date', todayStr)
        .order('date', ascending: true)
        .order('start_time', ascending: true);

    // Filter out expired schedules
    final schedules = data.map(_mapSchedule).toList();
    return schedules.where((s) => !_isScheduleExpired(s, now, cutoffTimeStr)).toList();
  }

  @override
  Future<List<ScheduleModel>> getSchedulesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final now = DateTime.now();
    final cutoffTime = now.subtract(const Duration(minutes: 30));
    final cutoffTimeStr = _formatTime(cutoffTime);

    final data = await _client
        .from('schedules')
        .select()
        .gte('date', _dateOnly(start))
        .lte('date', _dateOnly(end))
        .order('date', ascending: true)
        .order('start_time', ascending: true);

    // Filter out expired schedules
    final schedules = data.map(_mapSchedule).toList();
    return schedules.where((s) => !_isScheduleExpired(s, now, cutoffTimeStr)).toList();
  }

  @override
  Future<List<ScheduleModel>> getAvailableSchedules() async {
    final todayStr = _dateOnly(DateTime.now());
    final now = DateTime.now();
    final cutoffTime = now.subtract(const Duration(minutes: 30));
    final cutoffTimeStr = _formatTime(cutoffTime);

    final data = await _client
        .from('schedules')
        .select()
        .gte('date', todayStr)
        .gt('available_slots', 0)
        .order('date', ascending: true)
        .order('start_time', ascending: true);

    // Filter out expired schedules
    final schedules = data.map(_mapSchedule).toList();
    return schedules.where((s) => !_isScheduleExpired(s, now, cutoffTimeStr)).toList();
  }

  /// Check if a schedule is expired (30 minutes after start time).
  bool _isScheduleExpired(ScheduleModel schedule, DateTime now, String cutoffTimeStr) {
    // If it's not today, it's not expired yet
    if (!schedule.isToday) return false;

    // Compare time with cutoff (30 minutes ago)
    return schedule.startTime.compareTo(cutoffTimeStr) < 0;
  }

  /// Format time as HH:mm for comparison.
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
