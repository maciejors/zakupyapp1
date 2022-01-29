import 'package:flutter/material.dart';

/// DD/MM/YYYY, godz. HH:mm
String dateTimeToPolishString(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/'
      '${dateTime.month.toString().padLeft(2, '0')}/'
      '${dateTime.year}, godz. ${dateTime.hour}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}

/// DD/MM/YYYY
String dateToString(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

/// HH:mm
String timeToString(TimeOfDay timeOfDay) {
  return '${timeOfDay.hour}:${timeOfDay.minute.toString().padLeft(2, '0')}';
}

/// Checks whether both dates represent the same day
bool sameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
