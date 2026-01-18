import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/category.dart';
import '../../blocs/category/category_bloc.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category; // null for add, non-null for edit

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  CategoryType _selectedType = CategoryType.expense;
  String _selectedIcon = 'shopping-bag';
  String _selectedColor = AppColors.toHex(AppColors.categoryColors.first);
  bool _isSubmitting = false;

  bool get isEditing => widget.category != null;

  // Available icons
  static const List<Map<String, dynamic>> _icons = [
    {'name': 'utensils', 'icon': LucideIcons.utensils},
    {'name': 'car', 'icon': LucideIcons.car},
    {'name': 'shopping-bag', 'icon': LucideIcons.shoppingBag},
    {'name': 'file-text', 'icon': LucideIcons.fileText},
    {'name': 'heart-pulse', 'icon': LucideIcons.heartPulse},
    {'name': 'gamepad-2', 'icon': LucideIcons.gamepad2},
    {'name': 'graduation-cap', 'icon': LucideIcons.graduationCap},
    {'name': 'briefcase', 'icon': LucideIcons.briefcase},
    {'name': 'gift', 'icon': LucideIcons.gift},
    {'name': 'trending-up', 'icon': LucideIcons.trendingUp},
    {'name': 'heart', 'icon': LucideIcons.heart},
    {'name': 'home', 'icon': LucideIcons.home},
    {'name': 'plane', 'icon': LucideIcons.plane},
    {'name': 'coffee', 'icon': LucideIcons.coffee},
    {'name': 'music', 'icon': LucideIcons.music},
    {'name': 'book', 'icon': LucideIcons.book},
    {'name': 'camera', 'icon': LucideIcons.camera},
    {'name': 'phone', 'icon': LucideIcons.phone},
    {'name': 'tv', 'icon': LucideIcons.tv},
    {'name': 'wifi', 'icon': LucideIcons.wifi},
    {'name': 'fitness', 'icon': LucideIcons.dumbbell},
    {'name': 'pets', 'icon': LucideIcons.cat},
    {'name': 'star', 'icon': LucideIcons.star},
    {'name': 'more-horizontal', 'icon': LucideIcons.moreHorizontal},
  ];

  // Available colors
  static final List<String> _colors =
      AppColors.categoryColors.map(AppColors.toHex).toList();

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedIcon = widget.category!.icon;
      _selectedColor = AppColors.toHex(
        AppColors.toMonochrome(AppColors.fromHex(widget.category!.color)),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    if (isEditing) {
      context.read<CategoryBloc>().add(UpdateCategory(
            widget.category!.copyWith(
              name: _nameController.text.trim(),
              type: _selectedType,
              icon: _selectedIcon,
              color: _selectedColor,
            ),
          ));
    } else {
      context.read<CategoryBloc>().add(CreateCategory(
            name: _nameController.text.trim(),
            type: _selectedType,
            icon: _selectedIcon,
            color: _selectedColor,
          ));
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Food & Drinks',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Type Selector
              Text(
                'Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: CategoryType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: type == CategoryType.expense ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primarySoft
                              : (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              type == CategoryType.expense
                                  ? LucideIcons.arrowUp
                                  : LucideIcons.arrowDown,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.displayName,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : null,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _icons.map((iconData) {
                    final isSelected = _selectedIcon == iconData['name'];
                    final color = AppColors.toMonochrome(
                      AppColors.fromHex(_selectedColor),
                    );

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedIcon = iconData['name']),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          iconData['icon'] as IconData,
                          color: isSelected ? color : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (() {
                    final colors = _colors.contains(_selectedColor)
                        ? _colors
                        : [_selectedColor, ..._colors];
                    return colors.map((colorHex) {
                      final isSelected = _selectedColor == colorHex;
                      final color = AppColors.toMonochrome(
                        AppColors.fromHex(colorHex),
                      );

                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = colorHex),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(LucideIcons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList();
                  })(),
                ),
              ),

              const SizedBox(height: 32),

              // Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.toMonochrome(
                          AppColors.fromHex(_selectedColor),
                        ).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _icons.firstWhere(
                                (i) => i['name'] == _selectedIcon)['icon']
                            as IconData,
                        color: AppColors.toMonochrome(
                          AppColors.fromHex(_selectedColor),
                        ),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isEmpty
                                ? 'Category Name'
                                : _nameController.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _selectedType.displayName,
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
                  ],
                ),
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
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Update Category' : 'Create Category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
