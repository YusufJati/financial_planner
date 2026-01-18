import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/account.dart';
import '../../blocs/account/account_bloc.dart';
import '../../widgets/common/modern_dialogs.dart';

class AccountDetailScreen extends StatelessWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
            ),
          );
          if (state.successMessage == 'Account deleted') {
            context.pop(true);
          }
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
            ),
          );
        }
      },
      builder: (context, state) {
        final currentAccount = state.accounts.firstWhere(
          (a) => a.id == account.id,
          orElse: () => account,
        );

        return _AccountDetailContent(account: currentAccount);
      },
    );
  }
}

class _AccountDetailContent extends StatelessWidget {
  final Account account;

  const _AccountDetailContent({required this.account});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawColor = AppColors.fromHex(account.color);
    final headerDark =
        AppColors.toMonochrome(rawColor, minLightness: 0.18, maxLightness: 0.32);
    final headerLight =
        AppColors.toMonochrome(rawColor, minLightness: 0.32, maxLightness: 0.5);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text('Account Details',
            style: GoogleFonts.spaceMono(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () async {
              final result =
                  await context.push('/account/edit', extra: account);
              if (result == true && context.mounted) {
                context.read<AccountBloc>().add(LoadAccounts());
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreHorizontal),
            onSelected: (value) {
              if (value == 'delete') _confirmDelete(context);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete Account',
                    style: GoogleFonts.spaceMono()),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [headerDark, headerLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.radiusXxl,
                  boxShadow: [
                    BoxShadow(
                      color: headerDark.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Icon(
                        _getAccountIcon(account.icon),
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      account.name,
                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm - 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text(
                        account.type.displayName,
                        style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Current Balance',
                      style: GoogleFonts.spaceMono(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      CurrencyFormatter.format(account.currentBalance),
                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Initial Balance',
                      value: CurrencyFormatter.formatCompact(
                          account.initialBalance),
                      icon: LucideIcons.wallet,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      title: 'Change',
                      value: _formatChange(
                          account.currentBalance - account.initialBalance),
                      icon: account.currentBalance >= account.initialBalance
                          ? LucideIcons.trendingUp
                          : LucideIcons.trendingDown,
                      color: account.currentBalance >= account.initialBalance
                          ? AppColors.income
                          : AppColors.expense,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Account Info
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: AppRadius.radiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: GoogleFonts.spaceMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _InfoRow(
                      icon: LucideIcons.calendar,
                      label: 'Created',
                      value:
                          DateFormat('dd MMM yyyy').format(account.createdAt),
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InfoRow(
                      icon: LucideIcons.refreshCw,
                      label: 'Last Updated',
                      value: DateFormat('dd MMM yyyy, HH:mm')
                          .format(account.updatedAt),
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InfoRow(
                      icon: LucideIcons.checkCircle,
                      label: 'Status',
                      value: account.isActive ? 'Active' : 'Inactive',
                      isDark: isDark,
                      valueColor: account.isActive
                          ? AppColors.income
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s32),

              // Edit Button
              ElevatedButton.icon(
                onPressed: () async {
                  final result =
                      await context.push('/account/edit', extra: account);
                  if (result == true && context.mounted) {
                    context.read<AccountBloc>().add(LoadAccounts());
                  }
                },
                icon: const Icon(LucideIcons.pencil),
                label: Text('Edit Account',
                    style: GoogleFonts.spaceMono(fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Delete Button
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(LucideIcons.trash2, color: AppColors.expense),
                label: Text(
                  'Delete Account',
                  style: GoogleFonts.spaceMono(
                      color: AppColors.expense, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  side: const BorderSide(color: AppColors.expense),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatChange(double change) {
    final prefix = change >= 0 ? '+' : '';
    return '$prefix${CurrencyFormatter.formatCompact(change)}';
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showModernDialog(
      context: context,
      icon: LucideIcons.trash2,
      title: 'Hapus Account? 🗑️',
      subtitle: 'Account "${account.name}" akan dihapus.',
      description:
          'Semua transaksi terkait account ini akan kehilangan referensinya.',
      cancelText: 'Batal',
      confirmText: 'Hapus',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<AccountBloc>().add(DeleteAccount(account.id));
    }
  }

  IconData _getAccountIcon(String iconName) {
    final iconMap = {
      'wallet': LucideIcons.wallet,
      'building-2': LucideIcons.building2,
      'smartphone': LucideIcons.smartphone,
      'credit-card': LucideIcons.creditCard,
      'piggy-bank': LucideIcons.piggyBank,
      'briefcase': LucideIcons.briefcase,
    };
    return iconMap[iconName] ?? LucideIcons.wallet;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: GoogleFonts.spaceMono(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: GoogleFonts.spaceMono(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.w500,
            color: valueColor ??
                (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
