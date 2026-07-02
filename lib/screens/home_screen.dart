import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../models/subscription.dart';
import '../providers/app_provider.dart';
import '../widgets/app_icon.dart';
import '../widgets/empty_subscriptions_state.dart';
import '../widgets/glass_surface.dart';
import '../widgets/subscription_cards.dart';
import 'add_subscription_screen.dart';
import 'all_subscriptions_screen.dart';
import 'profile_screens.dart';
import 'notifications_screen.dart';
import 'subscription_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showBudgetDialog(AppProvider provider) {
    final controller = TextEditingController(
      text: provider.profile.monthlyBudget.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '\$',
            hintText: 'Enter your budget',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) provider.updateBudget(value);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isTablet = MediaQuery.of(context).size.width > 600;
    final maxWidth = isTablet ? 700.0 : double.infinity;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildHeader(provider),
                const SizedBox(height: 24),
                _buildSpendingCard(provider),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  'Upcoming',
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllSubscriptionsScreen(
                        initialFilter: 'Upcoming',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildUpcomingCarousel(provider),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  'Active Subscriptions',
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllSubscriptionsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.activeSubscriptions.isEmpty)
                  const EmptySubscriptionsState(
                    title: 'No active subscriptions',
                    subtitle: 'Add a subscription to start tracking',
                  )
                else
                  ...provider.activeSubscriptions.take(4).toList().asMap().entries.map(
                        (e) => ActiveSubscriptionTile(
                          subscription: e.value,
                          animationDelay: e.key * 80,
                          onTap: () =>
                              openSubscriptionDetail(context, e.value),
                        ),
                      ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileNameScreen()),
            ),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.inputBackground,
                    image: provider.profile.profileImagePath != null
                        ? DecorationImage(
                            image: FileImage(
                              File(provider.profile.profileImagePath!),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: provider.profile.profileImagePath == null
                      ? const AppIcon(
                          assetPath: AssetPaths.person,
                          fallback: Icons.person,
                          size: 28,
                          color: AppColors.textGrey,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.profile.greeting,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        provider.profile.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          child: GlassSurface(
          shape: BoxShape.circle,
          blur: 20,
          opacity: 0.8,
          tint: Colors.white,
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 22,
                color: AppColors.textBlack.withValues(alpha: 0.75),
              ),
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.trendRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildSpendingCard(AppProvider provider) {
    final total = provider.totalMonthlySpending;
    final diff = provider.spendingDifference;
    final isUp = diff > 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + 0.05 * value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showBudgetDialog(provider),
        onLongPress: () => _showBudgetDialog(provider),
        child: SoftCard(
        borderRadius: 28,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total this month',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -1.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddSubscriptionScreen(),
                    ),
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurpleLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primaryPurpleDark,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
              Icon(
                isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 14,
                  color: isUp ? AppColors.trendRed : AppColors.activeGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isUp ? '+' : ''}\$${diff.abs().toStringAsFixed(0)} vs last month',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isUp ? AppColors.trendRed : AppColors.activeGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'View all',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCarousel(AppProvider provider) {
    final upcoming = provider.upcomingSubscriptions;
    if (upcoming.isEmpty) {
      return const EmptySubscriptionsState(
        title: 'No upcoming payments',
        subtitle: 'Subscriptions due within 3 days will appear here',
        height: 180,
      );
    }

    return SizedBox(
      height: UpcomingCard.cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: upcoming.length,
        itemBuilder: (context, index) {
          final sub = upcoming[index];
          return UpcomingCard(
            subscription: sub,
            animationDelay: index * 100,
            onTap: () => openSubscriptionDetail(context, sub),
            onRenew: () => openSubscriptionDetail(context, sub),
            onDelete: () => _confirmDeleteUpcoming(context, provider, sub),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteUpcoming(
    BuildContext context,
    AppProvider provider,
    Subscription sub,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove subscription'),
        content: Text('Delete ${sub.name} from your subscriptions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.trendRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await provider.deleteSubscription(sub.id);
    }
  }
}
