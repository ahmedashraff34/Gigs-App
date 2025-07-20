import 'package:timeago/timeago.dart' as timeago;

/// Converts ISO 8601 date string to relative time string (e.g., "3 hours ago")
String timeAgoFromString(String dateStr) {
  try {
    final dateTime = DateTime.parse(dateStr);
    return timeago.format(dateTime);
  } catch (e) {
    return "Invalid date";
  }
}
