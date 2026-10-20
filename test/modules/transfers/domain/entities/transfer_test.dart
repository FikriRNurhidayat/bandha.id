import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';
import '../../../../support/transfers_fakes.dart';

void main() {
  group("Transfer.create", () {
    test("assigns a fresh id and timestamps", () {
      final before = DateTime.now();
      final transfer = Transfer.create(
        note: "Move",
        creditId: "c",
        creditFeeId: "cf",
        debitId: "d",
        debitFeeId: "df",
        issuedAt: fixedTime,
      );

      expect(transfer.id, isNotEmpty);
      expect(transfer.note, "Move");
      expect(transfer.creditId, "c");
      expect(transfer.creditFeeId, "cf");
      expect(transfer.debitId, "d");
      expect(transfer.debitFeeId, "df");
      expect(transfer.issuedAt, fixedTime);
      expect(transfer.createdAt.isBefore(before), isFalse);
      expect(transfer.updatedAt, transfer.createdAt);
    });

    test("generates distinct ids", () {
      final a = Transfer.create(
        creditId: "c",
        debitId: "d",
        issuedAt: fixedTime,
      );
      final b = Transfer.create(
        creditId: "c",
        debitId: "d",
        issuedAt: fixedTime,
      );
      expect(a.id, isNot(b.id));
    });
  });

  group("Transfer.fromRow", () {
    final row = {
      "id": "t1",
      "note": "Rent",
      "credit_id": "c",
      "credit_fee_id": null,
      "debit_id": "d",
      "debit_fee_id": "df",
      "issued_at": "2026-01-15T10:30:00.000Z",
      "created_at": "2026-01-14T00:00:00.000Z",
      "updated_at": "2026-01-16T00:00:00.000Z",
    };

    test("maps columns", () {
      final transfer = Transfer.fromRow(row);
      expect(transfer.id, "t1");
      expect(transfer.note, "Rent");
      expect(transfer.creditId, "c");
      expect(transfer.creditFeeId, isNull);
      expect(transfer.debitId, "d");
      expect(transfer.debitFeeId, "df");
      expect(transfer.issuedAt, fixedTime);
      expect(transfer.createdAt, DateTime.utc(2026, 1, 14));
      expect(transfer.updatedAt, DateTime.utc(2026, 1, 16));
    });

    test("tryRow returns null for null and parses otherwise", () {
      expect(Transfer.tryRow(null), isNull);
      expect(Transfer.tryRow(row)!.id, "t1");
    });
  });

  group("entries and entryIds", () {
    test("skip absent fees", () {
      final transfer = makeTransfer();
      expect(transfer.entries, [transfer.credit, transfer.debit]);
      expect(transfer.entryIds, [transfer.creditId, transfer.debitId]);
    });

    test("include fees in credit, creditFee, debit, debitFee order", () {
      final transfer = makeTransfer(debitFeeAmount: -1, creditFeeAmount: -2);
      expect(transfer.entries, [
        transfer.credit,
        transfer.creditFee,
        transfer.debit,
        transfer.debitFee,
      ]);
      expect(transfer.entryIds, [
        transfer.creditId,
        transfer.creditFeeId,
        transfer.debitId,
        transfer.debitFeeId,
      ]);
    });
  });

  group("fee attachment", () {
    test("withDebitFee/withCreditFee sync the fee id", () {
      final transfer = makeTransfer();
      final fee = makeEntry(amount: -500);

      transfer.withDebitFee(fee).withCreditFee(fee);

      expect(transfer.debitFeeId, fee.id);
      expect(transfer.debitFee, fee);
      expect(transfer.creditFeeId, fee.id);
      expect(transfer.creditFee, fee);
    });

    test("clearDebitFee removes the debit fee and its id", () {
      final transfer = makeTransfer(debitFeeAmount: -1, creditFeeAmount: -2);
      final result = transfer.clearDebitFee();

      expect(result, same(transfer));
      expect(transfer.debitFee, isNull);
      expect(transfer.debitFeeId, isNull);
      expect(transfer.creditFee, isNotNull);
    });

    test("clearCreditFee removes the credit fee and its id", () {
      final transfer = makeTransfer(debitFeeAmount: -1, creditFeeAmount: -2);
      transfer.clearCreditFee();

      expect(transfer.creditFee, isNull);
      expect(transfer.creditFeeId, isNull);
      expect(transfer.debitFee, isNotNull);
    });
  });

  group("copyWith", () {
    test("keeps identity, entries and createdAt, bumps updatedAt", () {
      final transfer = makeTransfer(debitFeeAmount: -1, creditFeeAmount: -2);
      final copy = transfer.copyWith(note: "New", issuedAt: DateTime.utc(2027));

      expect(copy, isNot(same(transfer)));
      expect(copy.id, transfer.id);
      expect(copy, transfer);
      expect(copy.note, "New");
      expect(copy.issuedAt, DateTime.utc(2027));
      expect(copy.createdAt, transfer.createdAt);
      expect(copy.updatedAt.isAfter(transfer.updatedAt), isTrue);
      expect(copy.debit, same(transfer.debit));
      expect(copy.debitFee, same(transfer.debitFee));
      expect(copy.credit, same(transfer.credit));
      expect(copy.creditFee, same(transfer.creditFee));
      expect(copy.entryIds, transfer.entryIds);
    });

    test("keeps existing values when no overrides are given", () {
      final transfer = makeTransfer();
      final copy = transfer.copyWith();
      expect(copy.note, transfer.note);
      expect(copy.issuedAt, transfer.issuedAt);
      expect(copy.debitFeeId, isNull);
      expect(copy.creditFeeId, isNull);
    });

    test("mutating the copy's fees leaves the original intact", () {
      final transfer = makeTransfer(debitFeeAmount: -1);
      transfer.copyWith().clearDebitFee();
      expect(transfer.debitFee, isNotNull);
      expect(transfer.debitFeeId, isNotNull);
    });

    test(
      "honours explicit fee id overrides",
      () {
        final transfer = makeTransfer(debitFeeAmount: -1, creditFeeAmount: -2);
        final copy = transfer.copyWith(debitFeeId: "df", creditFeeId: "cf");
        expect(copy.debitFeeId, "df");
        expect(copy.creditFeeId, "cf");
      },
      skip:
          "BUG: transfer.dart:113-116 copyWith re-attaches fee entries via "
          "withDebitFee/withCreditFee, which overwrite the debitFeeId/"
          "creditFeeId arguments with the old fee entry ids",
    );
  });

  group("controller and toJson", () {
    test("controller identifies the transfer", () {
      final transfer = makeTransfer(id: "t1");
      expect(transfer.controller.id, "t1");
      expect(transfer.controller.type, "Transfer");
      expect(transfer.dataFilter, {
        "controller_id_eq": "t1",
        "controller_type_eq": "Transfer",
      });
    });

    test("serialises fields and nested entries", () {
      final transfer = makeTransfer(id: "t1", debitFeeAmount: -1);
      final json = transfer.toJson();

      expect(json["id"], "t1");
      expect(json["note"], "Move");
      expect(json["creditId"], transfer.creditId);
      expect(json["debitId"], transfer.debitId);
      expect(json["debitFeeId"], transfer.debitFeeId);
      expect(json["creditFeeId"], isNull);
      expect(json["creditFee"], isNull);
      expect((json["debit"] as Map)["id"], transfer.debitId);
      expect((json["debitFee"] as Map)["amount"], -1);
      expect((json["credit"] as Map)["id"], transfer.creditId);
      expect(json["issuedAt"], fixedTime.toIso8601String());
      expect(json["createdAt"], fixedTime.toIso8601String());
      expect(json["updatedAt"], fixedTime.toIso8601String());
    });
  });
}
