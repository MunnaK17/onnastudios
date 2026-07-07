import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/extensions/mood_extensions.dart';
import '../../../data/models/app_enums.dart';
import '../../providers/mood_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 5;

  void _goToStep(int step) {
    if (step >= 0 && step <= _totalSteps) {
      setState(() => _currentStep = step);
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      headerTitle: 'Mood Tracker',
      showBackButton: true,
      onBackPressed: () {
        ref.read(moodTrackerProvider.notifier).reset();
        context.pop();
      },
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            _StepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              onStepTapped: _goToStep,
            ),
            // Page Content - Using IndexedStack to preserve state
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _MoodQuestionStep(),
                  _StressQuestionStep(),
                  _EnergyQuestionStep(),
                  _FlexibilityQuestionStep(),
                  _MentalFocusQuestionStep(),
                ],
              ),
            ),
            // Navigation Buttons
            _NavigationButtons(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              onPrevious: _previousStep,
              onNext: _nextStep,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ============ STEP INDICATOR ============

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.onStepTapped,
  });

  final int currentStep;
  final int totalSteps;
  final void Function(int) onStepTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;
              return GestureDetector(
                onTap: () => onStepTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : isCompleted
                            ? AppColors.primary.withAlpha(179)
                            : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Question ${currentStep + 1} of $totalSteps',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ NAVIGATION BUTTONS ============

class _NavigationButtons extends ConsumerWidget {
  const _NavigationButtons({
    required this.currentStep,
    required this.totalSteps,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodTrackerProvider);
    final isLastStep = currentStep == totalSteps - 1;

    // Check if current question is answered
    bool canProceed = _isCurrentStepAnswered(state, currentStep);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              if (currentStep > 0)
                Expanded(
                  child: AppButton(
                    label: 'Back',
                    onPressed: onPrevious,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
              if (currentStep > 0) const SizedBox(width: AppSpacing.md),
              // Next/Submit Button
              Expanded(
                flex: currentStep > 0 ? 2 : 1,
                child: AppButton(
                  label: isLastStep ? 'Get Recommendations' : 'Next',
                  onPressed: canProceed
                      ? () {
                          if (isLastStep) {
                            _submitAndNavigate(context, ref);
                          } else {
                            onNext();
                          }
                        }
                      : null,
                  isLoading: state.isSubmitting,
                  isExpanded: true,
                ),
              ),
            ],
          ),
          if (!canProceed) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Please select an answer to continue',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  bool _isCurrentStepAnswered(MoodTrackerState state, int step) {
    switch (step) {
      case 0:
        return state.mood != null;
      case 1:
        return state.stressLevel != null;
      case 2:
        return state.energyLevel != null;
      case 3:
        return state.flexibility != null;
      case 4:
        return state.mentalFocus != null;
      default:
        return false;
    }
  }

  Future<void> _submitAndNavigate(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(moodTrackerProvider.notifier);
    notifier.setSubmitting(true);

    try {
      final entry = await notifier.submit();

      if (entry != null && context.mounted) {
        context.pushReplacement(AppRoutes.moodRecommendations);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      notifier.setSubmitting(false);
    }
  }
}

// ============ MOOD QUESTION STEP ============

class _MoodQuestionStep extends ConsumerWidget {
  const _MoodQuestionStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodTrackerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _QuestionHeader(
            emoji: '🌟',
            title: 'How are you feeling?',
            subtitle: 'Choose the mood that best describes you right now',
          ),
          const SizedBox(height: AppSpacing.xl),
          // Grid layout for mood options
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.5,
            ),
            itemCount: MoodType.values.length,
            itemBuilder: (context, index) {
              final mood = MoodType.values[index];
              final isSelected = state.mood == mood;
              return _MoodChip(
                mood: mood,
                isSelected: isSelected,
                onTap: () {
                  ref.read(moodTrackerProvider.notifier).setMood(mood);
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.subtle : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              mood.label,
              style: AppTypography.bodySm.copyWith(
                color: isSelected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============ STRESS QUESTION STEP ============

class _StressQuestionStep extends ConsumerWidget {
  const _StressQuestionStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodTrackerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _QuestionHeader(
            emoji: '💭',
            title: 'How stressed do you feel?',
            subtitle: 'Rate your current stress level',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...StressLevel.values.map((level) {
            final isSelected = state.stressLevel == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SelectableOption(
                label: level.label,
                isSelected: isSelected,
                onTap: () {
                  ref.read(moodTrackerProvider.notifier).setStressLevel(level);
                },
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ============ ENERGY QUESTION STEP ============

class _EnergyQuestionStep extends ConsumerWidget {
  const _EnergyQuestionStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodTrackerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _QuestionHeader(
            emoji: '⚡',
            title: "What's your energy level?",
            subtitle: 'How much energy do you have right now?',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...EnergyLevel.values.map((level) {
            final isSelected = state.energyLevel == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SelectableOption(
                label: level.label,
                isSelected: isSelected,
                onTap: () {
                  ref.read(moodTrackerProvider.notifier).setEnergyLevel(level);
                },
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ============ FLEXIBILITY QUESTION STEP ============

class _FlexibilityQuestionStep extends ConsumerWidget {
  const _FlexibilityQuestionStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodTrackerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _QuestionHeader(
            emoji: '🧘',
            title: 'How flexible is your body?',
            subtitle: 'Do you feel tight or flexible today?',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...FlexibilityLevel.values.map((level) {
            final isSelected = state.flexibility == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SelectableOption(
                label: level.label,
                isSelected: isSelected,
                onTap: () {
                  ref.read(moodTrackerProvider.notifier).setFlexibility(level);
                },
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ============ MENTAL FOCUS QUESTION STEP ============

class _MentalFocusQuestionStep extends ConsumerWidget {
  const _MentalFocusQuestionStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodTrackerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _QuestionHeader(
            emoji: '🎯',
            title: 'How focused is your mind?',
            subtitle: 'Can you concentrate clearly today?',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...MentalFocusLevel.values.map((level) {
            final isSelected = state.mentalFocus == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SelectableOption(
                label: level.label,
                isSelected: isSelected,
                onTap: () {
                  ref.read(moodTrackerProvider.notifier).setMentalFocus(level);
                },
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ============ SHARED WIDGETS ============

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: AppTypography.h2,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SelectableOption extends StatelessWidget {
  const _SelectableOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.subtle : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLg.copyWith(
                  color: isSelected
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
