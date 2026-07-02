import '../models/subscription.dart';
import '../utils/subscription_date_utils.dart';

class SpendingAnalytics {
  SpendingAnalytics._();

  static const categoryAbbrev = {
    'Entertainment': 'ENT',
    'Music': 'MUS',
    'Movies': 'MOV',
    'Gaming': 'GAM',
    'News': 'NWS',
    'Sports': 'SPT',
    'Food': 'FOD',
    'All': 'OTH',
  };

  static List<String> monthLabels({int count = 6}) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final m = DateTime(now.year, now.month - (count - 1 - i), 1);
      const names = [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
      ];
      return names[m.month - 1];
    });
  }

  static List<double> monthlySpendingHistory(List<Subscription> subs) {
    final now = DateTime.now();
    final active = subs.where((s) => s.isActive).toList();

    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i), 1);
      return SubscriptionDateUtils.monthPaymentTotal(active, month);
    });
  }

  static Map<String, double> categorySpending(List<Subscription> subs) {
    final active = subs.where((s) => s.isActive).toList();
    final map = <String, double>{
      'ENT': 0, 'MOV': 0, 'GAM': 0, 'MUS': 0, 'NWS': 0, 'SPT': 0, 'FOD': 0,
    };

    for (final sub in active) {
      final key = categoryAbbrev[sub.category] ??
          categoryAbbrev.entries
              .firstWhere(
                (e) => sub.category.toLowerCase().contains(e.key.toLowerCase()),
                orElse: () => const MapEntry('All', 'ENT'),
              )
              .value;
      final bucket = map.containsKey(key) ? key : 'ENT';
      map[bucket] = map[bucket]! + sub.monthlyAmount;
    }

    return map;
  }
}
