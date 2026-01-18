import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/colors.dart';
import '../../blocs/goal/goal_bloc.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _targetDate;
  String _selectedIcon = 'target';
  String _selectedColor = '#10B981';
  bool _isSubmitting = false;

  static const List<Map<String, dynamic>> _icons = [
    {'name': 'target', 'icon': Icons.gps_fixed},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'car', 'icon': Icons.directions_car},
    {'name': 'plane', 'icon': Icons.flight},
    {'name': 'graduation-cap', 'icon': Icons.school},
    {'name': 'ring', 'icon': Icons.favorite},
    {'name': 'baby', 'icon': Icons.child_care},
    {'name': 'umbrella', 'icon': Icons.umbrella},
    {'name': 'piggy-bank', 'icon': Icons.savings},
    {'name': 'laptop', 'icon': Icons.laptop},
    {'name': 'phone', 'icon': Icons.phone_android},
    {'name': 'camera', 'icon': Icons.camera_alt},
  ];

  static const List<String> _colors = [
    '#10B981',
    '#3B82F6',
    '#8B5CF6',
    '#EC4899',
    '#F59E0B',
    '#EF4444',
    '#06B6D4',
    '#6366F1',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _targetDate = date);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final amount = double.tryParse(
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    context.read<GoalBloc>().add(CreateGoal(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          targetAmount: amount,
          targetDate: _targetDate,
          icon: _selectedIcon,
          color: _selectedColor,
        ));

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) context.pop(true);
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
        title: const Text('New Goal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g. Emergency Fund',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Why are you saving?',
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Target Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CurrencyInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: 'Rp ',
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Target Date
            Text(
              'Target Date (optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _targetDate != null
                          ? DateFormat('dd MMM yyyy').format(_targetDate!)
                          : 'Select a date',
                      style: TextStyle(
                        color: _targetDate != null
                            ? null
                            : AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_targetDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => _targetDate = null),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Icon Picker
            Text(
              'Icon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((iconData) {
                final isSelected = _selectedIcon == iconData['name'];
                final color = AppColors.fromHex(_selectedColor);

                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconData['name']),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.2)
                          : (isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iconData['icon'] as IconData,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Color Picker
            Text(
              'Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((colorHex) {
                final isSelected = _selectedColor == colorHex;
                final color = AppColors.fromHex(colorHex);

                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: color.withOpacity(0.5), blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number =
        int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
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
