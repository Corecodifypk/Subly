import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/add_subscription_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/ad_loading_overlay.dart';
import 'services/analytics_service.dart';
import 'services/database_service.dart';
import 'services/firebase_bootstrap.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  final firebaseReady = await FirebaseBootstrap.initialize();
  AnalyticsService.instance.setEnabled(firebaseReady);

  // Unity Ads initializes on the splash screen after iOS ATT consent.
  final db = DatabaseService();
  runApp(SublyApp(db: db));
}

class SublyApp extends StatelessWidget {
  const SublyApp({super.key, required this.db});

  final DatabaseService db;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(db)..init(),
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        title: 'SubTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorObservers: [
          if (AnalyticsService.instance.navigatorObserver != null)
            AnalyticsService.instance.navigatorObserver!,
        ],
        home: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onFinished: () => setState(() => _showSplash = false),
      );
    }
    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _screens = [
    HomeScreen(),
    CalendarScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  static const _activeLabels = ['Home', 'Calendar', 'Reports', 'Settings'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openNotificationsIfNeeded());
  }

  Future<void> _openNotificationsIfNeeded() async {
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    if (!provider.shouldAskNotificationPermission) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (!mounted) return;
    if (!provider.notificationsEnabled) {
      await provider.skipNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPurple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey(provider.currentTabIndex),
            child: _screens[provider.currentTabIndex],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: provider.currentTabIndex,
        activeLabel: _activeLabels[provider.currentTabIndex],
        onTap: (index) => provider.setTabIndex(index),
        onFabTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AddSubscriptionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        showAddSubsFab: false,
      ),
    );
  }
}
