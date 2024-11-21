import 'package:intl/intl.dart';

class CurrencyFormater {
  CurrencyFormater._();

  static String toIdr(
    double number, {
    required String locale,
    required String symbol,
  }) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    ).format(number);
  }
}
