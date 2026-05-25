import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/user_model.dart';
import '../../providers/membership_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Profile Header
            const _ProfileHeaderSection(),
            const SizedBox(height: AppSpacing.xxl),
            // Membership Summary
            const _MembershipSummarySection(),
            const SizedBox(height: AppSpacing.xxl),
            // Profile Menu
            const _ProfileMenuSection(),
            const SizedBox(height: AppSpacing.xxl),
            // Logout Button
            const _LogoutSection(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderSection extends ConsumerWidget {
  const _ProfileHeaderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return profileAsync.when(
      data: (user) {
        if (user == null) {
          return const _ProfileErrorState(message: 'Profile not found');
        }
        return _ProfileInfo(user: user);
      },
      loading: () => const _ProfileLoadingState(),
      error: (e, st) => _ProfileErrorState(message: 'Failed to load profile'),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppShadows.elevated,
            ),
            child: ClipOval(
              child: Image.network(
                user.profilePhoto,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceContainerHigh,
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Name
          Text(user.fullName, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.xs),
          // Email
          Text(
            user.email,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          // Phone
          Text(
            user.phone,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 160,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.errorContainer,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.onErrorContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTypography.bodyMd.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _MembershipSummarySection extends ConsumerWidget {
  const _MembershipSummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMembershipAsync = ref.watch(activeMembershipProvider);
    final walletAsync = ref.watch(walletNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
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
                // Active Package
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      color: AppColors.onTertiaryFixed,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Active Package',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onTertiaryFixed.withAlpha(179),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                activeMembershipAsync.when(
                  data: (membership) => Text(
                    membership?.name ?? 'No active package',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.onTertiaryFixed,
                    ),
                  ),
                  loading: () => Container(
                    width: 120,
                    height: 24,
                    color: AppColors.onTertiaryFixed.withAlpha(51),
                  ),
                  error: (e, st) => Text(
                    'Unable to load',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onTertiaryFixed.withAlpha(179),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Credits and Validity Row
                Row(
                  children: [
                    // Credits
                    Expanded(
                      child: walletAsync.when(
                        data: (wallet) => _MembershipBadge(
                          icon: Icons.monetization_on_outlined,
                          label: '${wallet.remainingCredits} Credits',
                        ),
                        loading: () => _MembershipBadge(
                          icon: Icons.monetization_on_outlined,
                          label: '...',
                        ),
                        error: (e, st) => _MembershipBadge(
                          icon: Icons.monetization_on_outlined,
                          label: '--',
                        ),
                      ),
                    ),
                    // Validity
                    Expanded(
                      child: activeMembershipAsync.when(
                        data: (membership) => _MembershipBadge(
                          icon: Icons.calendar_today_outlined,
                          label: membership != null
                              ? '${membership.validityDays} days'
                              : '--',
                        ),
                        loading: () => _MembershipBadge(
                          icon: Icons.calendar_today_outlined,
                          label: '...',
                        ),
                        error: (e, st) => _MembershipBadge(
                          icon: Icons.calendar_today_outlined,
                          label: '--',
                        ),
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

class _MembershipBadge extends StatelessWidget {
  const _MembershipBadge({required this.icon, required this.label});

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
        color: AppColors.onTertiaryFixed.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onTertiaryFixed),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onTertiaryFixed,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Text('Settings', style: AppTypography.h3),
        ),
        const SizedBox(height: AppSpacing.md),
        // Menu Items
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              _ProfileMenuItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'My Credits',
                onTap: () => context.go(AppRoutes.wallet),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.history,
                label: 'Booking History',
                onTap: () => context.go(AppRoutes.bookingHistory),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => context.go(AppRoutes.notification),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.location_on_outlined,
                label: 'Location',
                onTap: () => context.go(AppRoutes.location),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                label: 'Account Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Account settings coming soon'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Help & Support coming soon'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.onSurface, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              // Label
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right,
                color: AppColors.outlineVariant,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutSection extends ConsumerWidget {
  const _LogoutSection();

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LogoutConfirmationSheet(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: OutlinedButton(
        onPressed: () => _showLogoutConfirmation(context, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurfaceVariant,
          side: BorderSide(color: AppColors.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTypography.labelCaps,
        ),
        child: const Text('LOG OUT'),
      ),
    );
  }
}

class _LogoutConfirmationSheet extends ConsumerStatefulWidget {
  const _LogoutConfirmationSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_LogoutConfirmationSheet> createState() =>
      _LogoutConfirmationSheetState();
}

class _LogoutConfirmationSheetState
    extends ConsumerState<_LogoutConfirmationSheet> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) {
        Navigator.pop(context);
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Logout failed. Please try again.'),
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
            const SizedBox(height: AppSpacing.xl),
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout,
                size: 28,
                color: AppColors.onErrorContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            Text('Log Out?', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            // Description
            Text(
              'Are you sure you want to log out? You can always come back.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoggingOut
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      side: BorderSide(color: AppColors.outline),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onError,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: _isLoggingOut
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onError,
                            ),
                          )
                        : const Text('LOG OUT'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
