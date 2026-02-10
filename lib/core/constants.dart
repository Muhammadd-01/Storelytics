/// App-wide constants.
class AppConstants {
  AppConstants._();

  // ── Firestore Collections ──
  static const String usersCollection = 'users';
  static const String storesCollection = 'stores';
  static const String inventoryCollection = 'inventory';
  static const String salesCollection = 'sales';
  static const String demandCollection = 'demand_logs';

  // ── Thresholds ──
  static const int lowStockThreshold = 10;
  static const int expiryWarningDays = 30;
  static const double lowMarginThreshold = 10.0; // percent

  // ── Pagination ──
  static const int defaultPageSize = 20;

  // ── Free Plan Limits ──
  static const int freeMaxItems = 50;

  // ── App Info ──
  static const String appName = 'Storelytics';
  static const String appTagline = 'Retail Analytics & Inventory Intelligence';
  static const String appVersion = '1.0.0';
}
