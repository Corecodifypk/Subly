import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/subscription.dart';
import '../utils/subscription_date_utils.dart';

class ScheduledReminder {
  const ScheduledReminder({
    required this.subscriptionId,
    required this.subscriptionName,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.type,
  });

  final String subscriptionId;
  final String subscriptionName;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String type;
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionGranted = false;

  bool get isPermissionGranted => _permissionGranted;

  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final notification = await Permission.notification.request();
      if (defaultTargetPlatform == TargetPlatform.android) {
        await Permission.scheduleExactAlarm.request();
      }
      _permissionGranted = notification.isGranted;
      return _permissionGranted;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      _permissionGranted = await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return _permissionGranted;
    }
    _permissionGranted = true;
    return true;
  }

  Future<void> checkPermissionStatus() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _permissionGranted = await Permission.notification.isGranted;
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) {},
    );
    await checkPermissionStatus();
    _initialized = true;
  }

  List<ScheduledReminder> upcomingReminders(List<Subscription> subscriptions) {
    final reminders = <ScheduledReminder>[];
    final now = DateTime.now();

    for (final sub in subscriptions.where((s) => s.isActive)) {
      final due = SubscriptionDateUtils.dateOnly(sub.nextPaymentDate);
      final threeDaysBefore =
          due.subtract(const Duration(days: SubscriptionDateUtils.upcomingDaysThreshold));

      if (threeDaysBefore.isAfter(now)) {
        reminders.add(ScheduledReminder(
          subscriptionId: sub.id,
          subscriptionName: sub.name,
          title: 'Renewal in 3 days',
          body: '${sub.name} renews on ${_formatDate(due)}',
          scheduledAt: threeDaysBefore,
          type: 'reminder',
        ));
      }

      if (!due.isBefore(now)) {
        reminders.add(ScheduledReminder(
          subscriptionId: sub.id,
          subscriptionName: sub.name,
          title: 'Payment due today',
          body: '${sub.name} — \$${sub.amount.toStringAsFixed(2)}',
          scheduledAt: due,
          type: 'due',
        ));
      } else {
        reminders.add(ScheduledReminder(
          subscriptionId: sub.id,
          subscriptionName: sub.name,
          title: 'Needs renewal',
          body: '${sub.name} is overdue since ${_formatDate(due)}',
          scheduledAt: due,
          type: 'overdue',
        ));
      }
    }

    reminders.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return reminders;
  }

  Future<void> rescheduleAll(List<Subscription> subscriptions) async {
    if (!_initialized) return;
    await _plugin.cancelAll();
    if (!_permissionGranted) return;

    for (final sub in subscriptions.where((s) => s.isActive)) {
      await _scheduleForSubscription(sub);
    }
  }

  Future<void> _scheduleForSubscription(Subscription sub) async {
    final due = SubscriptionDateUtils.dateOnly(sub.nextPaymentDate);
    final threeDaysBefore = due.subtract(
      const Duration(days: SubscriptionDateUtils.upcomingDaysThreshold),
    );
    final now = DateTime.now();

    if (threeDaysBefore.isAfter(now)) {
      await _schedule(
        id: '${sub.id}_3day'.hashCode,
        title: 'Renewal in 3 days',
        body:
            '${sub.name} renews in 3 days (${_formatDate(due)})',
        when: threeDaysBefore,
      );
    }

    if (due.isAfter(now) || due == SubscriptionDateUtils.dateOnly(now)) {
      await _schedule(
        id: '${sub.id}_due'.hashCode,
        title: 'Subscription due today',
        body: '${sub.name} — \$${sub.amount.toStringAsFixed(2)} is due',
        when: due,
      );
    } else {
      await _schedule(
        id: '${sub.id}_overdue'.hashCode,
        title: 'Subscription needs renewal',
        body: '${sub.name} is overdue. Tap to renew.',
        when: now.add(const Duration(seconds: 10)),
      );
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subly_renewals',
          'Subscription Renewals',
          channelDescription:
              'Reminders 3 days before subscription renewals and on due dates',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
