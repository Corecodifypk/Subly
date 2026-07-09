import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/app_icon.dart';
import '../widgets/empty_subscriptions_state.dart';
import '../widgets/glass_surface.dart';
import '../widgets/subscription_list_with_ads.dart';
import '../services/unity_ads_instances.dart';
import '../widgets/unity_banner_widget.dart';
import 'subscription_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + delta,
      );
      final lastDay = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
        0,
      ).day;
      final day = _selectedDate.day.clamp(1, lastDay);
      _selectedDate = DateTime(
        _focusedMonth.year,
        _focusedMonth.month,
        day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isTablet = MediaQuery.of(context).size.width > 600;
    final maxWidth = isTablet ? 700.0 : double.infinity;
    final paymentDays = provider.getPaymentDaysForMonth(_focusedMonth);
    final overdueDays = provider.getOverdueDaysForMonth(_focusedMonth);
    final daySubscriptions = provider.getByDate(_selectedDate);
    final dayTotal = daySubscriptions.fold(0.0, (sum, s) => sum + s.amount);
    final monthTotal = provider.getMonthPaymentTotal(_focusedMonth);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 20,
        0,
        isTablet ? 32 : 20,
        130,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Subscription Cycle',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      _MonthArrow(
                        onTap: () => _changeMonth(-1),
                        assetPath: AssetPaths.chevronLeft,
                      ),
                      const SizedBox(width: 8),
                      _MonthArrow(
                        onTap: () => _changeMonth(1),
                        assetPath: AssetPaths.chevronRight,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CalendarGrid(
                focusedMonth: _focusedMonth,
                selectedDate: _selectedDate,
                paymentDays: paymentDays,
                overdueDays: overdueDays,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 16),
              UnityBannerWidget(placementId: unityAds.bannerAdId),
              const SizedBox(height: 16),
              SoftCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormat('MMMM yyyy').format(_focusedMonth)} total',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '\$${monthTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '\$${dayTotal == dayTotal.roundToDouble() ? dayTotal.toStringAsFixed(0) : dayTotal.toStringAsFixed(2)} day total',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (daySubscriptions.isEmpty)
                const EmptySubscriptionsState(
                  title: 'No payments on this date',
                  subtitle: 'Select another date or add a subscription',
                  height: 160,
                )
              else
                SubscriptionListWithAds(
                  subscriptions: daySubscriptions,
                  paymentDateFor: (sub) =>
                      provider.paymentDateFor(sub, _selectedDate),
                  onTap: (sub) => openSubscriptionDetail(context, sub),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.paymentDays,
    required this.overdueDays,
    required this.onDateSelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Set<int> paymentDays;
  final Set<int> overdueDays;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday; // Mon=1
    final prevMonthDays =
        DateTime(focusedMonth.year, focusedMonth.month, 0).day;

    final cells = <_CalendarCellData>[];

    for (int i = startWeekday - 1; i > 0; i--) {
      cells.add(_CalendarCellData(
        day: prevMonthDays - i + 1,
        isCurrentMonth: false,
      ));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(_CalendarCellData(day: d, isCurrentMonth: true));
    }
    var nextMonthDay = 1;
    while (cells.length % 7 != 0) {
      cells.add(_CalendarCellData(
        day: nextMonthDay++,
        isCurrentMonth: false,
      ));
    }

    return SoftCard(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      child: Column(
        children: [
          const Row(
            children: [
              _DayLabel('MO'),
              _DayLabel('TU'),
              _DayLabel('WE'),
              _DayLabel('TH'),
              _DayLabel('FR'),
              _DayLabel('SA'),
              _DayLabel('SU'),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(cells.length ~/ 7, (weekIndex) {
            final week = cells.sublist(weekIndex * 7, weekIndex * 7 + 7);
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: week.map((cell) {
                  final isSelected = cell.isCurrentMonth &&
                      cell.day == selectedDate.day &&
                      focusedMonth.month == selectedDate.month &&
                      focusedMonth.year == selectedDate.year;
                  final hasPayment =
                      cell.isCurrentMonth && paymentDays.contains(cell.day);
                  final isOverdue =
                      cell.isCurrentMonth && overdueDays.contains(cell.day);

                  return Expanded(
                    child: _CalendarDayCell(
                      day: cell.day,
                      isCurrentMonth: cell.isCurrentMonth,
                      isSelected: isSelected,
                      hasPayment: hasPayment,
                      isOverdue: isOverdue,
                      onTap: cell.isCurrentMonth
                          ? () => onDateSelected(DateTime(
                                focusedMonth.year,
                                focusedMonth.month,
                                cell.day,
                              ))
                          : null,
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CalendarCellData {
  const _CalendarCellData({required this.day, required this.isCurrentMonth});
  final int day;
  final bool isCurrentMonth;
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.hasPayment,
    required this.isOverdue,
    this.onTap,
  });

  final int day;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool hasPayment;
  final bool isOverdue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.calendarSelected
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: !isCurrentMonth
                      ? AppColors.textLightGrey.withValues(alpha: 0.6)
                      : isSelected
                          ? AppColors.primaryPurpleDark
                          : AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 6,
              child: Center(child: _buildDots()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    if (isSelected && hasPayment) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(AppColors.primaryPurpleDark),
          const SizedBox(width: 4),
          _dot(AppColors.primaryPurpleDark),
        ],
      );
    }
    if (hasPayment) {
      return _dot(isOverdue ? AppColors.trendRed : AppColors.calendarDot);
    }
    if (isSelected) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(AppColors.primaryPurpleDark),
          const SizedBox(width: 4),
          _dot(AppColors.primaryPurpleDark),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _dot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.onTap, required this.assetPath});

  final VoidCallback onTap;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        shape: BoxShape.circle,
        blur: 16,
        opacity: 0.75,
        tint: AppColors.inputBackground,
        width: 36,
        height: 36,
        shadows: const [],
        child: Center(
          child: AppIcon(
            assetPath: assetPath,
            fallback: assetPath.contains('left')
                ? Icons.chevron_left
                : Icons.chevron_right,
            size: 20,
            color: AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}
