import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/spacing.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String selectedMonth = 'September 2020';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Expenses',
          style: GoogleFonts.spaceMono(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () {
              // Add new expense
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            // Month selector
            _buildMonthSelector(),
            const SizedBox(height: AppSpacing.md),
            // Total expenses
            Text(
              '\$1,812',
              style: GoogleFonts.spaceMono(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Budget overview card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildBudgetOverviewCard(),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Category cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildCategoryCard(
                icon: Icons.directions_car,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primarySoft,
                title: 'Auto & transport',
                totalBudget: 700,
                expenses: [
                  ExpenseItem(
                    name: 'Auto & transport',
                    budget: 350,
                    spent: 164,
                    color: AppColors.primary,
                  ),
                  ExpenseItem(
                    name: 'Auto insurance',
                    budget: 250,
                    spent: 130,
                    color: const Color(0xFF06B6D4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildCategoryCard(
                icon: Icons.receipt_long,
                iconColor: AppColors.expense,
                iconBgColor: const Color(0xFFFEE2E2),
                title: 'Bill & Ultilities',
                totalBudget: 320,
                expenses: [
                  ExpenseItem(
                    name: 'Subscriptions',
                    budget: 52,
                    spent: 52,
                    color: AppColors.expense,
                  ),
                  ExpenseItem(
                    name: 'House service',
                    budget: 138,
                    spent: 128,
                    color: AppColors.expense,
                  ),
                  ExpenseItem(
                    name: 'Maintenance',
                    budget: 130,
                    spent: 100,
                    color: AppColors.expense,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(true),
                const SizedBox(width: AppSpacing.xs),
                _buildDot(false),
                const SizedBox(width: AppSpacing.xs),
                _buildDot(false),
              ],
            ),
            const SizedBox(height: AppSpacing.s100),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return GestureDetector(
      onTap: () {
        // Show month picker
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            selectedMonth,
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverviewCard() {
    const leftToSpend = 738.0;
    const monthlyBudget = 2550.0;
    const spent = monthlyBudget - leftToSpend;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Left to spend',
                    style: GoogleFonts.spaceMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '\$${leftToSpend.toStringAsFixed(0)}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Monthly budget',
                    style: GoogleFonts.spaceMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '\$${monthlyBudget.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Multi-color progress bar
          _buildMultiColorProgressBar(spent / monthlyBudget),
        ],
      ),
    );
  }

  Widget _buildMultiColorProgressBar(double progress) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Red segment
          Expanded(
            flex: 25,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.expense,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
          ),
          // Blue segment
          Expanded(
            flex: 20,
            child: Container(
              color: const Color(0xFF3B82F6),
            ),
          ),
          // Purple segment
          Expanded(
            flex: 26,
            child: Container(
              color: AppColors.primary,
            ),
          ),
          // Remaining (gray)
          Expanded(
            flex: 29,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required double totalBudget,
    required List<ExpenseItem> expenses,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '\$${totalBudget.toStringAsFixed(0)}',
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Expense items
          ...expenses.map((expense) => _buildExpenseItem(expense)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseItem expense) {
    final progress = expense.spent / expense.budget;
    final left = expense.budget - expense.spent;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                expense.name,
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${expense.budget.toStringAsFixed(0)}',
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: expense.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Left \$${left.toStringAsFixed(0)}',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.textSecondary : AppColors.border,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ExpenseItem {
  final String name;
  final double budget;
  final double spent;
  final Color color;

  ExpenseItem({
    required this.name,
    required this.budget,
    required this.spent,
    required this.color,
  });
}
