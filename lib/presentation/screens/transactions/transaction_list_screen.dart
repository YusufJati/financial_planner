import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/transaction.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../widgets/common/stylish_header.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/modern_dialogs.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final start = app_date.DateUtils.startOfMonth(_selectedMonth);
    final end = app_date.DateUtils.endOfMonth(_selectedMonth);

    context.read<TransactionBloc>().add(LoadTransactions(
          startDate: start,
          endDate: end,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StylishHeader(
            title: 'Transactions',
            subtitle: 'Track your history',
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilterSheet,
              ),
            ],
          ),
          // Month Selector
          _buildMonthSelector(),

          // Transaction List
          Expanded(
            child: BlocConsumer<TransactionBloc, TransactionState>(
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
                if (state.isLoading) {
                  return const AppLoading();
                }

                if (state.transactions.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long,
                    title: 'No transactions',
                    subtitle: 'Start adding your transactions',
                    actionText: 'Add Transaction',
                    onAction: () => context.push('/transaction/add'),
                  );
                }

                return _buildTransactionList(state);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/transaction/add');
          if (result == true && mounted) {
            _loadTransactions();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
              _loadTransactions();
            },
          ),
          GestureDetector(
            onTap: _showMonthPicker,
            child: Row(
              children: [
                Text(
                  app_date.DateUtils.formatMonthYear(_selectedMonth),
                  style: AppTextStyles.h4,
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final now = DateTime.now();
              if (_selectedMonth.year < now.year ||
                  (_selectedMonth.year == now.year &&
                      _selectedMonth.month < now.month)) {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
                _loadTransactions();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(TransactionState state) {
    final groupedTransactions = state.groupedTransactions;
    final keys = groupedTransactions.keys.toList();

    return RefreshIndicator(
      onRefresh: () async {
        _loadTransactions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final dateKey = keys[index];
          final transactions = groupedTransactions[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateKey,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _calculateDayTotal(transactions),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Transactions
              ...transactions.map((t) => _buildTransactionItem(t)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;

    final color = transaction.category != null
        ? AppColors.fromHex(transaction.category!.color)
        : AppColors.textSecondary;

    return Slidable(
      key: ValueKey(transaction.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editTransaction(transaction),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _deleteTransaction(transaction),
            backgroundColor: AppColors.expense,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        child: InkWell(
          onTap: () => _showTransactionDetail(transaction),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CategoryIcon(
                  icon: transaction.category?.icon ?? 'more-horizontal',
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTransfer
                            ? 'Transfer'
                            : transaction.category?.name ?? 'Unknown',
                        style: AppTextStyles.bodyLarge,
                      ),
                      if (transaction.note != null &&
                          transaction.note!.isNotEmpty)
                        Text(
                          transaction.note!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          transaction.account?.name ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? "-" : isTransfer ? "" : "+"}${CurrencyFormatter.format(transaction.amount)}',
                      style: AppTextStyles.amountSmall.copyWith(
                        color: isExpense
                            ? AppColors.expense
                            : isTransfer
                                ? AppColors.transfer
                                : AppColors.income,
                      ),
                    ),
                    Text(
                      app_date.DateUtils.formatTime(transaction.date),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
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

  String _calculateDayTotal(List<Transaction> transactions) {
    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else if (t.type == TransactionType.expense) {
        expense += t.amount;
      }
    }

    final net = income - expense;
    if (net >= 0) {
      return '+${CurrencyFormatter.formatCompact(net)}';
    }
    return CurrencyFormatter.formatCompact(net);
  }

  void _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
      _loadTransactions();
    }
  }

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    showAppBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        side: BorderSide(color: borderColor),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter', style: AppTextStyles.h4),
              const SizedBox(height: 16),
              ListTile(
                leading:
                    const Icon(LucideIcons.list, color: AppColors.textSecondary),
                title: const Text('All Transactions'),
                onTap: () {
                  Navigator.pop(context);
                  _loadTransactions();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.arrowUp,
                    color: AppColors.textSecondary),
                title: const Text('Expenses Only'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement expense filter
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.arrowDown,
                    color: AppColors.textSecondary),
                title: const Text('Income Only'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement income filter
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showTransactionDetail(Transaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    showAppBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        side: BorderSide(color: borderColor),
      ),
      builder: (context) {
        final isExpense = transaction.type == TransactionType.expense;
        final isTransfer = transaction.type == TransactionType.transfer;
        final amountColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        final color = transaction.category != null
            ? AppColors.fromHex(transaction.category!.color)
            : AppColors.textSecondary;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CategoryIcon(
                icon: transaction.category?.icon ?? 'more-horizontal',
                color: color,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                '${isExpense ? "-" : isTransfer ? "" : "+"}${CurrencyFormatter.format(transaction.amount)}',
                style: AppTextStyles.amountLarge.copyWith(color: amountColor),
              ),
              const SizedBox(height: 8),
              Text(
                transaction.category?.name ?? 'Transfer',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Account', transaction.account?.name ?? '-'),
              if (isTransfer && transaction.toAccount != null)
                _buildDetailRow('To', transaction.toAccount!.name),
              _buildDetailRow(
                  'Date', app_date.DateUtils.formatFull(transaction.date)),
              if (transaction.note != null && transaction.note!.isNotEmpty)
                _buildDetailRow('Note', transaction.note!),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editTransaction(transaction);
                      },
                      icon: const Icon(LucideIcons.pencil),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTransaction(transaction);
                      },
                      icon: const Icon(LucideIcons.trash2),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  void _editTransaction(Transaction transaction) {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit coming soon')),
    );
  }

  void _deleteTransaction(Transaction transaction) async {
    final confirmed = await showModernDialog(
      context: context,
      icon: LucideIcons.trash2,
      title: 'Delete Transaction',
      subtitle: 'Are you sure you want to delete this transaction?',
      description: 'This action cannot be undone.',
      cancelText: 'Cancel',
      confirmText: 'Delete',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      context.read<TransactionBloc>().add(
            DeleteTransaction(transaction.id),
          );
      // Auto-refresh after deletion
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _loadTransactions();
      }
    }
  }
}
