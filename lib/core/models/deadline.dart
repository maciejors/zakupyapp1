import 'package:flutter/material.dart';

/// Deadline's urgency
enum Urgency { too_late, urgent, not_urgent }

/// A handy way to manage product's deadline
class Deadline {
  final DateTime deadline;
  final bool isIgnoringTime;

  Deadline._new(this.deadline, this.isIgnoringTime);

  Deadline.fromDateTime(DateTime dateTime)
      : deadline = dateTime,
        isIgnoringTime = false;

  Deadline.fromDateAndTime(DateTime date, TimeOfDay time)
      : deadline =
            DateTime(date.year, date.month, date.day, time.hour, time.minute),
        isIgnoringTime = false;

  Deadline.ignoringTime(DateTime date)
      : deadline = date,
        isIgnoringTime = true;

  /// Parses a Deadline object from a String.
  ///
  /// Required String format:<br>
  /// `"${DateTime.toString()}|$bool"`<br>
  /// (same as Deadline.toString() format)
  static Deadline parse(String s) {
    var splitted = s.split('|');
    return Deadline._new(DateTime.parse(splitted[0]), splitted[1] == 'true');
  }

  /// Returns deadline's urgency (in relation to `DateTime.now()`).
  ///
  /// [Urgency.too_late] - deadline has passed,
  /// [Urgency.urgent] - deadline is today or tomorrow,
  /// [Urgency.not_urgent] - otherwise
  Urgency getUrgency() {
    DateTime nowExact = DateTime.now();
    DateTime today = DateTime(
        nowExact.year, nowExact.month, nowExact.day); // now but ignoring hour
    DateTime deadlineDay = DateTime(deadline.year, deadline.month,
        deadline.day); // deadline but ignoring hour
    int dayDiff = deadlineDay.difference(today).inDays;
    Urgency result = Urgency.not_urgent;
    if (nowExact.isAfter(deadline)) {
      if (today.isAtSameMomentAs(deadlineDay) && isIgnoringTime) {
        result = Urgency.urgent;
      } else {
        result = Urgency.too_late;
      }
    } else if (dayDiff <= 1) {
      result = Urgency.urgent;
    }
    return result;
  }

  /// Returns human-readable string describing the deadline.
  ///
  /// Example returns:
  /// - "za 4 dni",
  /// - "wczoraj o 20:00",
  /// - "5 dni temu",
  /// - "jutro".
  String getPolishDescription() {
    DateTime nowExact = DateTime.now();
    DateTime today = DateTime(
        nowExact.year, nowExact.month, nowExact.day); // now but ignoring hour
    DateTime deadlineDay = DateTime(deadline.year, deadline.month,
        deadline.day); // deadline but ignoring hour
    int dayDiff = deadlineDay.difference(today).inDays;
    String description = '';
    if (dayDiff.abs() <= 2) {
      switch (dayDiff) {
        case -2:
          description = 'przedwczoraj';
          break;
        case -1:
          description = 'wczoraj';
          break;
        case 0:
          description = 'dzisiaj';
          break;
        case 1:
          description = 'jutro';
          break;
        case 2:
          description = 'pojutrze';
          break;
      }
      if (!isIgnoringTime) {
        description += ' o ${deadline.hour}:'
            '${deadline.minute.toString().padLeft(2, '0')}';
      }
    } else if (dayDiff < 0) {
      description = '${-dayDiff} dni temu';
    } else if (dayDiff > 0) {
      description = 'za $dayDiff dni';
    }
    return description;
  }

  @override
  String toString() {
    return '$deadline|$isIgnoringTime';
  }
}
