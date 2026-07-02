import '../models/subscription.dart';

class SubscriptionDateUtils {
  SubscriptionDateUtils._();

  static const upcomingDaysThreshold = 3;

  static DateTime dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static int daysUntil(DateTime paymentDate) {
    return dateOnly(paymentDate).difference(dateOnly(DateTime.now())).inDays;
  }

  static bool isOverdue(DateTime paymentDate) => daysUntil(paymentDate) < 0;

  static bool isUpcoming(Subscription sub) {
    if (!sub.isActive) return false;
    return daysUntil(sub.nextPaymentDate) <= upcomingDaysThreshold;
  }

  static DateTime billingAnchor(Subscription sub) =>
      dateOnly(sub.nextPaymentDate);

  static DateTime? paymentOccurrenceOnDate(Subscription sub, DateTime date) {
    if (!hasPaymentOnDate(sub, date)) return null;
    return dateOnly(date);
  }

  /// True only when [date] is a billing occurrence on/after the subscription's
  /// first payment date and on/after it was created.
  static bool hasPaymentOnDate(Subscription sub, DateTime date) {
    if (!sub.isActive) return false;

    final target = dateOnly(date);
    final anchor = billingAnchor(sub);
    final created = dateOnly(sub.createdAt);
    final billingDay = anchor.day;

    var cursor = anchor;
    for (int i = 0; i < 60 && cursor.isAfter(target); i++) {
      cursor = subtractBillingCycle(cursor, sub.billingCycle, billingDay);
    }
    for (int i = 0; i < 60 && cursor.isBefore(target); i++) {
      cursor = addBillingCycle(cursor, sub.billingCycle, billingDay);
    }

    if (cursor != target) return false;
    if (target.isBefore(anchor)) return false;
    if (target.isBefore(created)) return false;

    return true;
  }

  static double monthPaymentTotal(
    List<Subscription> subs,
    DateTime month,
  ) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    double total = 0;
    for (int d = 1; d <= lastDay; d++) {
      final date = DateTime(month.year, month.month, d);
      for (final sub in subs) {
        if (hasPaymentOnDate(sub, date)) {
          total += sub.amount;
        }
      }
    }
    return total;
  }

  static DateTime advanceRenewalDate(Subscription sub) {
    var date = dateOnly(sub.nextPaymentDate);
    final billingDay = date.day;

    while (!date.isAfter(dateOnly(DateTime.now()))) {
      date = addBillingCycle(date, sub.billingCycle, billingDay);
    }
    return date;
  }

  static DateTime addBillingCycle(
    DateTime from,
    String billingCycle,
    int billingDay,
  ) {
    if (billingCycle == 'Yearly') {
      return safeDate(from.year + 1, from.month, billingDay);
    }
    final nextMonth = DateTime(from.year, from.month + 1, 1);
    return safeDate(nextMonth.year, nextMonth.month, billingDay);
  }

  static DateTime subtractBillingCycle(
    DateTime from,
    String billingCycle,
    int billingDay,
  ) {
    if (billingCycle == 'Yearly') {
      return safeDate(from.year - 1, from.month, billingDay);
    }
    final prevMonth = DateTime(from.year, from.month - 1, 1);
    return safeDate(prevMonth.year, prevMonth.month, billingDay);
  }

  static DateTime safeDate(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, lastDay));
  }

  static Set<int> paymentDaysInMonth(
    List<Subscription> subs,
    DateTime month,
  ) {
    final days = <int>{};
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    for (int d = 1; d <= lastDay; d++) {
      final date = DateTime(month.year, month.month, d);
      for (final sub in subs) {
        if (hasPaymentOnDate(sub, date)) {
          days.add(d);
          break;
        }
      }
    }
    return days;
  }

  static Set<int> overdueDaysInMonth(
    List<Subscription> subs,
    DateTime month,
  ) {
    final now = dateOnly(DateTime.now());
    final days = <int>{};
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    for (int d = 1; d <= lastDay; d++) {
      final date = DateTime(month.year, month.month, d);
      if (!date.isBefore(now)) continue;
      for (final sub in subs) {
        if (hasPaymentOnDate(sub, date) &&
            dateOnly(sub.nextPaymentDate) == date) {
          days.add(d);
          break;
        }
      }
    }
    return days;
  }
}
