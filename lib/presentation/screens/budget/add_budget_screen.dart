import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/themes/colors.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/category.dart';
import '../../blocs/budget/budget_bloc.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  Category? _selectedCategory;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

    final amount = double.tryParse(
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    context.read<BudgetBloc>().add(CreateBudget(
          categoryId: _selectedCategory!.id,
          amount: amount,
          period: _selectedPeriod,
        ));

    // Wait a bit for the bloc to process
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Budget'),
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Category Picker
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _CategoryPicker(
                  categories: state.expenseCategories,
                  selectedCategory: _selectedCategory,
                  onChanged: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),

                const SizedBox(height: 24),

                // Amount Input
                Text(
                  'Budget Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CurrencyInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    hintText: '0',
                    filled: true,
                    fillColor:
                        isDark ? AppColors.surfaceDark : AppColors.surface,
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(
                      value.replaceAll(RegExp(r'[^0-9]'), ''),
                    );
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Period Selector
                Text(
                  'Budget Period',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _PeriodSelector(
                  selectedPeriod: _selectedPeriod,
                  onChanged: (period) {
                    setState(() => _selectedPeriod = period);
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
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
                        : const Text('Create Budget'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category> onChanged;

  const _CategoryPicker({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedCategory?.id == category.id;
        final color = AppColors.fromHex(category.color);

        return GestureDetector(
          onTap: () => onChanged(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : (isDark ? AppColors.surfaceDark : AppColors.surface),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category.icon),
                  size: 18,
                  color: isSelected
                      ? color
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected
                        ? color
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    final iconMap = {
      'utensils': Icons.restaurant,
      'car': Icons.directions_car,
      'shopping-bag': Icons.shopping_bag,
      'file-text': Icons.receipt,
      'heart-pulse': Icons.medical_services,
      'gamepad-2': Icons.sports_esports,
      'graduation-cap': Icons.school,
      'more-horizontal': Icons.more_horiz,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}

class _PeriodSelector extends StatelessWidget {
  final BudgetPeriod selectedPeriod;
  final ValueChanged<BudgetPeriod> onChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BudgetPeriod.values.map((period) {
        final isSelected = selectedPeriod == period;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: period != BudgetPeriod.yearly ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getPeriodIcon(period),
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    period.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getPeriodIcon(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return Icons.view_week_outlined;
      case BudgetPeriod.monthly:
        return Icons.calendar_month_outlined;
      case BudgetPeriod.yearly:
        return Icons.calendar_today_outlined;
    }
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number =
        int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) {
      return oldValue;
    }

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
