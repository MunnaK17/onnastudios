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
      error: (_, _) => const _NotFoundScreen(),
    );
  }
}

class _InstructorProfileContent extends ConsumerWidget {
  const _InstructorProfileContent({required this.instructor});

  final dynamic instructor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(
      classesByInstructorIdProvider(instructor.id),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with avatar and info
          _InstructorHeader(instructor: instructor),
          // Bio section
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
                    instructor.bio,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Classes section
                  Text(
                    'Classes by ${instructor.name}',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          // Classes list
          classesAsync.when(
            data: (classes) {
              if (classes.isEmpty) {
                return const SliverToBoxAdapter(child: _EmptyClasses());
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
            loading: () => const SliverToBoxAdapter(child: _LoadingClasses()),
            error: (_, _) => const SliverToBoxAdapter(child: _ErrorClasses()),
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
                // Avatar
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
                    child: Image.network(
                      instructor.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.onSurfaceVariant.withAlpha(128),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Name
                Text(
                  instructor.name,
                  style: AppTypography.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                // Specialty badge
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
                    instructor.specialty,
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
        onTap: () => context.push('${AppRoutes.classDetail}/${yogaClass.id}'),
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
              // Class image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image.network(
                    yogaClass.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceContainerHigh,
                        child: Icon(
                          Icons.spa_outlined,
                          color: AppColors.onSurfaceVariant,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Class info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
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
                    // Title
                    Text(
                      yogaClass.title,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    // Info row
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${yogaClass.durationMinutes} min',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          Icons.monetization_on_outlined,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${yogaClass.creditCost} credits',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
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

class _EmptyClasses extends StatelessWidget {
  const _EmptyClasses();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No classes available',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingClasses extends StatelessWidget {
  const _LoadingClasses();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < 2 ? AppSpacing.md : AppSpacing.xxl,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: 150,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorClasses extends StatelessWidget {
  const _ErrorClasses();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unable to load classes',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    width: 80,
                    height: 24,
                    color: AppColors.surfaceContainerHigh,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    height: 80,
                    color: AppColors.surfaceContainerHigh,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    width: 150,
                    height: 24,
                    color: AppColors.surfaceContainerHigh,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_search,
                size: 64,
                color: AppColors.onSurfaceVariant.withAlpha(128),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Instructor Not Found',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This instructor may no longer be available',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
