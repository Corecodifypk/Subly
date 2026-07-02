import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';
import '../widgets/app_icon.dart';
import '../widgets/glass_surface.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final reminders = provider.upcomingReminders;
    final granted = provider.notificationsEnabled;

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
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SoftCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      granted
                          ? Icons.notifications_active
                          : Icons.notifications_off_outlined,
                      color: granted
                          ? AppColors.activeGreen
                          : AppColors.trendRed,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      granted ? 'Notifications enabled' : 'Notifications off',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'SubTrack alerts you 3 days before each subscription renews '
                  'and on the due date. Enable notifications so you never miss a payment.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                if (!granted)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await provider.requestNotificationPermission();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Enable notifications'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Upcoming alerts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (reminders.isEmpty)
            const SoftCard(
              borderRadius: 16,
              padding: EdgeInsets.all(20),
              child: Text(
                'No scheduled alerts yet. Add a subscription to get reminders.',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
            )
          else
            ...reminders.map((r) => _ReminderTile(reminder: r)),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});

  final ScheduledReminder reminder;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final isOverdue = reminder.type == 'overdue';

    return SoftCard(
      borderRadius: 16,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppColors.trendRed.withValues(alpha: 0.12)
                  : AppColors.primaryPurpleLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOverdue ? Icons.warning_amber_rounded : Icons.event,
              color: isOverdue
                  ? AppColors.trendRed
                  : AppColors.primaryPurpleDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateFormat.format(reminder.scheduledAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLightGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
