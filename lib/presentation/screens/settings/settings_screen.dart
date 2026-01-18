import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../data/datasources/local/database_service.dart';
import '../../../data/services/backup_restore_service.dart';
import '../../../injection.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../widgets/common/modern_dialogs.dart';
import '../../widgets/common/stylish_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider<SettingsBloc>.value(
      value: getIt<SettingsBloc>(),
      child: Scaffold(
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Use StylishHeader for consistency
                  const StylishHeader(
                    title: 'Settings',
                    subtitle: 'Customize your app',
                  ),

                  // Appearance Section
                  const _SectionHeader(title: 'Appearance'),
                  _SettingsSwitch(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Enable dark theme',
                    value: state.isDarkMode,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleDarkMode(value));
                    },
                  ),

                  // Currency Section
                  _SettingsTile(
                    icon: Icons.attach_money,
                    title: 'Currency',
                    subtitle: state.currencyCode,
                    onTap: () =>
                        _showCurrencyPicker(context, state.currencyCode),
                  ),
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Display Name',
                    subtitle: _getDisplayName(),
                    onTap: () => _showNameEditDialog(context),
                  ),

                  const Divider(height: 32),

                  // Management Section
                  const _SectionHeader(title: 'Management'),
                  _SettingsTile(
                    icon: Icons.category,
                    title: 'Categories',
                    subtitle: 'Manage expense & income categories',
                    onTap: () => context.push('/categories'),
                  ),
                  _SettingsTile(
                    icon: Icons.account_balance_wallet,
                    title: 'Accounts',
                    subtitle: 'Manage your accounts',
                    onTap: () => context.push('/accounts'),
                  ),
                  _SettingsTile(
                    icon: Icons.analytics,
                    title: 'Reports',
                    subtitle: 'View detailed financial reports',
                    onTap: () => context.push('/reports'),
                  ),
                  _SettingsTile(
                    icon: Icons.menu_book,
                    title: 'Financial Diary',
                    subtitle: 'Track daily cashflow & notes',
                    onTap: () => context.push('/diary'),
                  ),
                  _SettingsTile(
                    icon: Icons.repeat,
                    title: 'Recurring Transactions',
                    subtitle: 'Manage recurring payments',
                    onTap: () => context.push('/recurring'),
                  ),

                  const Divider(height: 32),

                  // Data Section
                  const _SectionHeader(title: 'Data'),
                  _SettingsTile(
                    icon: Icons.backup,
                    title: 'Backup Data',
                    subtitle: 'Export all data to JSON',
                    onTap: () => _backupData(context),
                  ),
                  _SettingsTile(
                    icon: Icons.download,
                    title: 'Export to CSV',
                    subtitle: 'Export transactions data',
                    onTap: () => _exportData(context),
                  ),
                  _SettingsTile(
                    icon: Icons.delete_forever,
                    iconColor: Colors.red,
                    title: 'Clear All Data',
                    subtitle: 'Delete all data and start fresh',
                    onTap: () => _confirmClearData(context),
                  ),

                  const Divider(height: 32),

                  // About Section
                  const _SectionHeader(title: 'About'),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About App',
                    subtitle: 'Version and information',
                    onTap: () => _showAboutDialog(context),
                  ),

                  const SizedBox(height: 32),

                  // App Info
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Financial Planner',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getDisplayName() {
    try {
      final db = getIt<DatabaseService>();
      return db.getSetting<String>('userName') ?? 'Financial Hero';
    } catch (_) {
      return 'Financial Hero';
    }
  }

  void _showNameEditDialog(BuildContext context) {
    final controller = TextEditingController(text: _getDisplayName());

    showAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final db = getIt<DatabaseService>();
                await db.saveSetting('userName', name);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  // Trigger rebuild by notifying through settings bloc
                  getIt<SettingsBloc>().add(LoadSettings());
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, String currentCurrency) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final selectedColor =
        isDark ? AppColors.borderDark : AppColors.primarySoft;

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Currency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: SettingsBloc.currencies.entries.map((entry) {
                      final isSelected = entry.key == currentCurrency;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? selectedColor : surfaceColor,
                            borderRadius: AppRadius.radiusSm,
                            border: Border.all(color: borderColor),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                        ),
                        title: Text(entry.key),
                        trailing: isSelected
                            ? const Icon(LucideIcons.check,
                                color: AppColors.primary)
                            : null,
                        onTap: () {
                          getIt<SettingsBloc>().add(ChangeCurrency(entry.key));
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      showAppDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (ctx) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );

      final service = BackupRestoreService(getIt<DatabaseService>());
      final filePath = await service.saveBackupToFile();

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading

        showSuccessDialog(
          context: context,
          title: 'Backup Berhasil! 🎉',
          message: 'Data kamu sudah aman tersimpan',
          details: filePath.split('/').last,
          buttonText: 'Tutup',
          additionalAction: OutlinedButton.icon(
            onPressed: () async {
              await service.copyToClipboard();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // Dismiss success dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Backup disalin ke clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(LucideIcons.copy),
            label: const Text('Salin ke Clipboard'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup gagal: $e')),
        );
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      showAppDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (ctx) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );

      final db = getIt<DatabaseService>();
      final transactions = db.transactionBox.values.toList();

      if (transactions.isEmpty) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No transactions to export')),
          );
        }
        return;
      }

      final buffer = StringBuffer();
      buffer.writeln('Date,Type,Category,Amount,Account,Note');

      for (final t in transactions) {
        final category = db.categoryBox.get(t.categoryId);
        final account = db.accountBox.get(t.accountId);
        final type = t.typeIndex == 0
            ? 'Expense'
            : (t.typeIndex == 1 ? 'Income' : 'Transfer');
        final date = DateFormat('yyyy-MM-dd').format(t.date);
        final note = t.note?.replaceAll(',', ';') ?? '';

        buffer.writeln(
            '$date,$type,${category?.name ?? ''},${t.amount},${account?.name ?? ''},$note');
      }

      final dir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final fileName =
          'transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
        showSuccessDialog(
          context: context,
          title: 'Export Berhasil! 📊',
          message: '${transactions.length} transaksi berhasil diekspor',
          details: fileName,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _confirmClearData(BuildContext context) async {
    final confirmed = await showModernDialog(
      context: context,
      icon: LucideIcons.trash2,
      title: 'Hapus Semua Data? 🗑️',
      subtitle:
          'Semua transaksi, akun, budget, dan goals akan dihapus permanen.',
      description: 'Aksi ini tidak dapat dibatalkan!',
      cancelText: 'Batal',
      confirmText: 'Hapus Semua',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      await _clearAllData(context);
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    try {
      showAppDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final db = getIt<DatabaseService>();
      await db.clearAll();

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully')),
        );

        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear data: $e')),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final iconColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    showAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.background,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: borderColor),
              ),
              child: Icon(LucideIcons.wallet, color: iconColor, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Financial Planner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'A complete personal finance manager with budget tracking, goals, and reports.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2026 Financial Planner',
              style: TextStyle(fontSize: 12, color: secondaryText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
