import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'en_OM',
  symbol: 'OMR ',
  decimalDigits: 3,
);

final _dateTime = DateFormat('dd/MM/yyyy hh:mm a');
final _date = DateFormat('dd MMM yyyy');
final _time = DateFormat('hh:mm a');

String formatCurrency(double amount) => _currency.format(amount);
String formatDateTime(DateTime dt) => _dateTime.format(dt);
String formatDate(DateTime dt) => _date.format(dt);
String formatTime(DateTime dt) => _time.format(dt);
String formatOrderId(String id) => '#$id';
