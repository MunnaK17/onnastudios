import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/chips/app_chip.dart';
import '../../../shared/widgets/images/optimized_image.dart';
import '../../../shared/widgets/inputs/app_search_field.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/state/app_state_widgets.dart';

class ClassesScreen extends ConsumerStatefulWidget {
  const ClassesScreen({super.key});

  @override
  ConsumerState<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends ConsumerState<ClassesScreen> {
  final TextEditingController _searchController = TextEditingController();
  ClassCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onCategorySelected(ClassCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  List<YogaClassModel> _filterClasses(List<YogaClassModel> classes) {
    return classes.where((yogaClass) {
      if (_selectedCategory != null &&
          yogaClass.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final titleMatch = yogaClass.title.toLowerCase().contains(_searchQuery);
        final categoryMatch = yogaClass.category.name.toLowerCase().contains(
          _searchQuery,
        );
        final descMatch = yogaClass.description.toLowerCase().contains(
          _searchQuery,
        );
        if (!titleMatch && !categoryMatch && !descMatch) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(allClassesProvider);

    return AppScaffold(
      headerTitle: 'Classes',
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  AppSearchField(
                    controller: _searchController,
                    hint: 'Search classes...',
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CategoryFilterChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            Expanded(
              child: classesAsync.when(
                data: (classes) {
                  final filteredClasses = _filterClasses(classes);
                  if (filteredClasses.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.search_off,
                      title: 'No class matches your search',
                      subtitle: 'Try adjusting your filter',
                      action: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedCategory = null;
                          _searchController.clear();
                        });
                      },
                      actionLabel: 'Clear Filters',
                    );
                  }
                  return _ClassList(classes: filteredClasses);
                },
                loading: () => const AppLoadingState(),
                error: (e, st) => AppErrorState(
                  onRetry: () => ref.invalidate(allClassesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterChips extends StatelessWidget {
  const _CategoryFilterChips({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final ClassCategory? selectedCategory;
  final ValueChanged<ClassCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppChip(
            label: 'All',
            selected: selectedCategory == null,
            onSelected: (_) => onCategorySelected(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Yoga Flow',
            selected: selectedCategory == ClassCategory.yogaFlow,
            onSelected: (_) => onCategorySelected(ClassCategory.yogaFlow),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Pilates',
            selected: selectedCategory == ClassCategory.pilates,
            onSelected: (_) => onCategorySelected(ClassCategory.pilates),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Meditation',
            selected: selectedCategory == ClassCategory.meditation,
            onSelected: (_) => onCategorySelected(ClassCategory.meditation),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Breathwork',
            selected: selectedCategory == ClassCategory.breathwork,
            onSelected: (_) => onCategorySelected(ClassCategory.breathwork),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Strength',
            selected: selectedCategory == ClassCategory.strength,
            onSelected: (_) => onCategorySelected(ClassCategory.strength),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Restorative',
            selected: selectedCategory == ClassCategory.restorative,
            onSelected: (_) => onCategorySelected(ClassCategory.restorative),
          ),
        ],
      ),
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({required this.classes});

  final List<YogaClassModel> classes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final yogaClass = classes[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < classes.length - 1 ? AppSpacing.md : AppSpacing.lg,
          ),
          child: _ClassCardItem(classModel: yogaClass),
        );
      },
    );
  }
}

class _ClassCardItem extends ConsumerWidget {
  const _ClassCardItem({required this.classModel});

  final YogaClassModel classModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorAsync = ref.watch(
      instructorByIdProvider(classModel.instructorId),
    );

    return GestureDetector(
      onTap: () => context.push(AppRoutes.classDetailPath(classModel.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.surfaceVariant),
          boxShadow: AppShadows.ambient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class image
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: OptimizedImage(
                      imageUrl: classModel.imageUrl,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.card),
                      ),
                      errorPlaceholder: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryContainer.withAlpha(77),
                              AppColors.secondaryContainer.withAlpha(77),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.self_improvement,
                            size: 56,
                            color: AppColors.onSurfaceVariant.withAlpha(128),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getIntensityColor(classModel.intensity),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 1.5,
                        ),
                        boxShadow: AppShadows.subtle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.onSurface.withAlpha(204),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${classModel.creditCost} Credits',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classModel.title,
                    style: AppTypography.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withAlpha(128),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      _formatCategory(classModel.category),
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  instructorAsync.when(
                    data: (instructor) => Row(
                      children: [
                        OptimizedAvatar(
                          imageUrl: instructor?.photoUrl ?? '',
                          name: instructor?.name,
                          size: 32,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            instructor?.name ?? 'Instructor',
                            style: AppTypography.bodyMd,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const _LoadingInstructorRow(),
                    error: (e, _) => Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Instructor', style: AppTypography.bodyMd),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.schedule,
                        label: '${classModel.durationMinutes} min',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _InfoChip(
                        icon: Icons.bolt,
                        label: _formatIntensity(classModel.intensity),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIntensityColor(ClassIntensity intensity) {
    switch (intensity) {
      case ClassIntensity.low:
        return AppColors.secondaryContainer;
      case ClassIntensity.medium:
        return AppColors.primaryFixed;
      case ClassIntensity.high:
        return AppColors.tertiaryContainer;
    }
  }

  String _formatCategory(ClassCategory category) {
    switch (category) {
      case ClassCategory.yogaFlow:
        return 'Yoga Flow';
      case ClassCategory.pilates:
        return 'Pilates';
      case ClassCategory.meditation:
        return 'Meditation';
      case ClassCategory.breathwork:
        return 'Breathwork';
      case ClassCategory.strength:
        return 'Strength';
      case ClassCategory.restorative:
        return 'Restorative';
    }
  }

  String _formatIntensity(ClassIntensity intensity) {
    switch (intensity) {
      case ClassIntensity.low:
        return 'Low';
      case ClassIntensity.medium:
        return 'Medium';
      case ClassIntensity.high:
        return 'High';
    }
  }
}

class _LoadingInstructorRow extends StatelessWidget {
  const _LoadingInstructorRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
