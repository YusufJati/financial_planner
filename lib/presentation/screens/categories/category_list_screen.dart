import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/category.dart';
import '../../blocs/category/category_bloc.dart';
import '../../widgets/common/stylish_header.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/modern_dialogs.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const StylishHeader(
              title: 'Categories',
              subtitle: 'Manage your categories',
              showBackArrow: true,
              actions: [
                // Add action logic if needed, but FAB handles add
              ],
            ),
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const TabBar(
                dividerColor: Colors.transparent,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: [
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state.isLoading && state.expenseCategories.isEmpty) {
                    return const ShimmerScreen(listItemCount: 8);
                  }

                  return TabBarView(
                    children: [
                      _CategoryList(
                        categories: state.expenseCategories,
                        type: CategoryType.expense,
                      ),
                      _CategoryList(
                        categories: state.incomeCategories,
                        type: CategoryType.income,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/category/add'),
          icon: const Icon(LucideIcons.plus),
          label: const Text('Add Category'),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<Category> categories;
  final CategoryType type;

  const _CategoryList({
    required this.categories,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return EmptyState(
        icon: LucideIcons.shapes,
        title: 'No ${type.displayName} Categories',
        subtitle: 'Tap + to add a new category',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CategoryBloc>().add(LoadCategories());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryItem(
            category: category,
            onEdit: () => context.push('/category/edit', extra: category),
            onDelete: () => _confirmDelete(context, category),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) async {
    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete default categories')),
      );
      return;
    }

    final confirmed = await showModernDialog(
      context: context,
      icon: LucideIcons.trash2,
      title: 'Hapus Kategori? 🗑️',
      subtitle: 'Kategori "${category.name}" akan dihapus.',
      description: 'Transaksi dengan kategori ini tidak akan terpengaruh.',
      cancelText: 'Batal',
      confirmText: 'Hapus',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<CategoryBloc>().add(DeleteCategory(category.id));
    }
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryItem({
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.fromHex(category.color);
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CategoryIcon(
          icon: category.icon,
          color: color,
          size: 44,
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: category.isDefault
            ? Text(
                'Default',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: category.isDefault
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
      ),
    );
  }
}
