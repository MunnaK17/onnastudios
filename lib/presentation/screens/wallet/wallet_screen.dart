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
import '../../../data/models/wallet_transaction_model.dart';
import '../../providers/wallet_provider.dart';
import '../../../shared/widgets/state/app_state_widgets.dart';

String _formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
}

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const _HeaderSection(),
              const SizedBox(height: AppSpacing.xl),
              const _WalletBalanceSection(),
              const SizedBox(height: AppSpacing.xl),
              const _TransactionsSection(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
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
      child: Row(
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
          Text('My Credits', style: AppTypography.h2),
        ],
      ),
    );
  }
}

class _WalletBalanceSection extends ConsumerWidget {
  const _WalletBalanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.surfaceVariant),
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              children: [
                Text(
                  'Available Credits',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    walletAsync.when(
                      data: (wallet) => Text(
                        '${wallet.remainingCredits}',
                        style: AppTypography.h1.copyWith(
                          color: AppColors.primary,
                          fontSize: 48,
                        ),
                      ),
                      loading: () => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      error: (e, _) => Text(
                        '--',
                        style: AppTypography.h1.copyWith(
                          color: AppColors.primary,
                          fontSize: 48,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Credits',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                walletAsync.when(
                  data: (wallet) => _CreditStatusBadge(
                    isEnough: wallet.hasEnoughCredits,
                    remaining: wallet.remainingCredits,
                  ),
                  loading: () => const _CreditStatusBadge(isEnough: true, remaining: null),
                  error: (e, _) => const _CreditStatusBadge(isEnough: false, remaining: null),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Top Up Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.topUp),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Top Up Credits'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          walletAsync.when(
            data: (wallet) {
              if (wallet.remainingCredits < 3 && wallet.remainingCredits > 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.topUp),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.onErrorContainer, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Your credits are running low. Tap to top up.',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onErrorContainer,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: AppColors.onErrorContainer, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CreditStatusBadge extends StatelessWidget {
  const _CreditStatusBadge({required this.isEnough, required this.remaining});

  final bool isEnough;
  final int? remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isEnough
            ? AppColors.secondaryContainer.withAlpha(128)
            : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEnough ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 16,
            color: isEnough
                ? AppColors.onSecondaryContainer
                : AppColors.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            remaining != null
                ? (isEnough ? 'Ready to book' : 'Low balance')
                : 'Loading...',
            style: AppTypography.labelCaps.copyWith(
              color: isEnough
                  ? AppColors.onSecondaryContainer
                  : AppColors.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsSection extends ConsumerWidget {
  const _TransactionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Text('Recent Activity', style: AppTypography.h3),
        ),
        const SizedBox(height: AppSpacing.md),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions yet',
                subtitle: 'Your transaction history will appear here',
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  final isLast = index == transactions.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
                    child: _TransactionCard(transaction: transaction),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const AppLoadingState(),
          error: (e, _) => AppErrorState(
            onRetry: () => ref.invalidate(transactionHistoryProvider),
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final WalletTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == WalletTransactionType.credit;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceVariant.withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.secondaryContainer
                  : AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: isCredit
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${_formatDate(transaction.createdAt)}${isCredit ? '' : ' • ${_formatTime(transaction.createdAt)}'}',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.secondaryContainer.withAlpha(77)
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              isCredit ? '+${transaction.amount}' : '-${transaction.amount}',
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: isCredit ? AppColors.secondary : AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
