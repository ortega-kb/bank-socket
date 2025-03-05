import 'package:intl/intl.dart';

String formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return DateFormat('dd/MM/yyyy').format(date);
}
