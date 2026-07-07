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
import '../../../shared/widgets/state/app_state_widgets.dart';
import '../../../shared/widgets/images/optimized_image.dart';

class InstructorProfileScreen extends ConsumerWidget {
  const InstructorProfileScreen({required this.instructorId, super.key});

  final String instructorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorAsync = ref.watch(instructorByIdProvider(instructorId));

    return instructorAsync.when(
      data: (instructor) {
        if (instructor == null) {
          return const _NotFoundScreen();
        }
        return _InstructorProfileContent(instructor: instructor);
      },
      loading: () => const _LoadingScreen(),
      error: (e, _) => _NotFoundScreen(
        onRetry: () => ref.invalidate(instructorByIdProvider(instructorId)),
      ),
    );
  }
}

class _InstructorProfileContent extends ConsumerWidget {
  const _InstructorProfileContent({required this.instructor});

  final dynamic instructor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesByInstructorIdProvider(instructor.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _InstructorHeader(instructor: instructor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text('About', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    instructor.bio ?? '',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Classes by ${instructor.name ?? 'Instructor'}',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          classesAsync.when(
            data: (classes) {
              if (classes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: AppEmptyState(
                    icon: Icons.school_outlined,
                    title: 'No classes available',
                    subtitle: 'Check back later for new classes',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final yogaClass = classes[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < classes.length - 1
                            ? AppSpacing.md
                            : AppSpacing.xxl,
                      ),
                      child: _InstructorClassCard(yogaClass: yogaClass),
                    );
                  }, childCount: classes.length),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: AppLoadingState()),
            error: (e, _) => SliverToBoxAdapter(
              child: AppErrorState(
                onRetry: () => ref.invalidate(classesByInstructorIdProvider(instructor.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructorHeader extends StatelessWidget {
  const _InstructorHeader({required this.instructor});

  final dynamic instructor;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withAlpha(230),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.onSurface,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.secondaryContainer.withAlpha(77),
                AppColors.primaryContainer.withAlpha(77),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.subtle,
                    border: Border.all(
                      color: AppColors.surfaceContainerLowest,
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: instructor.photoUrl != null && instructor.photoUrl.isNotEmpty
                        ? Image.network(
                            instructor.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, size: 60,
                                  color: AppColors.onSurfaceVariant);
                            },
                          )
                        : Icon(Icons.person, size: 60,
                            color: AppColors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  instructor.name ?? 'Instructor',
                  style: AppTypography.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    instructor.specialty ?? '',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructorClassCard extends StatelessWidget {
  const _InstructorClassCard({required this.yogaClass});

  final YogaClassModel yogaClass;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () => context.push(AppRoutes.classDetailPath(yogaClass.id)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: OptimizedImage(
                  imageUrl: yogaClass.imageUrl,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  errorPlaceholder: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.spa_outlined, color: AppColors.onSurfaceVariant, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withAlpha(128),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        _formatCategory(yogaClass.category),
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.onSecondaryContainer,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      yogaClass.title,
                      style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${yogaClass.durationMinutes} min',
                          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${yogaClass.creditCost} credits',
                          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCategory(ClassCategory category) {
    return switch (category) {
      ClassCategory.yogaFlow => 'Yoga',
      ClassCategory.pilates => 'Pilates',
      ClassCategory.meditation => 'Meditation',
      ClassCategory.breathwork => 'Breathwork',
      ClassCategory.strength => 'Strength',
      ClassCategory.restorative => 'Restorative',
    };
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withAlpha(230),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.onSurface,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.secondaryContainer.withAlpha(77),
                      AppColors.primaryContainer.withAlpha(77),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: 150,
                        height: 28,
                        color: AppColors.surfaceContainerHigh,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 100,
                        height: 20,
                        color: AppColors.surfaceContainerHigh,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: AppLoadingState()),
        ],
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Instructor Not Found'),
      ),
      body: AppErrorState(
        title: 'Instructor Not Found',
        subtitle: 'This instructor may no longer be available',
        onRetry: onRetry,
      ),
    );
  }
}
