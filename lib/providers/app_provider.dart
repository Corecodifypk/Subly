import 'dart:async';
import 'dart:io';



import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';



import '../models/subscription.dart';

import '../models/user_profile.dart';

import '../services/analytics_service.dart';

import '../services/notification_service.dart';
import '../services/spending_analytics.dart';
import '../services/unity_ads_instances.dart';
import '../utils/subscription_date_utils.dart';

import '../services/database_service.dart';



class AppProvider extends ChangeNotifier {

  AppProvider(this._db);



  final DatabaseService _db;

  final ImagePicker _picker = ImagePicker();



  List<Subscription> subscriptions = [];

  UserProfile profile = UserProfile();

  int currentTabIndex = 0;

  bool isLoading = true;



  double get totalMonthlySpending => subscriptions

      .where((s) => s.isActive)

      .fold(0.0, (sum, s) => sum + s.monthlyAmount);



  double get lastMonthSpending {

    final history = spendingHistory;

    if (history.length >= 2) return history[history.length - 2];

    return totalMonthlySpending;

  }



  double get spendingDifference => totalMonthlySpending - lastMonthSpending;



  List<Subscription> get activeSubscriptions =>

      subscriptions.where((s) => s.isActive).toList();



  List<Subscription> get upcomingSubscriptions {

    final upcoming = activeSubscriptions

        .where(SubscriptionDateUtils.isUpcoming)

        .toList()

      ..sort((a, b) {

        if (a.isOverdue != b.isOverdue) {

          return a.isOverdue ? -1 : 1;

        }

        return a.daysUntilPayment.compareTo(b.daysUntilPayment);

      });

    return upcoming;

  }



  Future<void> init() async {

    isLoading = true;

    notifyListeners();

    await _db.init();

    await NotificationService.instance.initialize();

    _loadData();

    await _syncNotifications();

    isLoading = false;

    notifyListeners();

  }



  Future<void> requestNotificationPermission() async {

    final granted = await NotificationService.instance.requestPermission();

    await _db.setNotificationPermissionAsked(true);

    await _db.setNotificationsEnabled(granted);

    notifyListeners();

    if (granted) await _syncNotifications();

  }



  Future<void> skipNotificationPermission() async {
    await _db.setNotificationPermissionAsked(true);
  }

  bool get shouldAskNotificationPermission =>

      !_db.getNotificationPermissionAsked();

  bool get notificationsEnabled =>
      _db.getNotificationsEnabled() ||
      NotificationService.instance.isPermissionGranted;

  List<ScheduledReminder> get upcomingReminders =>
      NotificationService.instance.upcomingReminders(subscriptions);



  void _loadData() {

    subscriptions = _db.getSubscriptions();

    profile = _db.getProfile();

  }



  Future<void> _syncNotifications() async {

    await NotificationService.instance.rescheduleAll(subscriptions);

  }



  void setTabIndex(int index) {

    currentTabIndex = index;

    notifyListeners();

  }



  Future<void> pickAndCropProfileImage() async {
    // Android: uses system photo picker — no READ_MEDIA_IMAGES permission needed.
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop profile photo',
          toolbarColor: Color(0xFF6B4EFF),
          toolbarWidgetColor: Color(0xFFFFFFFF),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop profile photo',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null) return;

    final path = await _db.saveProfileImage(File(cropped.path));
    profile = profile.copyWith(profileImagePath: path);
    await _db.saveProfile(profile);
    notifyListeners();
  }



  Future<void> updateBudget(double budget) async {

    profile = profile.copyWith(monthlyBudget: budget);

    await _db.saveProfile(profile);

    notifyListeners();

    unawaited(actionRewarded.showRewardedAd(onRewardCallback: () {}));

  }



  Future<void> updateProfileName(String name) async {

    profile = profile.copyWith(name: name);

    await _db.saveProfile(profile);

    notifyListeners();

  }



  Future<void> updateProfile({String? name, String? greeting}) async {

    profile = profile.copyWith(

      name: name ?? profile.name,

      greeting: greeting ?? profile.greeting,

    );

    await _db.saveProfile(profile);

    notifyListeners();

  }



  Future<void> addSubscription(Subscription sub) async {

    await _db.addSubscription(sub);

    _loadData();

    await _syncNotifications();

    await AnalyticsService.instance.logSubscriptionAdded(sub.name);

    notifyListeners();

    unawaited(actionRewarded.showRewardedAd(onRewardCallback: () {}));

  }



  Future<void> updateSubscription(Subscription sub) async {

    await _db.updateSubscription(sub);

    _loadData();

    await _syncNotifications();

    notifyListeners();

    unawaited(actionRewarded.showRewardedAd(onRewardCallback: () {}));

  }



  Future<void> renewSubscription(String id, {DateTime? customDate}) async {

    final sub = subscriptions.firstWhere((s) => s.id == id);

    final newDate =

        customDate ?? SubscriptionDateUtils.advanceRenewalDate(sub);

    await updateSubscription(sub.copyWith(nextPaymentDate: newDate));

    await AnalyticsService.instance.logSubscriptionRenewed(sub.name);

    unawaited(actionRewarded.showRewardedAd(onRewardCallback: () {}));

  }



  Future<void> deleteSubscription(String id) async {
    Subscription? sub;
    for (final s in subscriptions) {
      if (s.id == id) {
        sub = s;
        break;
      }
    }
    await _db.deleteSubscription(id);
    _loadData();
    await _syncNotifications();
    if (sub != null) {
      await AnalyticsService.instance.logSubscriptionDeleted(sub.name);
    }
    notifyListeners();
    unawaited(actionRewarded.showRewardedAd(onRewardCallback: () {}));
  }

  List<Subscription> getByDate(DateTime date) {
    return activeSubscriptions
        .where((s) => SubscriptionDateUtils.hasPaymentOnDate(s, date))
        .toList();
  }



  List<Subscription> getByCategory(String category) {

    if (category == 'All') return activeSubscriptions;

    if (category == 'Upcoming') return upcomingSubscriptions;

    return activeSubscriptions

        .where((s) => s.category.toLowerCase() == category.toLowerCase())

        .toList();

  }



  List<double> get spendingHistory =>

      SpendingAnalytics.monthlySpendingHistory(subscriptions);



  List<String> get spendingMonthLabels =>

      SpendingAnalytics.monthLabels();



  Map<String, double> get categorySpending =>

      SpendingAnalytics.categorySpending(subscriptions);



  Set<int> getPaymentDaysForMonth(DateTime month) {

    return SubscriptionDateUtils.paymentDaysInMonth(

      activeSubscriptions,

      month,

    );

  }



  Set<int> getOverdueDaysForMonth(DateTime month) {

    return SubscriptionDateUtils.overdueDaysInMonth(

      activeSubscriptions,

      month,

    );

  }

  double getMonthPaymentTotal(DateTime month) {
    return SubscriptionDateUtils.monthPaymentTotal(activeSubscriptions, month);
  }

  DateTime? paymentDateFor(Subscription sub, DateTime date) {
    return SubscriptionDateUtils.paymentOccurrenceOnDate(sub, date);
  }

  bool get isRewardedAdReady => actionRewarded.isReady;

  Future<bool> watchRewardedAd() async {
    var rewarded = false;
    await actionRewarded.showRewardedAd(
      onRewardCallback: () => rewarded = true,
    );
    return rewarded;
  }

}


