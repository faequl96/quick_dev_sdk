import 'package:intl/intl.dart';

class Currency {
  Currency._();

  static String format(double number, {required String locale, required String symbol}) {
    return NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0).format(number);
  }
}
