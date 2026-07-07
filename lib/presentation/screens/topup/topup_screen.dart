import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/credit_package_model.dart';
import '../../providers/package_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/state/app_state_widgets.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  String? _selectedPackageId;

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(allPackagesProvider);
    final purchaseState = ref.watch(packagePurchaseNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _HeaderSection(),
            Expanded(
              child: packagesAsync.when(
                data: (packages) => _PackageList(
                  packages: packages,
                  selectedPackageId: _selectedPackageId,
                  onPackageSelected: (id) {
                    setState(() {
                      _selectedPackageId = id;
                    });
                  },
                ),
                loading: () => const AppLoadingState(),
                error: (e, _) => AppErrorState(
                  title: 'Failed to load packages',
                  subtitle: e.toString(),
                  onRetry: () => ref.invalidate(allPackagesProvider),
                ),
              ),
            ),
            if (_selectedPackageId != null) _PurchaseButton(
              packageId: _selectedPackageId!,
              isLoading: purchaseState.isLoading,
              onPurchase: () => _handlePurchase(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackageId == null) return;

    final success = await ref
        .read(packagePurchaseNotifierProvider.notifier)
        .purchasePackage(_selectedPackageId!);

    if (!mounted) return;

    if (success) {
      // Show success dialog
      await showDialog(
        context: context,
        builder: (context) => _SuccessDialog(
          packageId: _selectedPackageId!,
          onDone: () {
            Navigator.of(context).pop();
            context.pop(); // Go back to wallet
          },
        ),
      );
    } else {
      // Show error
      final error = ref.read(packagePurchaseNotifierProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error?.toString() ?? 'Purchase failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      ref.read(packagePurchaseNotifierProvider.notifier).reset();
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.profile);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: AppColors.onSurface,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Top Up Credits', style: AppTypography.h2),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Choose a package that aligns with your practice. Your credits will be available immediately after purchase.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageList extends StatelessWidget {
  const _PackageList({
    required this.packages,
    required this.selectedPackageId,
    required this.onPackageSelected,
  });

  final List<CreditPackageModel> packages;
  final String? selectedPackageId;
  final ValueChanged<String> onPackageSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final isSelected = package.id == selectedPackageId;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < packages.length - 1 ? AppSpacing.md : 0,
          ),
          child: _PackageCard(
            package: package,
            isSelected: isSelected,
            onTap: () => onPackageSelected(package.id),
          ),
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  final CreditPackageModel package;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.subtle : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (package.isFeatured) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                'POPULAR',
                                style: AppTypography.labelCaps.copyWith(
                                  color: AppColors.onTertiaryContainer,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Expanded(
                            child: Text(
                              package.name,
                              style: AppTypography.h3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        package.description,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.secondary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : AppColors.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.surfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credits',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${package.totalCredits}',
                          style: AppTypography.h2.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        if (package.bonusCredits > 0) ...[
                          const SizedBox(width: AppSpacing.xxs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '+${package.bonusCredits} bonus',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.onSecondaryContainer,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Price',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      package.formattedPrice,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (package.validDays > 0) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Valid for ${package.validDays} days',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({
    required this.packageId,
    required this.isLoading,
    required this.onPurchase,
  });

  final String packageId;
  final bool isLoading;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(
          top: BorderSide(color: AppColors.surfaceVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: isLoading ? 'Processing...' : 'Purchase Package',
          onPressed: isLoading ? null : onPurchase,
          isExpanded: true,
        ),
      ),
    );
  }
}

class _SuccessDialog extends ConsumerWidget {
  const _SuccessDialog({
    required this.packageId,
    required this.onDone,
  });

  final String packageId;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(packageByIdProvider(packageId));

    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Purchase Successful! 🎉',
            style: AppTypography.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          packageAsync.when(
            data: (package) => package != null
                ? Column(
                    children: [
                      Text(
                        'You now have ${package.totalCredits} credits available.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Package: ${package.name}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Done',
              onPressed: onDone,
            ),
          ),
        ],
      ),
    );
  }
}
