import 'package:intl/intl.dart';

class NumberHelper {
  NumberHelper._();

  static double parse(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.')) ?? 0;

  static double parseDynamic(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return parse(value);
    }
    return 0;
  }

  static String decimal(num value, {int digits = 2}) =>
      NumberFormat.decimalPatternDigits(
        locale: 'id_ID',
        decimalDigits: digits,
      ).format(value);

  static String compact(num value) =>
      NumberFormat.compact(locale: 'id_ID').format(value);
}
