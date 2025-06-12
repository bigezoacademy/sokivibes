import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    return DateFormat('yMMMd').format(date);
  }
}
