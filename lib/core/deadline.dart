import 'package:flutter/material.dart';
import 'package:zakupyapk/utils/urgency.dart';

/// A handy way to manage product's deadline
class Deadline {
  final DateTime _deadline;
  final bool _ignoringTime;

  Deadline._new(this._deadline, this._ignoringTime);

  Deadline.fromDateTime(DateTime dateTime)
      : _deadline = dateTime,
        _ignoringTime = false;

  Deadline.fromDateAndTime(DateTime date, TimeOfDay time)
      : _deadline =
            DateTime(date.year, date.month, date.day, time.hour, time.minute),
        _ignoringTime = false;

  Deadline.ignoringTime(DateTime date)
      : _deadline = date,
        _ignoringTime = true;

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
  Urgency getUrgency() {
    DateTime nowExact = DateTime.now();
    DateTime today = DateTime(
        nowExact.year, nowExact.month, nowExact.day); // now but ignoring hour
    DateTime deadlineDay = DateTime(_deadline.year, _deadline.month,
        _deadline.day); // deadline but ignoring hour
    int dayDiff = deadlineDay.difference(today).inDays;
    Urgency result = Urgency.not_urgent;
    if (nowExact.isAfter(_deadline)) {
      if (today.isAtSameMomentAs(deadlineDay) && _ignoringTime) {
        result = Urgency.urgent;
      }
      else {
        result = Urgency.too_late;
      }
    }
    else if (dayDiff <= 1) {
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
    DateTime deadlineDay = DateTime(_deadline.year, _deadline.month,
        _deadline.day); // deadline but ignoring hour
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
      if (!_ignoringTime) {
        description += ' o ${_deadline.hour}:'
            '${_deadline.minute.toString().padLeft(2, '0')}';
      }
    } else if (dayDiff < 0) {
      description = '$dayDiff dni temu';
    } else if (dayDiff > 0) {
      description = 'za $dayDiff dni';
    }
    return description;
  }

  @override
  String toString() {
    return '$_deadline|$_ignoringTime';
  }
}
