import 'package:intl/intl.dart';

class Utils {
  static final NumberFormat _numberFormat = NumberFormat('#,###.#');

  static String toFormattedNumber(num number) {
    return _numberFormat.format(number);
  }
}
