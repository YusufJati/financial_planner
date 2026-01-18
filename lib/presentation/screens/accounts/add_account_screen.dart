import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/account.dart';
import '../../blocs/account/account_bloc.dart';

class AddAccountScreen extends StatefulWidget {
  final Account? account;

  const AddAccountScreen({super.key, this.account});

  bool get isEditing => account != null;

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  AccountType _selectedType = AccountType.cash;
  String _selectedIcon = 'wallet';
  Color _selectedColor = AppColors.categoryColors[0];

  final List<Map<String, dynamic>> _accountIcons = [
    {'name': 'wallet', 'icon': Icons.wallet},
    {'name': 'building-2', 'icon': Icons.account_balance},
    {'name': 'smartphone', 'icon': Icons.smartphone},
    {'name': 'credit-card', 'icon': Icons.credit_card},
    {'name': 'piggy-bank', 'icon': Icons.savings},
    {'name': 'briefcase', 'icon': Icons.work},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final account = widget.account!;
      _nameController.text = account.name;
      _balanceController.text =
          CurrencyFormatter.formatNumber(account.initialBalance);
      _selectedType = account.type;
      _selectedIcon = account.icon;
      _selectedColor = AppColors.fromHex(account.color);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Account' : 'Add Account',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            context.pop(true);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Card
              _buildPreviewCard(isDark),
              const SizedBox(height: AppSpacing.xxl),

              // Account Name
              Text('Account Name',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _nameController,
                style: GoogleFonts.spaceMono(),
                decoration: InputDecoration(
                  hintText: 'e.g., Cash, BCA, GoPay',
                  hintStyle: GoogleFonts.spaceMono(color: AppColors.textSecondary),
                  border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Account Type
              Text('Account Type',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: AppSpacing.sm),
              _buildTypeSelector(isDark),
              const SizedBox(height: AppSpacing.lg),

              // Balance
              Text('Initial Balance',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.spaceMono(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle:
                      GoogleFonts.spaceMono(color: AppColors.textSecondary),
                  border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final number = int.tryParse(value.replaceAll('.', '')) ?? 0;
                    final formatted =
                        CurrencyFormatter.formatNumber(number.toDouble());
                    if (formatted != value) {
                      _balanceController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                  setState(() {});
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Icon Selector
              Text('Icon',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: AppSpacing.sm),
              _buildIconSelector(isDark),
              const SizedBox(height: AppSpacing.lg),

              // Color Selector
              Text('Color',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: AppSpacing.sm),
              _buildColorSelector(),
              const SizedBox(height: AppSpacing.s32),

              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark) {
    final balanceText = _balanceController.text.replaceAll('.', '');
    final balance = double.tryParse(balanceText) ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: _selectedColor.withAlpha(25),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: _selectedColor),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _selectedColor.withAlpha(50),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(
              _getIconData(_selectedIcon),
              color: _selectedColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty
                      ? 'Account Name'
                      : _nameController.text,
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _selectedType.displayName,
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(balance),
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AccountType.values.map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(type.displayName),
          labelStyle: GoogleFonts.spaceMono(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedType = type;
                switch (type) {
                  case AccountType.cash:
                    _selectedIcon = 'wallet';
                    break;
                  case AccountType.bank:
                    _selectedIcon = 'building-2';
                    break;
                  case AccountType.eWallet:
                    _selectedIcon = 'smartphone';
                    break;
                  case AccountType.creditCard:
                    _selectedIcon = 'credit-card';
                    break;
                }
              });
            }
          },
          selectedColor: AppColors.primarySoft,
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector(bool isDark) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: _accountIcons.map((item) {
        final isSelected = _selectedIcon == item['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = item['name']),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedColor.withAlpha(50)
                  : (isDark ? AppColors.surfaceDark : AppColors.surface),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color: isSelected ? _selectedColor : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: isSelected ? _selectedColor : AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: AppColors.categoryColors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.textPrimary, width: 3)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state.isSaving ? null : _saveAccount,
            child: state.isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Save Account',
                    style: GoogleFonts.spaceMono(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'wallet': Icons.wallet,
      'building-2': Icons.account_balance,
      'smartphone': Icons.smartphone,
      'credit-card': Icons.credit_card,
      'piggy-bank': Icons.savings,
      'briefcase': Icons.work,
    };
    return iconMap[iconName] ?? Icons.wallet;
  }

  void _saveAccount() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please enter account name', style: GoogleFonts.spaceMono()),
        ),
      );
      return;
    }

    final balanceText = _balanceController.text.replaceAll('.', '');
    final balance = double.tryParse(balanceText) ?? 0;

    if (widget.isEditing) {
      final updatedAccount = widget.account!.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        initialBalance: balance,
        icon: _selectedIcon,
        color: AppColors.toHex(_selectedColor),
      );
      context.read<AccountBloc>().add(UpdateAccount(updatedAccount));
    } else {
      context.read<AccountBloc>().add(AddAccount(
            name: _nameController.text.trim(),
            type: _selectedType,
            initialBalance: balance,
            icon: _selectedIcon,
            color: AppColors.toHex(_selectedColor),
          ));
    }
  }
}
