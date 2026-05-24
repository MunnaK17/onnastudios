import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/membership_package_model.dart';
import '../../providers/membership_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';

class PackageScreen extends ConsumerWidget {
  const PackageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Header
            const _HeaderSection(),
            const SizedBox(height: AppSpacing.xl),
            // Active Membership & Credits
            const _MembershipSummary(),
            const SizedBox(height: AppSpacing.xxl),
            // Packages
            const _PackagesSection(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Elevate Your Practice', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            child: Text(
              'Choose a package that aligns with your rhythm. Whether you flow daily or visit occasionally, find the perfect balance for your journey.',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipSummary extends ConsumerWidget {
  const _MembershipSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMembershipAsync = ref.watch(activeMembershipProvider);
    final walletAsync = ref.watch(walletNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          // Active Membership Card
          activeMembershipAsync.when(
            data: (membership) {
              if (membership == null) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.tertiaryContainer,
                      AppColors.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadows.ambient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plan',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onTertiaryFixed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      membership.name,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.onTertiaryFixed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.onTertiaryFixed.withAlpha(51),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            membership.hasUnlimitedCredits
                                ? 'Unlimited'
                                : '${membership.credits} Credits',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onTertiaryFixed,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Valid for ${membership.validityDays} days',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onTertiaryFixed.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          // Credits Card
          walletAsync.when(
            data: (wallet) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.surfaceVariant),
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Credits',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${wallet.remainingCredits}',
                        style: AppTypography.h2,
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: wallet.hasEnoughCredits
                          ? AppColors.secondaryContainer
                          : AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Icon(
                      wallet.hasEnoughCredits
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_outlined,
                      color: wallet.hasEnoughCredits
                          ? AppColors.onSecondaryContainer
                          : AppColors.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const _LoadingCreditCard(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _LoadingCreditCard extends StatelessWidget {
  const _LoadingCreditCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 14,
                color: AppColors.surfaceContainerHigh,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 60,
                height: 32,
                color: AppColors.surfaceContainerHigh,
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            color: AppColors.surfaceContainerHigh,
          ),
        ],
      ),
    );
  }
}

class _PackagesSection extends ConsumerWidget {
  const _PackagesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(allPackagesProvider);

    return packagesAsync.when(
      data: (packages) {
        if (packages.isEmpty) {
          return const _EmptyState();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Text('Available Packages', style: AppTypography.h3),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Packages Grid
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: packages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final package = entry.value;
                  final isLast = index == packages.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : AppSpacing.md,
                    ),
                    child: _PackageCard(package: package),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const _LoadingPackages(),
      error: (_, _) => const _EmptyState(),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package});

  final MembershipPackageModel package;

  void _showPurchaseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PurchaseConfirmationSheet(package: package),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: package.isPopular
              ? AppColors.onTertiaryContainer
              : AppColors.surfaceVariant,
          width: package.isPopular ? 2 : 1,
        ),
        boxShadow: package.isPopular ? AppShadows.elevated : AppShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Badge
          if (package.isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.onTertiaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'Most Popular',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.surfaceContainerLowest,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // Name & Description
          Text(package.name, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            package.description,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${package.price.toStringAsFixed(0)}',
                style: AppTypography.h2,
              ),
              if (package.hasUnlimitedCredits) ...[
                Text(
                  '/month',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Credits & Validity
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _PackageBadge(
                icon: Icons.monetization_on_outlined,
                label: package.hasUnlimitedCredits
                    ? 'Unlimited Credits'
                    : '${package.credits} Credits',
              ),
              _PackageBadge(
                icon: Icons.calendar_today_outlined,
                label: 'Valid ${package.validityDays} days',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Benefits
          ...package.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 18,
                    color: package.isPopular
                        ? AppColors.onTertiaryContainer
                        : AppColors.outline,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      benefit,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // CTA Button
          AppButton(
            label: package.isPopular ? 'Upgrade Now' : 'Purchase',
            variant: package.isPopular
                ? AppButtonVariant.primary
                : AppButtonVariant.ghost,
            onPressed: () => _showPurchaseSheet(context),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

class _PackageBadge extends StatelessWidget {
  const _PackageBadge({required this.icon, required this.label});

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

class _PurchaseConfirmationSheet extends ConsumerStatefulWidget {
  const _PurchaseConfirmationSheet({required this.package});

  final MembershipPackageModel package;

  @override
  ConsumerState<_PurchaseConfirmationSheet> createState() =>
      _PurchaseConfirmationSheetState();
}

class _PurchaseConfirmationSheetState
    extends ConsumerState<_PurchaseConfirmationSheet> {
  bool _isPurchasing = false;
  bool _purchaseSuccess = false;

  Future<void> _confirmPurchase() async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      // Purchase package via provider
      await ref
          .read(membershipRepositoryProvider)
          .purchasePackage(widget.package.id);

      // Add credits to wallet (mock)
      await ref
          .read(walletNotifierProvider.notifier)
          .addCredits(
            widget.package.credits ?? 0,
            'Purchased: ${widget.package.name}',
          );

      setState(() {
        _purchaseSuccess = true;
        _isPurchasing = false;
      });
    } catch (e) {
      setState(() {
        _isPurchasing = false;
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your package purchase was not completed. Please try again.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      child: SafeArea(
        top: false,
        child: _purchaseSuccess
            ? _SuccessContent(package: widget.package)
            : _ConfirmContent(
                package: widget.package,
                isPurchasing: _isPurchasing,
                onConfirm: _confirmPurchase,
              ),
      ),
    );
  }
}

class _ConfirmContent extends StatelessWidget {
  const _ConfirmContent({
    required this.package,
    required this.isPurchasing,
    required this.onConfirm,
  });

  final MembershipPackageModel package;
  final bool isPurchasing;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Title
          Text('Confirm Purchase', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          // Package Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Package', style: AppTypography.bodySm),
                    Text(package.name, style: AppTypography.bodySm),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Credits', style: AppTypography.bodySm),
                    Text(
                      package.hasUnlimitedCredits
                          ? 'Unlimited'
                          : '${package.credits}',
                      style: AppTypography.bodySm,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Validity', style: AppTypography.bodySm),
                    Text(
                      '${package.validityDays} days',
                      style: AppTypography.bodySm,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(color: AppColors.surfaceVariant),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTypography.bodyMd),
                    Text(
                      '\$${package.price.toStringAsFixed(2)}',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                  isExpanded: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: isPurchasing ? '...' : 'Confirm',
                  onPressed: isPurchasing ? null : onConfirm,
                  isLoading: isPurchasing,
                  isExpanded: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.package});

  final MembershipPackageModel package;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Success Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 32,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Title
          Text('Package Purchased!', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your ${package.name} package is now active.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Buttons
          AppButton(
            label: 'View My Credits',
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.wallet);
            },
            isExpanded: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Back to Home',
            variant: AppButtonVariant.text,
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
            },
            isExpanded: true,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _LoadingPackages extends StatelessWidget {
  const _LoadingPackages();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < 2 ? AppSpacing.md : 0),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
            ),
          ),
        ),
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
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No packages available',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check back soon for new packages',
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
