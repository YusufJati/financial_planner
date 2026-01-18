import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/spacing.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'Bill',
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
              // Add new subscription/bill
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.spaceMono(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.spaceMono(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Bills'),
                Tab(text: 'Payments'),
                Tab(text: 'Subscription'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBillsTab(),
                _buildPaymentsTab(),
                _buildSubscriptionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsTab() {
    return const Center(
      child: Text('Bills content'),
    );
  }

  Widget _buildPaymentsTab() {
    return const Center(
      child: Text('Payments content'),
    );
  }

  Widget _buildSubscriptionTab() {
    final subscriptions = [
      SubscriptionItem(
        name: 'Patreon membership',
        amount: 19.99,
        icon: _buildPatreonIcon(),
      ),
      SubscriptionItem(
        name: 'Netflix',
        amount: 12.00,
        icon: _buildNetflixIcon(),
      ),
      SubscriptionItem(
        name: 'Apple payment',
        amount: 19.99,
        icon: _buildAppleIcon(),
      ),
      SubscriptionItem(
        name: 'Spotify',
        amount: 6.99,
        icon: _buildSpotifyIcon(),
      ),
    ];

    final totalAmount =
        subscriptions.fold(0.0, (sum, item) => sum + item.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Monthly payment summary
          Text(
            'Your monthly payment',
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'for subcriptions',
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\$${totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.spaceMono(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Subscription list
          Container(
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
              children: subscriptions.asMap().entries.map((entry) {
                final index = entry.key;
                final subscription = entry.value;
                return _buildSubscriptionListItem(
                  subscription: subscription,
                  showDivider: index < subscriptions.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionListItem({
    required SubscriptionItem subscription,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(child: subscription.icon),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name and amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.name,
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '\$${subscription.amount.toStringAsFixed(2)}/mo',
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildPatreonIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFFF424D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'P',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNetflixIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Color(0xFFE50914),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAppleIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Icon(
          Icons.apple,
          size: 24,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSpotifyIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SubscriptionItem {
  final String name;
  final double amount;
  final Widget icon;

  SubscriptionItem({
    required this.name,
    required this.amount,
    required this.icon,
  });
}
