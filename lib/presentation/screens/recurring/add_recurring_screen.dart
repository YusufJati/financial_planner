import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/account.dart';
import '../../blocs/recurring/recurring_bloc.dart';

class AddRecurringScreen extends StatefulWidget {
  const AddRecurringScreen({super.key});

  @override
  State<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends State<AddRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  Account? _selectedAccount;
  RecurringFrequency _selectedFrequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Recurring'),
      ),
      body: BlocBuilder<RecurringBloc, RecurringState>(
        builder: (context, state) {
          // Set defaults
          if (_selectedAccount == null && state.accounts.isNotEmpty) {
            _selectedAccount = state.accounts.first;
          }
          if (_selectedCategory == null) {
            if (_selectedType == TransactionType.expense &&
                state.expenseCategories.isNotEmpty) {
              _selectedCategory = state.expenseCategories.first;
            } else if (_selectedType == TransactionType.income &&
                state.incomeCategories.isNotEmpty) {
              _selectedCategory = state.incomeCategories.first;
            }
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Netflix Subscription',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),

                const SizedBox(height: 16),

                // Type Selector
                _buildTypeSelector(),

                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CurrencyInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'Rp ',
                  ),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _selectedType == TransactionType.expense
                        ? AppColors.expense
                        : AppColors.income,
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    final amount = double.tryParse(v!.replaceAll('.', ''));
                    if (amount == null || amount <= 0) return 'Invalid amount';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Category
                _buildCategorySelector(state),

                const SizedBox(height: 16),

                // Account
                _buildAccountSelector(state),

                const SizedBox(height: 16),

                // Frequency
                _buildFrequencySelector(),

                const SizedBox(height: 16),

                // Start Date
                _buildDateSelector(
                  label: 'Start Date',
                  date: _startDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // End Date (optional)
                _buildDateSelector(
                  label: 'End Date (optional)',
                  date: _endDate,
                  isOptional: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          _endDate ?? _startDate.add(const Duration(days: 365)),
                      firstDate: _startDate,
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                    }
                  },
                  onClear: () => setState(() => _endDate = null),
                ),

                const SizedBox(height: 16),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 32),

                // Submit
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Recurring'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildTypeButton(
              'Expense', TransactionType.expense, AppColors.expense),
          _buildTypeButton('Income', TransactionType.income, AppColors.income),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type, Color color) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedCategory = null;
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
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(RecurringState state) {
    final categories = _selectedType == TransactionType.expense
        ? state.expenseCategories
        : state.incomeCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory?.id == category.id;
            final color = AppColors.fromHex(category.color);
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? color.withOpacity(0.2) : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAccountSelector(RecurringState state) {
    return DropdownButtonFormField<Account>(
      initialValue: _selectedAccount,
      decoration: const InputDecoration(labelText: 'Account'),
      items: state.accounts.map((account) {
        return DropdownMenuItem(
          value: account,
          child: Text(account.name),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedAccount = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RecurringFrequency.values.map((freq) {
            final isSelected = _selectedFrequency == freq;
            return GestureDetector(
              onTap: () => setState(() => _selectedFrequency = freq),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  freq.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool isOptional = false,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    date != null
                        ? DateFormat('dd MMM yyyy').format(date)
                        : 'Not set',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: date != null ? null : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isOptional && date != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final amount = double.parse(
      _amountController.text.replaceAll('.', ''),
    );

    context.read<RecurringBloc>().add(CreateRecurring(
          name: _nameController.text.trim(),
          amount: amount,
          type: _selectedType,
          categoryId: _selectedCategory!.id,
          accountId: _selectedAccount!.id,
          frequency: _selectedFrequency,
          startDate: _startDate,
          endDate: _endDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ));

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) context.pop(true);
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) return oldValue;
    final formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
