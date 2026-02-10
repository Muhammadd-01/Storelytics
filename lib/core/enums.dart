// App-wide enumerations.

enum UserRole {
  admin,
  storeOwner;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.storeOwner:
        return 'Store Owner';
    }
  }
}

enum StoreType {
  pharmacy,
  grocery,
  electronics,
  clothing,
  restaurant,
  generalStore,
  other;

  String get label {
    switch (this) {
      case StoreType.pharmacy:
        return 'Pharmacy';
      case StoreType.grocery:
        return 'Grocery';
      case StoreType.electronics:
        return 'Electronics';
      case StoreType.clothing:
        return 'Clothing';
      case StoreType.restaurant:
        return 'Restaurant';
      case StoreType.generalStore:
        return 'General Store';
      case StoreType.other:
        return 'Other';
    }
  }
}

enum SubscriptionPlan {
  free,
  pro,
  enterprise;

  String get label {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  int get maxItems {
    switch (this) {
      case SubscriptionPlan.free:
        return 50;
      case SubscriptionPlan.pro:
        return -1; // unlimited
      case SubscriptionPlan.enterprise:
        return -1; // unlimited
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.pro:
        return 9.99;
      case SubscriptionPlan.enterprise:
        return 19.99;
    }
  }
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock;

  String get label {
    switch (this) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }
}
