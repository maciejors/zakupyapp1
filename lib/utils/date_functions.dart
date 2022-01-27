String dateToString(DateTime dateTime) {
  String rawDateStr = dateTime.toString();
  String result = '${rawDateStr.substring(0, 10)}, '
      'godz. ${rawDateStr.substring(11, 16)}';
  return result;
}

/// Checks whether both dates represent the same day
bool sameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
