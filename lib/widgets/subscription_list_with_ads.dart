import 'package:flutter/material.dart';

import '../models/subscription.dart';
import '../services/unity_ads_instances.dart';
import 'subscription_cards.dart';
import 'unity_banner_widget.dart';

/// Inserts a banner after every 3 items, after the last item if fewer than 3,
/// or alone when the list is empty.
class SubscriptionListWithAds extends StatelessWidget {
  const SubscriptionListWithAds({
    super.key,
    required this.subscriptions,
    required this.onTap,
    this.paymentDateFor,
  });

  final List<Subscription> subscriptions;
  final void Function(Subscription sub) onTap;
  final DateTime? Function(Subscription sub)? paymentDateFor;

  @override
  Widget build(BuildContext context) {
    final bannerPlacement = unityAds.bannerAdId;

    if (subscriptions.isEmpty) {
      return ListBody(
        children: [
          UnityBannerWidget(placementId: bannerPlacement),
        ],
      );
    }

    final children = <Widget>[];
    for (int i = 0; i < subscriptions.length; i++) {
      final sub = subscriptions[i];
      children.add(
        SubscriptionListCard(
          subscription: sub,
          animationDelay: i * 60,
          paymentDateOverride: paymentDateFor?.call(sub),
          onTap: () => onTap(sub),
        ),
      );
      final isThird = (i + 1) % 3 == 0;
      final isLast = i == subscriptions.length - 1;
      if (isThird || (isLast && !isThird)) {
        children.add(UnityBannerWidget(placementId: bannerPlacement));
      }
    }

    return ListBody(children: children);
  }
}
