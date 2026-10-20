import 'package:bandha/modules/transfers/data/services/transfer_hydrator.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';
import '../../../../support/transfers_fakes.dart';

/// Strips a hydrated transfer down to the row-level ids.
Transfer bare(Transfer t) => Transfer(
  id: t.id,
  note: t.note,
  creditId: t.creditId,
  creditFeeId: t.creditFeeId,
  debitId: t.debitId,
  debitFeeId: t.debitFeeId,
  issuedAt: t.issuedAt,
  createdAt: t.createdAt,
  updatedAt: t.updatedAt,
);

void main() {
  group("TransferHydrator", () {
    test("hydrate attaches debit, credit and fees", () async {
      final source = makeTransfer(debitFeeAmount: -1, creditFeeAmount: -2);
      final reader = FakeEntryReader(seed: source.entries);
      final hydrated = await TransferHydrator(
        entryReader: reader,
      ).hydrate(bare(source));

      expect(hydrated.debit, same(source.debit));
      expect(hydrated.debitFee, same(source.debitFee));
      expect(hydrated.credit, same(source.credit));
      expect(hydrated.creditFee, same(source.creditFee));
      expect(hydrated.entryIds, source.entryIds);
    });

    test("hydrate leaves absent fees null", () async {
      final source = makeTransfer();
      final hydrated = await TransferHydrator(
        entryReader: FakeEntryReader(seed: source.entries),
      ).hydrate(bare(source));

      expect(hydrated.debitFee, isNull);
      expect(hydrated.creditFee, isNull);
      expect(hydrated.debitFeeId, isNull);
      expect(hydrated.creditFeeId, isNull);
    });

    test("hydrateAll batches entry lookups into one read", () async {
      final a = makeTransfer(id: "a", debitFeeAmount: -1);
      final b = makeTransfer(id: "b", creditFeeAmount: -2);
      final reader = FakeEntryReader(seed: [...a.entries, ...b.entries]);

      final hydrated = (await TransferHydrator(
        entryReader: reader,
      ).hydrateAll([bare(a), bare(b)])).toList();

      expect(reader.requestedIds, [
        [...a.entryIds, ...b.entryIds],
      ]);
      expect(hydrated.map((t) => t.id), ["a", "b"]);
      expect(hydrated[0].debitFee, same(a.debitFee));
      expect(hydrated[0].creditFee, isNull);
      expect(hydrated[1].creditFee, same(b.creditFee));
      expect(hydrated[1].debitFee, isNull);
    });

    test("hydrateAll of nothing returns nothing", () async {
      final hydrated = await TransferHydrator(
        entryReader: FakeEntryReader(),
      ).hydrateAll([]);
      expect(hydrated, isEmpty);
    });

    test("drops a fee id whose entry is missing", () async {
      final source = makeTransfer(debitFeeAmount: -1);
      final reader = FakeEntryReader(seed: [source.debit, source.credit]);
      final hydrated = await TransferHydrator(
        entryReader: reader,
      ).hydrate(bare(source));

      expect(hydrated.debitFee, isNull);
      expect(hydrated.debitFeeId, isNull);
    });

    test("throws when the debit entry is missing", () async {
      final source = makeTransfer();
      final reader = FakeEntryReader(seed: [source.credit]);
      await expectLater(
        TransferHydrator(entryReader: reader).hydrate(bare(source)),
        throwsA(isA<TypeError>()),
      );
    });

    test("keeps row fields", () async {
      final source = makeTransfer(id: "t1");
      final hydrated = await TransferHydrator(
        entryReader: FakeEntryReader(seed: source.entries),
      ).hydrate(bare(source));
      expect(hydrated.id, "t1");
      expect(hydrated.issuedAt, fixedTime);
    });
  });
}
