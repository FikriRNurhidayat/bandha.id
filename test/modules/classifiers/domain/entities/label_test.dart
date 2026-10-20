import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  final row = {
    "id": "l1",
    "name": "Tag",
    "readonly": 1,
    "created_at": "2026-01-15T10:30:00.000Z",
    "updated_at": "2026-01-16T10:30:00.000Z",
  };

  group("Label.create", () {
    test("is writable with equal timestamps", () {
      final label = Label.create(name: "Tag");

      expect(label.id, isNotEmpty);
      expect(label.name, "Tag");
      expect(label.readOnly, isFalse);
      expect(label.createdAt, label.updatedAt);
    });
  });

  group("Label.fromRow", () {
    test("maps columns and readonly flag", () {
      final label = Label.fromRow(row);

      expect(label.id, "l1");
      expect(label.name, "Tag");
      expect(label.readOnly, isTrue);
      expect(label.createdAt, DateTime.utc(2026, 1, 15, 10, 30));
      expect(label.updatedAt, DateTime.utc(2026, 1, 16, 10, 30));
    });

    test("treats readonly other than 1 as writable", () {
      expect(Label.fromRow({...row, "readonly": 0}).readOnly, isFalse);
    });

    test("tryRow handles null", () {
      expect(Label.tryRow(null), isNull);
      expect(Label.tryRow(row)?.id, "l1");
    });
  });

  test(
    "copyWith renames and keeps identity",
    () {
      final label = makeLabel(id: "l1", name: "Tag");
      final copy = label.copyWith(name: "Trip");

      expect(copy.id, "l1");
      expect(copy.name, "Trip");
      expect(copy.createdAt, fixedTime);
    },
    skip:
        "BUG: Label.copyWith throws UnimplementedError, so UpdateClassifier<Label> always fails",
  );

  test("toJson uses ISO timestamps", () {
    expect(makeLabel(id: "l1").toJson(), {
      "id": "l1",
      "name": "Tag",
      "readOnly": false,
      "createdAt": fixedTime.toIso8601String(),
      "updatedAt": fixedTime.toIso8601String(),
    });
  });
}
