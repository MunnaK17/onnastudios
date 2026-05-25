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
import '../../../shared/widgets/buttons/app_button.dart';

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour > 12
      ? date.hour - 12
      : (date.hour == 0 ? 12 : date.hour);
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
}

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

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
            // Wallet Balance Section
            const _WalletBalanceSection(),
            const SizedBox(height: AppSpacing.xl),
            // Transactions Section
            const _TransactionsSection(),
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
      child: Text('My Credits', style: AppTypography.h2),
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
          // Balance Card
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
                // Label
                Text(
                  'Available Credits',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Balance
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
                      error: (e, st) => Text(
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
                // Status Indicator
                walletAsync.when(
                  data: (wallet) => _CreditStatusBadge(
                    isEnough: wallet.hasEnoughCredits,
                    remaining: wallet.remainingCredits,
                  ),
                  loading: () =>
                      const _CreditStatusBadge(isEnough: true, remaining: null),
                  error: (e, st) => const _CreditStatusBadge(
                    isEnough: false,
                    remaining: null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Low Credit Warning
          walletAsync.when(
            data: (wallet) {
              if (wallet.remainingCredits < 3 && wallet.remainingCredits > 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Your credits are running low. Consider purchasing more.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          // Buy More Credits Button
          AppButton(
            label: 'Buy More Credits',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.package),
            isExpanded: true,
            icon: Icons.add_circle_outline,
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
              return const _EmptyTransactions();
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
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : AppSpacing.sm,
                    ),
                    child: _TransactionCard(transaction: transaction),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const _LoadingTransactions(),
          error: (e, st) => const _ErrorTransactions(),
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
          // Icon
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
          // Details
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
          // Amount
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

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No transactions yet',
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

class _LoadingTransactions extends StatelessWidget {
  const _LoadingTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < 2 ? AppSpacing.sm : 0),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: 100,
                          height: 12,
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

class _ErrorTransactions extends StatelessWidget {
  const _ErrorTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unable to load transactions',
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
