import 'package:intl/intl.dart';

/// Formats an amount for display: thousands grouping, whole đồng (no .00), no currency symbol.
String formatMoney(num value) {
  return NumberFormat('#,##0', 'en_US').format(value.round());
}
