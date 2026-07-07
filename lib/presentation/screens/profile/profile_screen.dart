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
            const _ProfileHeaderSection(),
            const SizedBox(height: AppSpacing.xxl),
            const _ProfileMenuSection(),
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
          return const _ProfileInfoPlaceholder();
        }
        return _ProfileInfo(user: user);
      },
      loading: () => const _ProfileLoadingState(),
      error: (e, _) => _ProfileErrorState(
        message: 'Failed to load profile',
        onRetry: () => ref.invalidate(profileNotifierProvider),
      ),
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
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppShadows.elevated,
            ),
            child: ClipOval(
              child: user.profilePhoto.isNotEmpty
                  ? Image.network(
                      user.profilePhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _DefaultAvatar();
                      },
                    )
                  : _DefaultAvatar(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(user.fullName, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.email,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
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

class _DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: Icon(
        Icons.person,
        size: 48,
        color: AppColors.onSurfaceVariant,
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
  const _ProfileErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

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
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileInfoPlaceholder extends StatelessWidget {
  const _ProfileInfoPlaceholder();

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
            child: Icon(
              Icons.person,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Guest User', style: AppTypography.h2),
        ],
      ),
    );
  }
}

class _ProfileMenuSection extends ConsumerWidget {
  const _ProfileMenuSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              _ProfileMenuItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'My Credits',
                onTap: () => context.push(AppRoutes.wallet),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.history,
                label: 'Booking History',
                onTap: () => context.push(AppRoutes.bookingHistory),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => context.push(AppRoutes.notification),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                label: 'Account Settings',
                onTap: () => context.push(AppRoutes.accountSettings),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Help & Support coming soon'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.logout,
                label: 'Log Out',
                onTap: () => _showLogoutConfirmation(context, ref),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LogoutConfirmationSheet(),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive ? AppColors.error : AppColors.onSurface;

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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? AppColors.error : null,
                  ),
                ),
              ),
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

class _LogoutConfirmationSheet extends ConsumerStatefulWidget {
  const _LogoutConfirmationSheet();

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
      ref.invalidate(profileNotifierProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(walletNotifierProvider);
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
            Text('Log Out?', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Are you sure you want to log out? You can always come back.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
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
