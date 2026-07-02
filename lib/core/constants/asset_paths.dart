/// Asset paths — matches files in assets/icons/ and assets/animations/.
class AssetPaths {
  AssetPaths._();

  static const icons = 'assets/icons';
  static const images = 'assets/images';
  static const animations = 'assets/animations';

  // Bottom navigation (your files)
  static const bottomNavHome = '$icons/bottom_nave_home.png';
  static const bottomNavCalendar = '$icons/bottom_nav_calander.png';
  static const bottomNavReports = '$icons/bottom_nav_mage_chart.png';
  static const bottomNavSettings = '$icons/bottom_nav_settingpng.png';
  static const bottomNavAdd = '$icons/bottom_nav_add.png';

  // Optional extras (add later if needed)
  static const edit = '$icons/edit.png';
  static const delete = '$icons/delete.png';
  static const chevronLeft = '$icons/chevron_left.png';
  static const chevronRight = '$icons/chevron_right.png';
  static const notifications = '$icons/notifications.png';
  static const person = '$icons/person.png';
  static const wallet = '$icons/wallet.png';
  static const subscriptions = '$icons/subscriptions.png';
  static const spending = '$icons/spending.png';
  static const calendarDate = '$icons/calendar_date.png';

  // Empty state Lottie
  static const notFound = '$animations/notfound.json';

  /// Branded splash logo (also used for native launch screens).
  static const splashLogo = '$images/splash_logo.png';

  /// Splash animation — optional Lottie fallback.
  static const splash = '$animations/splash.json';
}
