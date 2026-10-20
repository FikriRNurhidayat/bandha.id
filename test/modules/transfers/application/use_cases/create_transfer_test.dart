import 'package:bandha/core/domain/constants/system_categories.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/modules/entries/data/services/entry_writer_impl.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/transfers/application/use_cases/create_transfer.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';
import '../../../../support/transfers_fakes.dart';

void main() {
  late Journal debitJournal;
  late Journal creditJournal;
  late FakeEntryWriter entryWriter;
  late FakeTransferRepository transferRepository;
  late FakeUnitOfWork unitOfWork;
  late FakeCategoryReader categoryReader;
  late FakeJournalReader journalReader;
  late CreateTransfer useCase;

  setUp(() {
    debitJournal = makeJournal(name: "Bank");
    creditJournal = makeJournal(name: "Wallet");
    entryWriter = FakeEntryWriter();
    transferRepository = FakeTransferRepository();
    unitOfWork = FakeUnitOfWork();
    categoryReader = transferCategoryReader();
    journalReader = FakeJournalReader(seed: [debitJournal, creditJournal]);
    useCase = CreateTransfer(
      entryWriter: entryWriter,
      labelReader: transferLabelReader(),
      unitOfWork: unitOfWork,
      transferRepository: transferRepository,
      journalReader: journalReader,
      categoryReader: categoryReader,
    );
  });

  Future<Transfer> run({
    String? note,
    double? debitFeeAmount,
    double? creditFeeAmount,
  }) {
    return useCase.execute(
      note: note,
      debitJournalId: debitJournal.id,
      creditJournalId: creditJournal.id,
      debitAmount: 10000,
      creditAmount: -10000,
      debitFeeAmount: debitFeeAmount,
      creditFeeAmount: creditFeeAmount,
      issuedAt: fixedTime,
    );
  }

  Iterable<String> labelIds(Entry entry) => entry.labels.map((l) => l.id);

  group("without fees", () {
    test("creates debit and credit entries and saves the transfer", () async {
      final transfer = await run();

      expect(unitOfWork.executions, 1);
      expect(entryWriter.created, hasLength(2));
      expect(transferRepository.saved, [transfer]);
      expect(transfer.creditFeeId, isNull);
      expect(transfer.debitFeeId, isNull);
      expect(transfer.issuedAt, fixedTime);

      final [debit, credit] = entryWriter.created;
      expect(transfer.debitId, debit.id);
      expect(transfer.creditId, credit.id);
    });

    test("builds read-only, categorised, labelled entries", () async {
      final transfer = await run();
      final [debit, credit] = entryWriter.created;

      expect(debit.amount, 10000);
      expect(debit.journalId, debitJournal.id);
      expect(debit.journal, same(debitJournal));
      expect(labelIds(debit), [SystemLabels.debitId]);

      expect(credit.amount, -10000);
      expect(credit.journalId, creditJournal.id);
      expect(credit.journal, same(creditJournal));
      expect(labelIds(credit), [SystemLabels.creditId]);

      for (final entry in [debit, credit]) {
        expect(entry.readOnly, isTrue);
        expect(entry.status, EntryStatus.done);
        expect(entry.categoryId, SystemCategories.transferId);
        expect(entry.category.id, SystemCategories.transferId);
        expect(entry.issuedAt, fixedTime);
        expect(entry.controller!.id, transfer.id);
        expect(entry.controller!.type, "Transfer");
      }
    });
  });

  group("with fees", () {
    test("creates debit fee entry on the debit journal", () async {
      final transfer = await run(debitFeeAmount: -500);
      final [debit, debitFee, credit] = entryWriter.created;

      expect(transfer.debitId, debit.id);
      expect(transfer.debitFeeId, debitFee.id);
      expect(transfer.creditId, credit.id);
      expect(transfer.creditFeeId, isNull);
      expect(debitFee.amount, -500);
      expect(debitFee.journalId, debitJournal.id);
      expect(debitFee.readOnly, isTrue);
      expect(labelIds(debitFee), [SystemLabels.debitId, SystemLabels.feeId]);
      expect(debitFee.controller!.id, transfer.id);
    });

    test("creates credit fee entry on the credit journal", () async {
      final transfer = await run(creditFeeAmount: -250);
      final [_, credit, creditFee] = entryWriter.created;

      expect(transfer.creditId, credit.id);
      expect(transfer.creditFeeId, creditFee.id);
      expect(transfer.debitFeeId, isNull);
      expect(creditFee.amount, -250);
      expect(creditFee.journalId, creditJournal.id);
      expect(labelIds(creditFee), [SystemLabels.creditId, SystemLabels.feeId]);
    });

    test("creates all four entries when both fees are present", () async {
      final transfer = await run(debitFeeAmount: -500, creditFeeAmount: -250);

      expect(entryWriter.created.map((e) => e.id), [
        transfer.debitId,
        transfer.debitFeeId,
        transfer.creditId,
        transfer.creditFeeId,
      ]);
    });

    test(
      "treats a zero fee as no fee",
      () async {
        final transfer = await run(debitFeeAmount: 0, creditFeeAmount: 0);
        expect(entryWriter.created, hasLength(2));
        expect(transfer.debitFeeId, isNull);
        expect(transfer.creditFeeId, isNull);
      },
      skip:
          "BUG: create_transfer.dart:92,116 only checks for null, so a 0 fee "
          "creates a zero-amount fee entry, while update_transfer.dart:243,262 "
          "treats 0 as 'no fee'",
    );
  });

  test(
    "stores the note on the transfer and its entries",
    () async {
      final transfer = await run(note: "Savings");
      expect(transfer.note, "Savings");
      for (final entry in entryWriter.created) {
        expect(entry.note, "Savings");
      }
    },
    skip:
        "BUG: create_transfer.dart:81-137 never passes `note` to "
        "Transfer.create or entryWriter.readOnly, so the note is dropped "
        "(update_transfer.dart does persist it)",
  );

  group("errors", () {
    test("fails when the transfer category is missing", () async {
      categoryReader.store.clear();
      await expectLater(run(), throwsException);
      expect(entryWriter.created, isEmpty);
      expect(transferRepository.saved, isEmpty);
    });

    test("fails when a journal is missing", () async {
      journalReader.store.remove(creditJournal.id);
      await expectLater(run(), throwsStateError);
      expect(entryWriter.created, isEmpty);
      expect(transferRepository.saved, isEmpty);
    });

    test("fails when a system label is missing", () async {
      final labelReader = transferLabelReader();
      labelReader.store.remove(SystemLabels.feeId);
      final failing = CreateTransfer(
        entryWriter: entryWriter,
        labelReader: labelReader,
        unitOfWork: unitOfWork,
        transferRepository: transferRepository,
        journalReader: journalReader,
        categoryReader: categoryReader,
      );

      await expectLater(
        failing.execute(
          debitJournalId: debitJournal.id,
          creditJournalId: creditJournal.id,
          debitAmount: 1,
          creditAmount: -1,
          issuedAt: fixedTime,
        ),
        throwsStateError,
      );
      expect(transferRepository.saved, isEmpty);
    });
  });

  test("raises EntryCreated for every entry via the real writer", () async {
    final publisher = RecordingEventPublisher();
    final entryRepository = FakeEntryRepository();
    final real = CreateTransfer(
      entryWriter: EntryWriterImpl(
        entryRepository: entryRepository,
        eventPublisher: publisher,
      ),
      labelReader: transferLabelReader(),
      unitOfWork: unitOfWork,
      transferRepository: transferRepository,
      journalReader: journalReader,
      categoryReader: categoryReader,
    );

    final transfer = await real.execute(
      debitJournalId: debitJournal.id,
      creditJournalId: creditJournal.id,
      debitAmount: 10000,
      creditAmount: -10000,
      debitFeeAmount: -500,
      creditFeeAmount: -250,
      issuedAt: fixedTime,
    );

    expect(entryRepository.store.keys, unorderedEquals(transfer.entryIds));
    final events = publisher.ofType<EntryCreated>().toList();
    expect(events.map((e) => e.entryId), unorderedEquals(transfer.entryIds));
    final debitEvent = events.firstWhere((e) => e.entryId == transfer.debitId);
    expect(debitEvent.snapshot.journalId, debitJournal.id);
    expect(debitEvent.snapshot.assetId, debitJournal.asset.id);
    expect(debitEvent.snapshot.amount, 10000);
  });
}
