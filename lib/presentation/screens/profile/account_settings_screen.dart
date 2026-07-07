import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_error_message.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _photoController = TextEditingController();

  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isSendingReset = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _initialize(UserProfileSnapshot snapshot) {
    if (_isInitialized) return;
    _nameController.text = snapshot.fullName;
    _emailController.text = snapshot.email;
    _phoneController.text = snapshot.phone;
    _photoController.text = snapshot.profilePhoto;
    _isInitialized = true;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateProfile(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            profilePhoto: _photoController.text.trim(),
          );
      ref.invalidate(userProfileProvider);
      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account updated successfully.'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appErrorMessage(e, fallback: 'Unable to update account.'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a valid email first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSendingReset = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to $email'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appErrorMessage(
                e,
                fallback: 'Unable to send password reset email.',
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Account Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (user) {
            if (user == null) {
              return const _SettingsMessage(message: 'Profile not found.');
            }

            _initialize(
              UserProfileSnapshot(
                fullName: user.fullName,
                email: user.email,
                phone: user.phone,
                profilePhoto: user.profilePhoto,
              ),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfilePreview(photoUrl: _photoController.text),
                    const SizedBox(height: AppSpacing.xl),
                    _SettingsCard(
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.onSurfaceVariant,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().length < 2) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.onSurfaceVariant,
                            ),
                            validator: (value) {
                              if (!_isValidEmail((value ?? '').trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            hint: 'Enter your phone number',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _photoController,
                            label: 'Profile Photo URL',
                            hint: 'https://...',
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icon(
                              Icons.image_outlined,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Save Changes',
                      onPressed: _saveProfile,
                      isLoading: _isSaving,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Send Password Reset',
                      variant: AppButtonVariant.ghost,
                      onPressed: _isSendingReset ? null : _sendPasswordReset,
                      isLoading: _isSendingReset,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => _SettingsMessage(
            message: appErrorMessage(e, fallback: 'Unable to load account.'),
          ),
        ),
      ),
    );
  }
}

class UserProfileSnapshot {
  const UserProfileSnapshot({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePhoto,
  });

  final String fullName;
  final String email;
  final String phone;
  final String profilePhoto;
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
          boxShadow: AppShadows.elevated,
        ),
        child: ClipOval(
          child: photoUrl.isEmpty
              ? Icon(Icons.person, size: 48, color: AppColors.onSurfaceVariant)
              : Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.onSurfaceVariant,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.subtle,
      ),
      child: child,
    );
  }
}

class _SettingsMessage extends StatelessWidget {
  const _SettingsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Text(
          message,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
