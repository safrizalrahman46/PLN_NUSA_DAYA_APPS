import 'package:intl/intl.dart';

import '../constants/app_config.dart';

class DateHelper {
  DateHelper._();

  static String greeting([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  static String formatDate(DateTime value) =>
      DateFormat('dd MMM yyyy', 'id_ID').format(value);

  static String formatDateTime(DateTime value) =>
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(value);

  static String formatFull(DateTime value) =>
      DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID').format(value);

  static String formatHour(DateTime value) =>
      DateFormat('HH:mm', 'id_ID').format(value);

  static DateTime nextReportTime([DateTime? now]) {
    final base = now ?? DateTime.now();
    final nextHour = base.add(
      const Duration(hours: AppConfig.reportIntervalHour),
    );
    return DateTime(nextHour.year, nextHour.month, nextHour.day, nextHour.hour);
  }

  static String countdownText(DateTime nextTime, [DateTime? current]) {
    final now = current ?? DateTime.now();
    final diff = nextTime.difference(now);
    if (diff.isNegative) return 'Siap input';
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);
    if (hours > 0) return '${hours}j ${minutes}m';
    return '${minutes}m ${seconds}s';
  }

  static List<String> reportSlots() => List<String>.generate(
    24,
    (index) => '${index.toString().padLeft(2, '0')}:00',
  );
}
