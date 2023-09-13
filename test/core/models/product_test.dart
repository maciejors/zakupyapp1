import 'package:flutter_test/flutter_test.dart';
import 'package:zakupyapp/core/models/product.dart';

void main() {
  group('formQuantityLabel correctly rounds quantity', () {
    test('Doubles that are integers are rounded', () {
      double quantity = 28.0;
      String quantityUnit = 'szt.';
      String quantityLabel = '28 szt.';
      expect(
        Product.formQuantityLabel(quantity, quantityUnit),
        equals(quantityLabel),
      );
    });
    test('Doubles that have fractions are not rounded', () {
      double quantity = 3.5;
      String quantityUnit = 'kg';
      String quantityLabel = '3.5 kg';
      expect(
        Product.formQuantityLabel(quantity, quantityUnit),
        equals(quantityLabel),
      );
    });
  });
}
