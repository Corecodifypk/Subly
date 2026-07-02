import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../models/subscription.dart';
import '../providers/app_provider.dart';
import '../widgets/app_icon.dart';
import '../widgets/brand_icon.dart';
import '../widgets/glass_surface.dart';
import 'add_subscription_screen.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  const SubscriptionDetailScreen({super.key, required this.subscription});

  final Subscription subscription;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text('Remove ${subscription.name} from your subscriptions?'),
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
      await context.read<AppProvider>().deleteSubscription(subscription.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(
            assetPath: AssetPaths.chevronLeft,
            fallback: Icons.arrow_back_ios,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const AppIcon(
              assetPath: AssetPaths.delete,
              fallback: Icons.delete_outline,
              size: 22,
              color: AppColors.trendRed,
            ),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SoftCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  BrandIcon(name: subscription.name, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    subscription.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscription.planName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    label: 'Amount',
                    value:
                        '\$${subscription.amount.toStringAsFixed(2)} / ${subscription.billingCycle.toLowerCase()}',
                  ),
                  _DetailRow(
                    label: 'Next payment',
                    value: dateFormat.format(subscription.nextPaymentDate),
                    valueColor: subscription.isOverdue
                        ? AppColors.trendRed
                        : null,
                  ),
                  _DetailRow(
                    label: 'Category',
                    value: subscription.category,
                  ),
                  if (subscription.isOverdue)
                    const _DetailRow(
                      label: 'Status',
                      value: 'Needs renewal',
                      valueColor: AppColors.trendRed,
                    )
                  else
                    _DetailRow(
                      label: 'Status',
                      value: subscription.isActive ? 'Active' : 'Inactive',
                      valueColor: subscription.isActive
                          ? AppColors.activeGreen
                          : AppColors.textGrey,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (subscription.isOverdue)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddSubscriptionScreen(
                          subscription: subscription,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.trendRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Renew — set new date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (subscription.isOverdue) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddSubscriptionScreen(
                        subscription: subscription,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Edit Subscription',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => _confirmDelete(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.trendRed,
                  side: const BorderSide(color: AppColors.trendRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Delete Subscription',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

void openSubscriptionDetail(BuildContext context, Subscription subscription) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SubscriptionDetailScreen(subscription: subscription),
    ),
  );
}
