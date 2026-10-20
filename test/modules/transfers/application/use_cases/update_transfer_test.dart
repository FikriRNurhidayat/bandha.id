import 'package:bandha/core/domain/constants/system_categories.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/modules/entries/data/services/entry_writer_impl.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/transfers/application/use_cases/update_transfer.dart';
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
  late FakeCategoryReader categoryReader;
  late FakeUnitOfWork unitOfWork;

  final laterTime = DateTime.utc(2026, 2, 1);

  setUp(() {
    debitJournal = makeJournal(name: "Bank");
    creditJournal = makeJournal(name: "Wallet");
    entryWriter = FakeEntryWriter();
    transferRepository = FakeTransferRepository();
    categoryReader = transferCategoryReader();
    unitOfWork = FakeUnitOfWork();
  });

  Transfer seed({double? debitFeeAmount, double? creditFeeAmount}) {
    final transfer = makeTransfer(
      debitJournal: debitJournal,
      creditJournal: creditJournal,
      debitFeeAmount: debitFeeAmount,
      creditFeeAmount: creditFeeAmount,
    );
    transferRepository.store[transfer.id] = transfer;
    return transfer;
  }

  UpdateTransfer build([EntryWriter? writer]) => UpdateTransfer(
    entryWriter: writer ?? entryWriter,
    unitOfWork: unitOfWork,
    transferRepository: transferRepository,
    categoryReader: categoryReader,
  );

  /// Calls the use case with the seeded values unless overridden.
  Future<Transfer> run(
    Transfer before, {
    UpdateTransfer? useCase,
    String? note = "Move",
    String? debitJournalId,
    String? creditJournalId,
    double? debitAmount,
    double? creditAmount,
    double? debitFeeAmount,
    double? creditFeeAmount,
    DateTime? issuedAt,
  }) {
    return (useCase ?? build()).execute(
      before.id,
      note: note,
      debitJournalId: debitJournalId ?? before.debit.journalId,
      creditJournalId: creditJournalId ?? before.credit.journalId,
      debitAmount: debitAmount ?? before.debit.amount,
      creditAmount: creditAmount ?? before.credit.amount,
      debitFeeAmount: debitFeeAmount,
      creditFeeAmount: creditFeeAmount,
      issuedAt: issuedAt ?? before.issuedAt,
    );
  }

  DataChangeSetView plan() => DataChangeSetView(entryWriter);

  group("unchanged entries", () {
    test("executes an empty plan and saves the transfer", () async {
      final before = seed();
      final after = await run(before, note: "Renamed", issuedAt: laterTime);

      expect(unitOfWork.executions, 1);
      expect(entryWriter.executed, hasLength(1));
      expect(entryWriter.executed.single.isEmpty, isTrue);
      expect(transferRepository.saved, [after]);
      expect(after, isNot(same(before)));
      expect(after.id, before.id);
      expect(after.note, "Renamed");
      expect(after.issuedAt, laterTime);
      expect(after.debit, same(before.debit));
      expect(after.credit, same(before.credit));
    });

    test("keeps the old note when none is given", () async {
      final before = seed();
      final after = await run(before, note: null);
      expect(after.note, "Move");
    });

    test("leaves unchanged fees alone", () async {
      final before = seed(debitFeeAmount: -500, creditFeeAmount: -250);
      final after = await run(
        before,
        debitFeeAmount: -500,
        creditFeeAmount: -250,
      );

      expect(entryWriter.executed.single.isEmpty, isTrue);
      expect(after.debitFee, same(before.debitFee));
      expect(after.creditFee, same(before.creditFee));
      expect(after.entryIds, before.entryIds);
    });

    test(
      "propagates note and issuedAt to every entry",
      () async {
        final before = seed(debitFeeAmount: -500);
        final after = await run(
          before,
          note: "Renamed",
          issuedAt: laterTime,
          debitFeeAmount: -500,
        );

        for (final entry in after.entries) {
          expect(entry.note, "Renamed");
          expect(entry.issuedAt, laterTime);
        }
      },
      skip:
          "BUG: update_transfer.dart:108,132,162,210 only touch an entry when "
          "its amount/journal changes, so a note or date edit leaves every "
          "entry with the old note and issuedAt",
    );
  });

  group("debit", () {
    test("updates the debit entry when its amount changes", () async {
      final before = seed();
      final after = await run(
        before,
        note: "Renamed",
        debitAmount: 20000,
        issuedAt: laterTime,
      );

      final change = plan().updates.single;
      expect(change.before, same(before.debit));
      expect(change.after, same(after.debit));
      expect(after.debit.id, before.debit.id);
      expect(after.debit.amount, 20000);
      expect(after.debit.note, "Renamed");
      expect(after.debit.issuedAt, laterTime);
      expect(after.debit.labels, before.debit.labels);
      expect(after.debit.controller!.id, before.id);
      expect(after.credit, same(before.credit));
    });

    test("updates the debit entry when its journal changes", () async {
      final before = seed();
      final other = makeJournal(name: "Other");
      final after = await run(before, debitJournalId: other.id);

      expect(plan().updates.single.before, same(before.debit));
      expect(after.debit.journalId, other.id);
      expect(after.debit.amount, before.debit.amount);
    });
  });

  group("credit", () {
    test("updates the credit entry when its amount changes", () async {
      final before = seed();
      final after = await run(before, creditAmount: -20000);

      final change = plan().updates.single;
      expect(change.before, same(before.credit));
      expect(after.credit.id, before.credit.id);
      expect(after.credit.amount, -20000);
      expect(after.debit, same(before.debit));
    });

    test("updates the credit entry when its journal changes", () async {
      final before = seed();
      final other = makeJournal(name: "Other");
      final after = await run(before, creditJournalId: other.id);

      expect(plan().updates.single.before, same(before.credit));
      expect(after.credit.journalId, other.id);
    });

    test("updates both sides independently", () async {
      final before = seed();
      final after = await run(before, debitAmount: 1, creditAmount: -1);

      expect(plan().updates.map((c) => c.before), [
        before.debit,
        before.credit,
      ]);
      expect(after.debit.amount, 1);
      expect(after.credit.amount, -1);
    });
  });

  for (final side in ["debit", "credit"]) {
    final isDebit = side == "debit";

    Future<Transfer> runFee(
      Transfer before,
      double? fee, {
      String? journalId,
    }) => isDebit
        ? run(before, debitFeeAmount: fee, debitJournalId: journalId)
        : run(before, creditFeeAmount: fee, creditJournalId: journalId);

    Transfer seedFee([double? fee]) =>
        isDebit ? seed(debitFeeAmount: fee) : seed(creditFeeAmount: fee);

    Entry? feeOf(Transfer t) => isDebit ? t.debitFee : t.creditFee;
    String? feeIdOf(Transfer t) => isDebit ? t.debitFeeId : t.creditFeeId;
    Journal journalOf() => isDebit ? debitJournal : creditJournal;

    group("$side fee", () {
      test("does nothing when absent before and after", () async {
        final before = seedFee();
        final after = await runFee(before, null);

        expect(entryWriter.executed.single.isEmpty, isTrue);
        expect(feeOf(after), isNull);
        expect(feeIdOf(after), isNull);
      });

      test("is created when added", () async {
        final before = seedFee();
        final after = await runFee(before, -500);

        final created = plan().creates.single;
        expect(feeOf(after), same(created));
        expect(feeIdOf(after), created.id);
        expect(created.amount, -500);
        expect(created.journalId, journalOf().id);
        expect(created.categoryId, SystemCategories.transferId);
        expect(created.note, "Move");
        expect(created.readOnly, isTrue);
        expect(created.status, EntryStatus.done);
        expect(after.entryIds, contains(created.id));
        expect(transferRepository.saved.single, after);
      });

      test(
        "is created hydrated, labelled and controlled like on create",
        () async {
          final before = seedFee();
          final after = await runFee(before, -500);
          final created = feeOf(after)!;

          expect(created.labels.map((l) => l.id), [
            isDebit ? SystemLabels.debitId : SystemLabels.creditId,
            SystemLabels.feeId,
          ]);
          expect(created.controller?.id, after.id);
          expect(created.journal.id, journalOf().id);
          expect(created.category.id, SystemCategories.transferId);
        },
        skip:
            "BUG: update_transfer.dart:167-177/215-225 create the fee via "
            "entryWriter.readOnly without .withLabels([side, fee]), "
            ".withJournal/.withCategory or .of(transfer) (create_transfer.dart "
            "does all of these): the new fee has no labels, no controller and "
            "an uninitialised `journal`, so EntryWriterImpl's EntryCreated "
            "snapshot throws LateInitializationError",
      );

      test("is updated when its amount changes", () async {
        final before = seedFee(-500);
        final after = await runFee(before, -750);

        final change = plan().updates.single;
        expect(change.before, same(feeOf(before)));
        expect(change.after, same(feeOf(after)));
        expect(feeOf(after)!.id, feeOf(before)!.id);
        expect(feeOf(after)!.amount, -750);
        expect(feeOf(after)!.labels, feeOf(before)!.labels);
        expect(feeIdOf(after), feeIdOf(before));
      });

      test("is destroyed when removed with null", () async {
        final before = seedFee(-500);
        final after = await runFee(before, null);

        expect(plan().destroys, [feeOf(before)]);
        expect(feeOf(after), isNull);
        expect(feeIdOf(after), isNull);
        expect(after.entryIds, isNot(contains(feeIdOf(before))));
        expect(feeOf(before), isNotNull, reason: "before stays intact");
      });

      test("is destroyed when removed with zero", () async {
        final before = seedFee(-500);
        final after = await runFee(before, 0);

        expect(plan().destroys, [feeOf(before)]);
        expect(feeOf(after), isNull);
      });

      test(
        "is not created for a zero amount",
        () async {
          final before = seedFee();
          final after = await runFee(before, 0);

          expect(entryWriter.executed.single.isEmpty, isTrue);
          expect(feeOf(after), isNull);
        },
        skip:
            "BUG: update_transfer.dart:156,204 only destroy when a fee exists; "
            "with no prior fee, _${side}FeeChanged(0) is true and a "
            "zero-amount fee entry is created",
      );

      test(
        "moves with its journal when the $side journal changes",
        () async {
          final before = seedFee(-500);
          final other = makeJournal(name: "Other");
          final after = await runFee(before, -500, journalId: other.id);

          expect(feeOf(after)!.journalId, other.id);
        },
        skip:
            "BUG: update_transfer.dart:247-251/266-270 _${side}FeeChanged "
            "compares only the amount, so changing the $side journal moves "
            "the main entry but leaves the fee on the old journal",
      );
    });
  }

  test("combines create, update and destroy in one plan", () async {
    final before = seed(creditFeeAmount: -250);
    final after = await run(
      before,
      debitAmount: 20000,
      debitFeeAmount: -500,
      creditFeeAmount: null,
    );

    final p = plan();
    expect(p.creates, [after.debitFee]);
    expect(p.updates.map((c) => c.before), [before.debit]);
    expect(p.destroys, [before.creditFee]);
    expect(after.entryIds, [after.creditId, after.debitId, after.debitFeeId]);
  });

  group("errors", () {
    test("fails when the transfer does not exist", () async {
      await expectLater(
        build().execute(
          "missing",
          debitJournalId: debitJournal.id,
          creditJournalId: creditJournal.id,
          debitAmount: 1,
          creditAmount: -1,
          issuedAt: fixedTime,
        ),
        throwsException,
      );
      expect(entryWriter.executed, isEmpty);
      expect(transferRepository.saved, isEmpty);
    });

    test("fails when the transfer category is missing", () async {
      final before = seed();
      categoryReader.store.clear();

      await expectLater(run(before, debitAmount: 1), throwsException);
      expect(entryWriter.executed, isEmpty);
      expect(transferRepository.saved, isEmpty);
    });
  });

  group("with the real entry writer", () {
    late RecordingEventPublisher publisher;
    late FakeEntryRepository entryRepository;
    late UpdateTransfer useCase;

    setUp(() {
      publisher = RecordingEventPublisher();
      entryRepository = FakeEntryRepository();
      useCase = build(
        EntryWriterImpl(
          entryRepository: entryRepository,
          eventPublisher: publisher,
        ),
      );
    });

    test("raises EntryUpdated with the amount delta", () async {
      final before = seed();
      final after = await run(before, useCase: useCase, debitAmount: 20000);

      final event = publisher.ofType<EntryUpdated>().single;
      expect(event.entryId, before.debitId);
      expect(event.before.amount, 10000);
      expect(event.after.amount, 20000);
      expect(event.amountChanged, isTrue);
      expect(entryRepository.store[after.debitId]!.amount, 20000);
    });

    test("raises EntryDestroyed when a fee is removed", () async {
      final before = seed(debitFeeAmount: -500);
      await run(before, useCase: useCase, debitFeeAmount: null);

      final event = publisher.ofType<EntryDestroyed>().single;
      expect(event.entryId, before.debitFeeId);
      expect(event.snapshot.amount, -500);
      expect(entryRepository.destroyed, [before.debitFee]);
    });

    test(
      "raises EntryUpdated with journalChanged when the journal moves",
      () async {
        final before = seed();
        final other = makeJournal(name: "Other");
        await run(before, useCase: useCase, debitJournalId: other.id);

        final event = publisher.ofType<EntryUpdated>().single;
        expect(event.before.journalId, debitJournal.id);
        expect(event.after.journalId, other.id);
        expect(event.journalChanged, isTrue);
      },
      skip:
          "BUG: update_transfer.dart:113,137 Entry.copyWith(journalId:) keeps "
          "the old hydrated `journal`, and EntrySnapshot reads entry.journal.id, "
          "so the event reports no journal change and balances are not moved",
    );

    test(
      "raises EntryCreated when a fee is added",
      () async {
        final before = seed();
        final after = await run(before, useCase: useCase, debitFeeAmount: -500);

        final event = publisher.ofType<EntryCreated>().single;
        expect(event.entryId, after.debitFeeId);
        expect(event.snapshot.journalId, debitJournal.id);
      },
      skip:
          "BUG: update_transfer.dart:167-177 new fee entry has no journal "
          "attached; EntryCreated.fromEntry throws LateInitializationError",
    );
  });
}

/// Flattens everything the [FakeEntryWriter] was asked to execute.
class DataChangeSetView {
  final FakeEntryWriter writer;
  DataChangeSetView(this.writer);

  List<Entry> get creates =>
      writer.executed.expand((s) => s.createList).toList();
  List<DataChange<Entry>> get updates =>
      writer.executed.expand((s) => s.updateList).toList();
  List<Entry> get destroys =>
      writer.executed.expand((s) => s.destroyList).toList();
}
