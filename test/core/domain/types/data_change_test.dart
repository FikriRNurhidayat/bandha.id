import 'package:bandha/core/domain/types/data_change.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("DataChange", () {
    test("holds before and after", () {
      const c = DataChange(1, 2);
      expect(c.before, 1);
      expect(c.after, 2);
    });
  });

  group("DataChangeList", () {
    test("starts empty", () {
      final list = DataChangeList<int>([]);
      expect(list.isEmpty, isTrue);
      expect(list.isNotEmpty, isFalse);
      expect(list.length, 0);
    });

    test("add appends and is chainable", () {
      final list = DataChangeList<int>([]);
      expect(list.add(1, 10).add(2, 20), same(list));
      expect(list.length, 2);
      expect(list.isNotEmpty, isTrue);
      expect(list.before, [1, 2]);
      expect(list.after, [10, 20]);
    });

    test("iterates the changes in order", () {
      final list = DataChangeList<int>([]).add(1, 10).add(2, 20);
      expect(list.map((c) => "${c.before}>${c.after}"), ["1>10", "2>20"]);
    });
  });

  group("DataChangeSet", () {
    test("starts empty", () {
      final set = DataChangeSet<String>();
      expect(set.isEmpty, isTrue);
      expect(set.isNotEmpty, isFalse);
      expect(set.shouldCreate, isFalse);
      expect(set.shouldUpdate, isFalse);
      expect(set.shouldDestroy, isFalse);
    });

    test("create records and returns the data", () {
      final set = DataChangeSet<String>();
      expect(set.create("a"), "a");
      expect(set.createList, ["a"]);
      expect(set.shouldCreate, isTrue);
      expect(set.isNotEmpty, isTrue);
    });

    test("update records the change and returns after", () {
      final set = DataChangeSet<String>();
      expect(set.update("a", "b"), "b");
      expect(set.updateList.before, ["a"]);
      expect(set.updateList.after, ["b"]);
      expect(set.shouldUpdate, isTrue);
      expect(set.shouldCreate, isFalse);
    });

    test("destroy records the data", () {
      final set = DataChangeSet<String>()..destroy("a");
      expect(set.destroyList, ["a"]);
      expect(set.shouldDestroy, isTrue);
      expect(set.isEmpty, isFalse);
    });
  });
}
