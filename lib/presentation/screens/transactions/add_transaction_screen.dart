import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/account.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../widgets/common/common_widgets.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  Category? _selectedCategory;
  Account? _selectedAccount;
  Account? _selectedToAccount;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadFormData());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
              ),
            );
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
        builder: (context, state) {
          if (state.isLoading && state.accounts.isEmpty) {
            return const AppLoading();
          }

          // Set default account if not set
          if (_selectedAccount == null && state.accounts.isNotEmpty) {
            _selectedAccount = state.accounts.first;
          }

          // Set default category based on type
          if (_selectedCategory == null) {
            if (_selectedType == TransactionType.expense &&
                state.expenseCategories.isNotEmpty) {
              _selectedCategory = state.expenseCategories.first;
            } else if (_selectedType == TransactionType.income &&
                state.incomeCategories.isNotEmpty) {
              _selectedCategory = state.incomeCategories.first;
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type Selector
                _buildTypeSelector(),
                const SizedBox(height: 24),

                // Amount Input
                _buildAmountInput(),
                const SizedBox(height: 24),

                // Category Selector (hidden for transfer)
                if (_selectedType != TransactionType.transfer) ...[
                  _buildCategorySelector(state),
                  const SizedBox(height: 16),
                ],

                // Account Selector
                _buildAccountSelector(state),
                const SizedBox(height: 16),

                // To Account Selector (for transfer)
                if (_selectedType == TransactionType.transfer) ...[
                  _buildToAccountSelector(state),
                  const SizedBox(height: 16),
                ],

                // Date Selector
                _buildDateSelector(),
                const SizedBox(height: 16),

                // Note Input
                _buildNoteInput(),
                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildTypeButton(
            label: 'Expense',
            type: TransactionType.expense,
            color: AppColors.expense,
          ),
          _buildTypeButton(
            label: 'Income',
            type: TransactionType.income,
            color: AppColors.income,
          ),
          _buildTypeButton(
            label: 'Transfer',
            type: TransactionType.transfer,
            color: AppColors.transfer,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required TransactionType type,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedCategory = null; // Reset category when type changes
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: AppTextStyles.amountLarge.copyWith(
            color: _selectedType == TransactionType.expense
                ? AppColors.expense
                : _selectedType == TransactionType.income
                    ? AppColors.income
                    : AppColors.transfer,
          ),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: AppTextStyles.amountLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            hintText: '0',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            // Format number with thousand separator
            if (value.isNotEmpty) {
              final number = int.tryParse(value.replaceAll('.', '')) ?? 0;
              final formatted =
                  CurrencyFormatter.formatNumber(number.toDouble());
              if (formatted != value) {
                _amountController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelector(TransactionState state) {
    final categories = _selectedType == TransactionType.expense
        ? state.expenseCategories
        : state.incomeCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final category = categories[index];
              final isSelected = _selectedCategory?.id == category.id;
              final color = AppColors.fromHex(category.color);

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = category);
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : (isDark ? AppColors.surfaceDark : AppColors.surface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CategoryIcon(
                        icon: category.icon,
                        color: color,
                        size: 36,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.name,
                        style: AppTextStyles.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelector(TransactionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedType == TransactionType.transfer
              ? 'From Account'
              : 'Account',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        _buildAccountDropdown(
          accounts: state.accounts,
          selectedAccount: _selectedAccount,
          onChanged: (account) {
            setState(() => _selectedAccount = account);
          },
          excludeAccount: _selectedToAccount,
        ),
      ],
    );
  }

  Widget _buildToAccountSelector(TransactionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('To Account', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        _buildAccountDropdown(
          accounts: state.accounts,
          selectedAccount: _selectedToAccount,
          onChanged: (account) {
            setState(() => _selectedToAccount = account);
          },
          excludeAccount: _selectedAccount,
        ),
      ],
    );
  }

  Widget _buildAccountDropdown({
    required List<Account> accounts,
    required Account? selectedAccount,
    required Function(Account?) onChanged,
    Account? excludeAccount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredAccounts = excludeAccount != null
        ? accounts.where((a) => a.id != excludeAccount.id).toList()
        : accounts;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Account>(
          value: selectedAccount,
          isExpanded: true,
          hint: const Text('Select Account'),
          items: filteredAccounts.map((account) {
            final color =
                AppColors.toMonochrome(AppColors.fromHex(account.color));
            return DropdownMenuItem<Account>(
              value: account,
              child: Row(
                children: [
                  CategoryIcon(icon: account.icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(account.name, style: AppTextStyles.bodyMedium),
                        Text(
                          CurrencyFormatter.format(account.currentBalance),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_selectedDate),
                      style: AppTextStyles.bodyLarge,
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note (optional)', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Add a note...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(TransactionState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state.isSaving ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedType == TransactionType.expense
              ? AppColors.expense
              : _selectedType == TransactionType.income
                  ? AppColors.income
                  : AppColors.transfer,
        ),
        child: state.isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Transaction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return 'Today, ${date.day}/${date.month}/${date.year}';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${date.day}/${date.month}/${date.year}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveTransaction() {
    // Validate
    final amountText = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
        ),
      );
      return;
    }

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account'),
        ),
      );
      return;
    }

    if (_selectedType == TransactionType.transfer &&
        _selectedToAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select destination account'),
        ),
      );
      return;
    }

    if (_selectedType != TransactionType.transfer &&
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
        ),
      );
      return;
    }

    context.read<TransactionBloc>().add(AddTransaction(
          type: _selectedType,
          amount: amount,
          categoryId: _selectedCategory?.id ?? '',
          accountId: _selectedAccount!.id,
          toAccountId: _selectedToAccount?.id,
          date: _selectedDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ));
  }
}
