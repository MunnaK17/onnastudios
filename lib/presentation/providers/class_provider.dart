import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/yoga_class_model.dart';
import '../../data/models/app_enums.dart';
import '../../data/repositories/interfaces/class_repository.dart';
import '../../data/repositories/implementations/mock_class_repository.dart';

/// Provider for ClassRepository instance.
final classRepositoryProvider = Provider<ClassRepository>((ref) {
  return MockClassRepository();
});

/// Provider for all classes.
final allClassesProvider = FutureProvider<List<YogaClassModel>>((ref) async {
  final repository = ref.watch(classRepositoryProvider);
  return repository.getAllClasses();
});

/// Provider for featured classes.
final featuredClassesProvider = FutureProvider<List<YogaClassModel>>((
  ref,
) async {
  final repository = ref.watch(classRepositoryProvider);
  return repository.getFeaturedClasses();
});

/// Provider for a single class by ID.
final classByIdProvider = FutureProvider.family<YogaClassModel?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(classRepositoryProvider);
  return repository.getClassById(id);
});

/// State for search query.
final classSearchQueryProvider =
    NotifierProvider<ClassSearchQueryNotifier, String>(
      ClassSearchQueryNotifier.new,
    );

class ClassSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider for searched classes.
final searchedClassesProvider = FutureProvider<List<YogaClassModel>>((
  ref,
) async {
  final query = ref.watch(classSearchQueryProvider);
  if (query.isEmpty) {
    return ref.watch(allClassesProvider.future);
  }
  final repository = ref.watch(classRepositoryProvider);
  return repository.searchClasses(query);
});

/// State for selected category.
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, ClassCategory?>(
      SelectedCategoryNotifier.new,
    );

class SelectedCategoryNotifier extends Notifier<ClassCategory?> {
  @override
  ClassCategory? build() => null;

  void setCategory(ClassCategory? category) {
    state = category;
  }

  void clear() {
    state = null;
  }
}

/// Provider for filtered classes by category.
final filteredClassesByCategoryProvider = FutureProvider<List<YogaClassModel>>((
  ref,
) async {
  final category = ref.watch(selectedCategoryProvider);
  if (category == null) {
    return ref.watch(allClassesProvider.future);
  }
  final repository = ref.watch(classRepositoryProvider);
  return repository.getClassesByCategory(category);
});

/// Class list state notifier using Riverpod 3.x Notifier.
class ClassListNotifier extends Notifier<AsyncValue<List<YogaClassModel>>> {
  @override
  AsyncValue<List<YogaClassModel>> build() => const AsyncValue.loading();

  Future<void> loadClasses() async {
    state = const AsyncValue.loading();
    try {
      final classes = await ref.read(classRepositoryProvider).getAllClasses();
      state = AsyncValue.data(classes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> filterByCategory(ClassCategory? category) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(classRepositoryProvider);
      final classes = category == null
          ? await repository.getAllClasses()
          : await repository.getClassesByCategory(category);
      state = AsyncValue.data(classes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// NotifierProvider for class list.
final classListNotifierProvider =
    NotifierProvider<ClassListNotifier, AsyncValue<List<YogaClassModel>>>(() {
      return ClassListNotifier();
    });
