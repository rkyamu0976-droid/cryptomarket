import 'package:intl/intl.dart';

class Fmt {
  static String price(double v) {
    if (v == 0) return '\$0.00';
    if (v >= 1) return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(v);
    if (v >= 0.01) return '\$${v.toStringAsFixed(4)}';
    return '\$${v.toStringAsFixed(8)}';
  }

  static String axisPrice(double v) {
    if (v >= 10000) return NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1).format(v);
    if (v >= 1) return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(v);
    return '\$${v.toStringAsFixed(4)}';
  }

  static String compactUsd(double v) =>
      NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 2).format(v);

  static String compact(double v) => NumberFormat.compact().format(v);

  static String percent(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

  static String time(DateTime d) => DateFormat('HH:mm').format(d);

  static String chartDate(DateTime d, {bool withTime = true}) =>
      withTime ? DateFormat('d MMM, HH:mm').format(d) : DateFormat('d MMM yyyy').format(d);
}
