/// Deadline's urgency
enum Urgency { tooLate, urgent, notUrgent }

/// A handy way to manage product's deadline
class Deadline {
  /// deadline but ignoring hour
  DateTime deadlineDay = DateTime.now();

  Deadline(DateTime dateTime) {
    deadlineDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Parses a Deadline object from a String.
  ///
  /// Required String format is the same as the one obtained from
  /// `DateTime.toString()` and `Deadline.toString()`<br>
  ///
  /// Old format will also work:<br>
  /// `"${DateTime.toString()}|$bool"`<br>
  @Deprecated('Since migration to Firestore, this is no longer used and '
      'is left just in case')
  static Deadline parse(String s) {
    // split to support old deadline format
    var splitted = s.split('|');
    return Deadline(DateTime.parse(splitted[0]));
  }

  /// Returns deadline's urgency (in relation to `DateTime.now()`).
  ///
  /// [Urgency.tooLate] - deadline has passed,
  /// [Urgency.urgent] - deadline is today or tomorrow,
  /// [Urgency.notUrgent] - otherwise
  Urgency getUrgency() {
    DateTime nowExact = DateTime.now();
    DateTime today = DateTime(
        nowExact.year, nowExact.month, nowExact.day); // now but ignoring hour
    int dayDiff = deadlineDay.difference(today).inDays;
    Urgency result = Urgency.notUrgent;
    if (nowExact.isAfter(deadlineDay.add(const Duration(days: 1)))) {
      result = Urgency.tooLate;
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
    } else if (dayDiff < 0) {
      description = '${-dayDiff} dni temu';
    } else if (dayDiff > 0) {
      description = 'za $dayDiff dni';
    }
    return description;
  }

  @override
  @Deprecated('Since migration to Firestore, this is no longer used and '
      'is left just in case')
  /// Since migration to Firestore, this is no longer used and is left
  /// just in case
  String toString() {
    return deadlineDay.toString();
  }
}
