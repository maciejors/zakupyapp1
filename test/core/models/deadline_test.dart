import 'package:flutter_test/flutter_test.dart';
import 'package:zakupyapp/core/models/deadline.dart';

void main() {
  var now = DateTime.now();
  var today = DateTime(now.year, now.month, now.day);

  group('getUrgency() correctly classifies date differences', () {
    test('yesterday is too late', () {
      var deadline = Deadline(today.subtract(const Duration(days: 1)));
      var result = Urgency.tooLate;
      expect(deadline.getUrgency(), equals(result));
    });
    test('exact day is urgent', () {
      var deadline = Deadline(today);
      var result = Urgency.urgent;
      expect(deadline.getUrgency(), equals(result));
    });
    test('tomorrow is urgent', () {
      var deadline = Deadline(today.add(const Duration(days: 1)));
      var result = Urgency.urgent;
      expect(deadline.getUrgency(), equals(result));
    });
    test('in two days is not urgent', () {
      var deadline = Deadline(today.add(const Duration(days: 2)));
      var result = Urgency.notUrgent;
      expect(deadline.getUrgency(), equals(result));
    });
  });

  group('getPolishDescription() returns correct labels', () {
    test('deadline more than two days ago', () {
      var deadline = Deadline(today.subtract(const Duration(days: 3)));
      var result = '3 dni temu';
      expect(deadline.getPolishDescription(), equals(result));
    });
    test('deadline two days ago', () {
      var deadline = Deadline(today.subtract(const Duration(days: 2)));
      var result = 'przedwczoraj';
      expect(deadline.getPolishDescription(), equals(result));
    });
    test('deadline yesterday', () {
      var deadline = Deadline(today.subtract(const Duration(days: 1)));
      var result = 'wczoraj';
      expect(deadline.getPolishDescription(), equals(result));
    });
    test('deadline today', () {
      var deadline = Deadline(today);
      var result = 'dzisiaj';
      expect(deadline.getPolishDescription(), equals(result));
    });
    test('deadline tomorrow', () {
      var deadline = Deadline(today.add(const Duration(days: 1)));
      var result = 'jutro';
      expect(deadline.getPolishDescription(), equals(result));
    });
    test('deadline in two days', () {
      var deadline = Deadline(today.add(const Duration(days: 2)));
      var result = 'pojutrze';
      expect(deadline.getPolishDescription(), equals(result));
    });
    test('deadline in more than two days', () {
      var deadline = Deadline(today.add(const Duration(days: 3)));
      var result = 'za 3 dni';
      expect(deadline.getPolishDescription(), equals(result));
    });
  });
}
