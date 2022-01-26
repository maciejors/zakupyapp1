String dateToString(DateTime dateTime) {
  String rawDateStr = dateTime.toString();
  String result = '${rawDateStr.substring(0, 10)}, '
      'godz. ${rawDateStr.substring(11, 16)}';
  return result;
}
