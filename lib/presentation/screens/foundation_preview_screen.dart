import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/widgets.dart';
import '../providers/providers.dart';

class FoundationPreviewScreen extends ConsumerWidget {
  const FoundationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final classesAsync = ref.watch(allClassesProvider);
    final instructorsAsync = ref.watch(allInstructorsProvider);
    final schedulesAsync = ref.watch(allSchedulesProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Good Morning!', style: textTheme.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Foundation, navigation, reusable components ready. Connected to Supabase.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppSearchField(hint: 'Search classes, instructors, or mood...'),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              AppChip(label: 'Yoga', selected: true),
              AppChip(label: 'Pilates', selected: false),
              AppChip(label: 'Meditation', selected: false),
              AppChip(label: 'Restorative', selected: false),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Data from Supabase',
            subtitle: 'Live data preview from your database.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DataRow(
                  label: 'Yoga classes',
                  value: classesAsync.when(
                    data: (classes) => classes.length.toString(),
                    loading: () => '...',
                    error: (e, s) => '0',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _DataRow(
                  label: 'Instructors',
                  value: instructorsAsync.when(
                    data: (instructors) => instructors.length.toString(),
                    loading: () => '...',
                    error: (e, s) => '0',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _DataRow(
                  label: 'Schedules',
                  value: schedulesAsync.when(
                    data: (schedules) => schedules.length.toString(),
                    loading: () => '...',
                    error: (e, s) => '0',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Preview Input',
            hint: 'Reusable text field',
            prefixIcon: const Icon(Icons.mail_outline),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Reusable Button',
            icon: Icons.spa_outlined,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Use the bottom navigation to check active tab state. The final screens will replace these placeholders next.',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        Text(value, style: textTheme.headlineMedium),
      ],
    );
  }
}
