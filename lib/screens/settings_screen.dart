import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/app_icon.dart';
import '../widgets/glass_surface.dart';
import 'all_subscriptions_screen.dart';
import 'notifications_screen.dart';
import 'profile_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isTablet = MediaQuery.of(context).size.width > 600;
    final budget = provider.profile.monthlyBudget;
    final spending = provider.totalMonthlySpending;
    final remaining = budget - spending;
    final progress = budget > 0 ? (spending / budget).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),

          // Profile card
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileNameScreen()),
            ),
            child: SoftCard(
              borderRadius: 20,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurpleLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: AppIcon(
                        assetPath: AssetPaths.person,
                        fallback: Icons.person_outline,
                        size: 24,
                        color: AppColors.primaryPurpleDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.profile.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          provider.profile.greeting,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppIcon(
                    assetPath: AssetPaths.chevronRight,
                    fallback: Icons.chevron_right,
                    size: 22,
                    color: AppColors.textGrey,
                  ),
                ],
              ),
            ),
          ),

          // Monthly budget card
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetScreen()),
            ),
            child: SoftCard(
              borderRadius: 20,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppIcon(
                        assetPath: AssetPaths.wallet,
                        fallback: Icons.account_balance_wallet_outlined,
                        size: 22,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Monthly Budget',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      const AppIcon(
                        assetPath: AssetPaths.chevronRight,
                        fallback: Icons.chevron_right,
                        size: 20,
                        color: AppColors.textGrey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${budget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.inputBackground,
                      color: progress > 0.9
                          ? AppColors.trendRed
                          : AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${remaining.toStringAsFixed(0)} remaining this month',
                    style: TextStyle(
                      fontSize: 12,
                      color: remaining >= 0
                          ? AppColors.activeGreen
                          : AppColors.trendRed,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllSubscriptionsScreen(),
                    ),
                  ),
                  child: SoftCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppIcon(
                          assetPath: AssetPaths.subscriptions,
                          fallback: Icons.subscriptions_outlined,
                          size: 22,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${provider.activeSubscriptions.length}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Text(
                          'Total Subscriptions',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SoftCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppIcon(
                        assetPath: AssetPaths.spending,
                        fallback: Icons.payments_outlined,
                        size: 22,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${spending.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Text(
                        'Monthly Spending',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: SoftCard(
              borderRadius: 20,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    provider.notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          provider.notificationsEnabled
                              ? 'Alerts 3 days before renewals'
                              : 'Tap to enable renewal alerts',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppIcon(
                    assetPath: AssetPaths.chevronRight,
                    fallback: Icons.chevron_right,
                    size: 20,
                    color: AppColors.textGrey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
