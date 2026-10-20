import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("DataList", () {
    final next = DataCursor(direction: DataCursorDirection.next, values: {});
    final prev = DataCursor(
      direction: DataCursorDirection.previous,
      values: {},
    );

    test("iterates hits", () {
      final list = DataList<int>(
        hasNext: false,
        hasPrevious: false,
        hits: [1, 2, 3],
      );
      expect(list.toList(), [1, 2, 3]);
      expect(list.length, 3);
      expect(list.isEmpty, isFalse);
    });

    test("copyWith keeps unspecified fields", () {
      final list = DataList<int>(
        previous: prev,
        next: next,
        hasNext: true,
        hasPrevious: true,
        hits: [1],
      );
      final copy = list.copyWith(hits: [9]);
      expect(copy.toList(), [9]);
      expect(copy.next, same(next));
      expect(copy.previous, same(prev));
      expect(copy.hasNext, isTrue);
      expect(copy.hasPrevious, isTrue);
    });

    test("copyWith overrides given fields", () {
      final list = DataList<int>(hasNext: true, hasPrevious: true, hits: [1]);
      final copy = list.copyWith(
        hasNext: false,
        hasPrevious: false,
        next: next,
        previous: prev,
      );
      expect(copy.hasNext, isFalse);
      expect(copy.hasPrevious, isFalse);
      expect(copy.next, same(next));
      expect(copy.previous, same(prev));
      expect(copy.toList(), [1]);
    });
  });
}
