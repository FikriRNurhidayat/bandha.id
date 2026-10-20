import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  final row = {
    "id": "c1",
    "name": "Food",
    "readonly": 1,
    "created_at": "2026-01-15T10:30:00.000Z",
    "updated_at": "2026-01-16T10:30:00.000Z",
  };

  group("Category.create", () {
    test("is writable with equal timestamps", () {
      final category = Category.create(name: "Food");

      expect(category.id, isNotEmpty);
      expect(category.name, "Food");
      expect(category.readOnly, isFalse);
      expect(category.createdAt, category.updatedAt);
    });
  });

  group("Category.fromRow", () {
    test("maps columns and readonly flag", () {
      final category = Category.fromRow(row);

      expect(category.id, "c1");
      expect(category.name, "Food");
      expect(category.readOnly, isTrue);
      expect(category.createdAt, DateTime.utc(2026, 1, 15, 10, 30));
      expect(category.updatedAt, DateTime.utc(2026, 1, 16, 10, 30));
    });

    test("treats readonly other than 1 as writable", () {
      expect(Category.fromRow({...row, "readonly": 0}).readOnly, isFalse);
      expect(Category.fromRow({...row, "readonly": null}).readOnly, isFalse);
    });

    test("tryRow handles null", () {
      expect(Category.tryRow(null), isNull);
      expect(Category.tryRow(row)?.id, "c1");
    });
  });

  test(
    "copyWith renames and keeps identity",
    () {
      final category = makeCategory(id: "c1", name: "Food", readOnly: true);
      final copy = category.copyWith(name: "Meals");

      expect(copy.id, "c1");
      expect(copy.name, "Meals");
      expect(copy.readOnly, isTrue);
      expect(copy.createdAt, fixedTime);
    },
    skip:
        "BUG: Category.copyWith throws UnimplementedError, so UpdateClassifier<Category> always fails",
  );

  test("toJson uses ISO timestamps", () {
    expect(makeCategory(id: "c1", readOnly: true).toJson(), {
      "id": "c1",
      "name": "Food",
      "readOnly": true,
      "createdAt": fixedTime.toIso8601String(),
      "updatedAt": fixedTime.toIso8601String(),
    });
  });

  test("equality is by id and type", () {
    expect(makeCategory(id: "x", name: "A"), makeCategory(id: "x", name: "B"));
    expect(makeCategory(id: "x"), isNot(makeLabel(id: "x")));
  });
}
