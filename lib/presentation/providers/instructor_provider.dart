import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/instructor_model.dart';
import '../../data/repositories/interfaces/instructor_repository.dart';
import '../../data/repositories/implementations/mock_instructor_repository.dart';

/// Provider for InstructorRepository instance.
final instructorRepositoryProvider = Provider<InstructorRepository>((ref) {
  return MockInstructorRepository();
});

/// Provider for all instructors.
final allInstructorsProvider = FutureProvider<List<InstructorModel>>((
  ref,
) async {
  final repository = ref.watch(instructorRepositoryProvider);
  return repository.getAllInstructors();
});

/// Provider for a single instructor by ID.
final instructorByIdProvider = FutureProvider.family<InstructorModel?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(instructorRepositoryProvider);
  return repository.getInstructorById(id);
});

/// Instructor list state notifier using Riverpod 3.x Notifier.
class InstructorListNotifier
    extends Notifier<AsyncValue<List<InstructorModel>>> {
  @override
  AsyncValue<List<InstructorModel>> build() => const AsyncValue.loading();

  Future<void> loadInstructors() async {
    state = const AsyncValue.loading();
    try {
      final instructors = await ref
          .read(instructorRepositoryProvider)
          .getAllInstructors();
      state = AsyncValue.data(instructors);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// NotifierProvider for instructor list.
final instructorListNotifierProvider =
    NotifierProvider<InstructorListNotifier, AsyncValue<List<InstructorModel>>>(
      () {
        return InstructorListNotifier();
      },
    );
