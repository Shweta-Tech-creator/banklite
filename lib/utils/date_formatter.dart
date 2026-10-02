import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    } else {
      return DateFormat('dd MMM, hh:mm a').format(date);
    }
  }

  static String formatDateOnly(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTimeOnly(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}
