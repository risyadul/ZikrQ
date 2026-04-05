import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';

void main() {
  group('nextLocalChangeVersion', () {
    test('returns 1 for legacy version 0', () {
      expect(MemorizationLocalDatasource.nextLocalChangeVersion(0), 1);
    });

    test('returns 1 for negative legacy version', () {
      expect(MemorizationLocalDatasource.nextLocalChangeVersion(-3), 1);
    });

    test('increments modern version', () {
      expect(MemorizationLocalDatasource.nextLocalChangeVersion(7), 8);
    });
  });
}
