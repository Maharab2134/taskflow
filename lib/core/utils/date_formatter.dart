import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEE');

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '';
    return _shortDateFormat.format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return _timeFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatDayOfWeek(DateTime date) {
    return _dayOfWeekFormat.format(date);
  }

  static String getRelativeDueDate(DateTime? date) {
    if (date == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < -1) {
      return '${difference.abs()} days overdue';
    } else {
      return _shortDateFormat.format(date);
    }
  }

  static bool isOverdue(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isBefore(today);
  }

  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
