import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../../shared/widgets/chips/app_chip.dart';
import '../../../shared/widgets/inputs/app_search_field.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';

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
      // Filter by category
      if (_selectedCategory != null &&
          yogaClass.category != _selectedCategory) {
        return false;
      }
      // Filter by search query
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
            // Search and filters
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  // Search field
                  AppSearchField(
                    controller: _searchController,
                    hint: 'Search classes...',
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Category filter chips
                  _CategoryFilterChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            // Class list
            Expanded(
              child: classesAsync.when(
                data: (classes) {
                  final filteredClasses = _filterClasses(classes);
                  if (filteredClasses.isEmpty) {
                    return const _EmptyState();
                  }
                  return _ClassList(classes: filteredClasses);
                },
                loading: () => const _LoadingState(),
                error: (error, _) => const _ErrorState(),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
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
      onTap: () => context.push('/classes/${classModel.id}'),
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
            // Class image placeholder
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.card),
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder gradient
                  Container(
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
                  ),
                  // Class icon
                  Center(
                    child: Icon(
                      Icons.self_improvement,
                      size: 56,
                      color: AppColors.onSurfaceVariant.withAlpha(128),
                    ),
                  ),
                  // Mood indicator (intensity)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getIntensityColor(classModel.intensity),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x29000000), blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  // Credit cost badge
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
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    classModel.title,
                    style: AppTypography.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Category
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
                  // Instructor
                  instructorAsync.when(
                    data: (instructor) => Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: AppColors.onSurfaceVariant.withAlpha(128),
                          ),
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
                    loading: () => Row(
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
                    ),
                    error: (_, _) => Row(
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
                  // Duration and intensity row
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No class matches your search',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your filter',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(
          bottom: index < 2 ? AppSpacing.md : AppSpacing.lg,
        ),
        child: const _LoadingClassCard(),
      ),
    );
  }
}

class _LoadingClassCard extends StatelessWidget {
  const _LoadingClassCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.card),
              ),
            ),
          ),
          // Content placeholder
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 160,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
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
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'We could not connect right now',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Please check your connection and try again',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
