import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/mock/mock_data.dart';
import '../../shared/widgets/widgets.dart';

class FoundationPreviewScreen extends StatelessWidget {
  const FoundationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Good Morning, Alya.', style: textTheme.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Foundation, navigation, reusable components, and mock data are ready.',
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
            title: 'Build Progress',
            subtitle: 'Visible preview of the current app foundation.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressRow(
                  label: 'Yoga classes',
                  value: MockOnnaData.yogaClasses.length.toString(),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProgressRow(
                  label: 'Instructors',
                  value: MockOnnaData.instructors.length.toString(),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProgressRow(
                  label: 'Schedules',
                  value: MockOnnaData.schedules.length.toString(),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProgressRow(
                  label: 'Packages',
                  value: MockOnnaData.membershipPackages.length.toString(),
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

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value});

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
