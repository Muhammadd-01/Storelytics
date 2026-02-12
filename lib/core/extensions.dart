import 'package:intl/intl.dart';

/// Useful Dart extensions.
extension DateTimeX on DateTime {
  String get formatted => DateFormat('MMM dd, yyyy').format(this);
  String get shortFormatted => DateFormat('dd/MM/yy').format(this);
  String get timeFormatted => DateFormat('hh:mm a').format(this);
  String get monthYear => DateFormat('MMMM yyyy').format(this);
  String get dayMonth => DateFormat('dd MMM').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool isExpiringSoon(int daysThreshold) {
    return difference(DateTime.now()).inDays <= daysThreshold &&
        isAfter(DateTime.now());
  }

  bool get isExpired => isBefore(DateTime.now());

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return formatted;
  }
}

extension DoubleX on double {
  String get toCurrency =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(this);
  String get toPercent => '${toStringAsFixed(1)}%';
  String get toCompact => NumberFormat.compact().format(this);
}

extension IntX on int {
  String get toCompact => NumberFormat.compact().format(this);
}

extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((e) => e.capitalize).join(' ');
}
