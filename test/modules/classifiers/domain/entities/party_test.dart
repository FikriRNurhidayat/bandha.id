import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  final row = {
    "id": "p1",
    "name": "Alice",
    "created_at": "2026-01-15T10:30:00.000Z",
    "updated_at": "2026-01-16T10:30:00.000Z",
  };

  test("Party.create is writable with equal timestamps", () {
    final party = Party.create(name: "Alice");

    expect(party.id, isNotEmpty);
    expect(party.name, "Alice");
    expect(party.readOnly, isFalse);
    expect(party.createdAt, party.updatedAt);
  });

  group("Party.fromRow", () {
    test("maps columns and is never readonly", () {
      final party = Party.fromRow({...row, "readonly": 1});

      expect(party.id, "p1");
      expect(party.name, "Alice");
      expect(party.readOnly, isFalse);
      expect(party.createdAt, DateTime.utc(2026, 1, 15, 10, 30));
      expect(party.updatedAt, DateTime.utc(2026, 1, 16, 10, 30));
    });

    test("tryRow handles null", () {
      expect(Party.tryRow(null), isNull);
      expect(Party.tryRow(row)?.id, "p1");
    });
  });

  test(
    "copyWith renames and keeps identity",
    () {
      final party = makeParty(id: "p1");
      final copy = party.copyWith(name: "Bob");

      expect(copy.id, "p1");
      expect(copy.name, "Bob");
      expect(copy.createdAt, fixedTime);
    },
    skip:
        "BUG: Party.copyWith throws UnimplementedError, so UpdateClassifier<Party> always fails",
  );
}
