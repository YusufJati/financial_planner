import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/account.dart';
import '../../blocs/account/account_bloc.dart';
import '../../widgets/common/stylish_header.dart';
import '../../widgets/common/common_widgets.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  Future<bool> _onBackPressed(BuildContext context) async {
    // Always navigate back to home instead of exiting the app
    context.go('/');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onBackPressed(context);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            const StylishHeader(
              title: 'Accounts',
              subtitle: 'Manage your accounts',
              showBackArrow: true,
            ),
            Expanded(
              child: BlocConsumer<AccountBloc, AccountState>(
                listener: (context, state) {
                  if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error!),
                      ),
                    );
                  }
                  if (state.successMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.successMessage!),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.isLoading && state.accounts.isEmpty) {
                    return const AppLoading();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AccountBloc>().add(LoadAccounts());
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Total Balance Card
                        _buildTotalBalanceCard(state.totalBalance),
                        const SizedBox(height: 24),

                        // Account List
                        Text('My Accounts', style: AppTextStyles.h4),
                        const SizedBox(height: 12),

                        if (state.accounts.isEmpty)
                          const EmptyState(
                            icon: LucideIcons.wallet,
                            title: 'No accounts yet',
                            subtitle: 'Add your first account to get started',
                          )
                        else
                          ...state.accounts.map((account) => _buildAccountCard(
                                context,
                                account,
                              )),

                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await context.push('/account/add');
            if (result == true) {
              if (context.mounted) {
                context.read<AccountBloc>().add(LoadAccounts());
              }
            }
          },
          icon: const Icon(LucideIcons.plus),
          label: const Text('Add Account'),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(double totalBalance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Balance',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(totalBalance),
            style: AppTextStyles.amountLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.toMonochrome(AppColors.fromHex(account.color));
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        elevation: 0,
        child: InkWell(
          onTap: () async {
            final result =
                await context.push('/account/detail', extra: account);
            if (result == true && context.mounted) {
              context.read<AccountBloc>().add(LoadAccounts());
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CategoryIcon(
                  icon: account.icon,
                  color: color,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        account.type.displayName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(account.currentBalance),
                      style: AppTextStyles.amountMedium.copyWith(
                        color: account.currentBalance >= 0
                            ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)
                            : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
