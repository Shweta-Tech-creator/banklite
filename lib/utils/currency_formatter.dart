import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactInrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double amount, {bool showDecimals = true}) {
    if (!showDecimals && amount % 1 == 0) {
      return _compactInrFormatter.format(amount);
    }
    return _inrFormatter.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    final format = NumberFormat('#,##,##0.00', 'en_IN');
    return format.format(amount);
  }
}
