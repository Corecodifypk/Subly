import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../models/subscription.dart';
import 'brand_icon.dart';
import 'glass_surface.dart';

class SubscriptionListCard extends StatelessWidget {
  const SubscriptionListCard({
    super.key,
    required this.subscription,
    this.onTap,
    this.animate = true,
    this.animationDelay = 0,
    this.paymentDateOverride,
  });

  final Subscription subscription;
  final VoidCallback? onTap;
  final bool animate;
  final int animationDelay;
  final DateTime? paymentDateOverride;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    final payDate = paymentDateOverride ?? subscription.nextPaymentDate;

    Widget card = GestureDetector(
      onTap: onTap,
      onLongPress: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                  bottom: Radius.circular(4),
                ),
                boxShadow: AppDecorations.softCardShadow,
              ),
              child: Row(
                children: [
                  BrandIcon(name: subscription.name, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subscription.planName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${subscription.amount == subscription.amount.roundToDouble() ? subscription.amount.toStringAsFixed(0) : subscription.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.activeGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.cardFooterGrey,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Text(
                'Next Pay on ${dateFormat.format(payDate)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 400 + animationDelay),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: card,
      );
    }
    return card;
  }
}

class ActiveSubscriptionTile extends StatelessWidget {
  const ActiveSubscriptionTile({
    super.key,
    required this.subscription,
    this.animationDelay = 0,
    this.onTap,
  });

  final Subscription subscription;
  final int animationDelay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + animationDelay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onTap,
        child: SoftCard(
        borderRadius: 20,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            BrandIcon(name: subscription.name, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subscription.planName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${subscription.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.activeGreen,
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
}

class UpcomingCard extends StatelessWidget {
  const UpcomingCard({
    super.key,
    required this.subscription,
    this.width = 163,
    this.animationDelay = 0,
    this.onTap,
    this.onDelete,
    this.onRenew,
  });

  final Subscription subscription;
  final double width;
  final int animationDelay;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRenew;

  static const _radius = 20.0;
  /// Total card height — keep in sync with home carousel `SizedBox` height.
  static const cardHeight = 172.0;

  @override
  Widget build(BuildContext context) {
    final days = subscription.daysUntilPayment;
    final overdue = subscription.isOverdue;
    final daysText = overdue
        ? 'Needs renewal'
        : days == 0
            ? 'today'
            : 'in $days days';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + animationDelay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.85 + 0.15 * value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onTap,
        child: Container(
          width: width,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: SizedBox(
              height: cardHeight,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: AppColors.upcomingCardWhite,
                      padding: const EdgeInsets.fromLTRB(16, 16, 14, 10),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BrandIcon(name: subscription.name, size: 44),
                              const Spacer(),
                              Text(
                                subscription.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '\$${subscription.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1C1E),
                                  height: 1.1,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 4,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      AppColors.upcomingFooterGlow,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (overdue && onDelete != null)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: onDelete,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.trendRed,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: overdue ? onRenew : onTap,
                    behavior: HitTestBehavior.opaque,
                    child: ColoredBox(
                      color: overdue
                          ? AppColors.trendRed
                          : AppColors.upcomingFooter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          overdue ? 'Renew' : daysText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
