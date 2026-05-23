import '../../models/schedule_model.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/schedule_repository.dart';

/// Mock implementation of ScheduleRepository.
class MockScheduleRepository implements ScheduleRepository {
  @override
  Future<List<ScheduleModel>> getAllSchedules() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.schedules;
  }

  @override
  Future<ScheduleModel?> getScheduleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return MockOnnaData.schedules.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.schedules.where((s) {
      return s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day;
    }).toList();
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByClassId(String classId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.schedules
        .where((s) => s.classId == classId)
        .toList();
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByInstructorId(
    String instructorId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.schedules
        .where((s) => s.instructorId == instructorId)
        .toList();
  }

  @override
  Future<List<ScheduleModel>> getSchedulesInRange(
    DateTime start,
    DateTime end,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.schedules.where((s) {
      return s.date.isAfter(start.subtract(const Duration(days: 1))) &&
          s.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<ScheduleModel>> getAvailableSchedules() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockOnnaData.schedules
        .where((s) => s.availableSlots > 0)
        .toList();
  }
}