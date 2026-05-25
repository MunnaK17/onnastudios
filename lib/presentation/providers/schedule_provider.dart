import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/schedule_model.dart';
import '../../data/repositories/interfaces/schedule_repository.dart';
import '../../data/repositories/implementations/mock_schedule_repository.dart';

/// Provider for ScheduleRepository instance.
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return MockScheduleRepository();
});

/// Provider for all schedules.
final allSchedulesProvider = FutureProvider<List<ScheduleModel>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getAllSchedules();
});

/// Provider for schedules by date.
final schedulesByDateProvider =
    FutureProvider.family<List<ScheduleModel>, DateTime>((ref, date) async {
      final repository = ref.watch(scheduleRepositoryProvider);
      return repository.getSchedulesByDate(date);
    });

/// Provider for schedules by class ID.
final schedulesByClassIdProvider =
    FutureProvider.family<List<ScheduleModel>, String>((ref, classId) async {
      final repository = ref.watch(scheduleRepositoryProvider);
      return repository.getSchedulesByClassId(classId);
    });

/// Provider for a single schedule by ID.
final scheduleByIdProvider = FutureProvider.family<ScheduleModel?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getScheduleById(id);
});

/// Provider for available schedules only.
final availableSchedulesProvider = FutureProvider<List<ScheduleModel>>((
  ref,
) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getAvailableSchedules();
});

/// State for selected date.
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

/// Provider for schedules filtered by selected date.
final schedulesForSelectedDateProvider = FutureProvider<List<ScheduleModel>>((
  ref,
) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getSchedulesByDate(selectedDate);
});

/// Schedule list state notifier using Riverpod 3.x Notifier.
class ScheduleListNotifier extends Notifier<AsyncValue<List<ScheduleModel>>> {
  @override
  AsyncValue<List<ScheduleModel>> build() => const AsyncValue.loading();

  Future<void> loadSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await ref
          .read(scheduleRepositoryProvider)
          .getAllSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadByDate(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final schedules = await ref
          .read(scheduleRepositoryProvider)
          .getSchedulesByDate(date);
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// NotifierProvider for schedule list.
final scheduleListNotifierProvider =
    NotifierProvider<ScheduleListNotifier, AsyncValue<List<ScheduleModel>>>(() {
      return ScheduleListNotifier();
    });
