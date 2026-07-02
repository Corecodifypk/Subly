import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/subscription.dart';
import '../models/user_profile.dart';

class DatabaseService {
  static const _subscriptionsBox = 'subscriptions';
  static const _profileBox = 'profile';
  static const _settingsBox = 'settings';

  Box? _subsBox;
  Box? _profBox;
  Box? _settings;

  Future<void> init() async {
    await Hive.initFlutter();
    _subsBox = await Hive.openBox(_subscriptionsBox);
    _profBox = await Hive.openBox(_profileBox);
    _settings = await Hive.openBox(_settingsBox);

    // One-time removal of old seeded demo subscriptions
    if (_settings!.get('defaults_cleared') != true) {
      await _subsBox!.clear();
      await _settings!.put('defaults_cleared', true);
    }

    if (_profBox!.isEmpty) {
      await saveProfile(UserProfile());
    }
  }

  List<Subscription> getSubscriptions() {
    final list = _subsBox!.values
        .map((e) => Subscription.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
    return list;
  }

  Subscription? getSubscription(String id) {
    final data = _subsBox!.get(id);
    if (data == null) return null;
    return Subscription.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> addSubscription(Subscription sub) async {
    await _subsBox!.put(sub.id, sub.toMap());
  }

  Future<void> updateSubscription(Subscription sub) async {
    await _subsBox!.put(sub.id, sub.toMap());
  }

  Future<void> deleteSubscription(String id) async {
    await _subsBox!.delete(id);
  }

  UserProfile getProfile() {
    if (_profBox!.isEmpty) return UserProfile();
    return UserProfile.fromMap(
      Map<String, dynamic>.from(_profBox!.get('profile') as Map),
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _profBox!.put('profile', profile.toMap());
  }

  Future<String> saveProfileImage(File imageFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/profile_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final path = '${imagesDir.path}/profile.jpg';
    await imageFile.copy(path);
    return path;
  }

  List<double> getMonthlySpendingHistory() {
    final stored = _settings!.get('spending_history');
    if (stored != null) {
      final list = jsonDecode(stored as String) as List;
      return list.map((e) => (e as num).toDouble()).toList();
    }
    return [0, 0, 0, 0, 0, 0];
  }

  Future<void> saveMonthlySpendingHistory(List<double> data) async {
    await _settings!.put('spending_history', jsonEncode(data));
  }

  Map<String, double> getCategorySpending() {
    final stored = _settings!.get('category_spending');
    if (stored != null) {
      final map = Map<String, dynamic>.from(stored as Map);
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }
    return {
      'ENT': 0.0,
      'MOV': 0.0,
      'GAM': 0.0,
      'MUS': 0.0,
      'NWS': 0.0,
      'SPT': 0.0,
      'FOD': 0.0,
    };
  }

  bool getNotificationPermissionAsked() =>
      _settings!.get('notifications_asked') == true;

  Future<void> setNotificationPermissionAsked(bool value) async {
    await _settings!.put('notifications_asked', value);
  }

  bool getNotificationsEnabled() =>
      _settings!.get('notifications_enabled') == true;

  Future<void> setNotificationsEnabled(bool value) async {
    await _settings!.put('notifications_enabled', value);
  }
}
