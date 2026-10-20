import 'package:bandha/modules/entries/data/services/entry_writer_impl.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/transfers/application/use_cases/destroy_transfer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes.dart';
import '../../../../support/transfers_fakes.dart';

void main() {
  group("DestroyTransfer", () {
    test("destroys the transfer and all its entries", () async {
      final transfer = makeTransfer(debitFeeAmount: -1, creditFeeAmount: -2);
      final repository = FakeTransferRepository(seed: [transfer]);
      final entryWriter = FakeEntryWriter();
      final unitOfWork = FakeUnitOfWork();

      await DestroyTransfer(
        repository,
        entryWriter: entryWriter,
        unitOfWork: unitOfWork,
      ).execute(transfer.id);

      expect(unitOfWork.executions, 1);
      expect(repository.destroyed, [transfer]);
      expect(repository.store, isEmpty);
      expect(entryWriter.destroyed, transfer.entries.toList());
      expect(entryWriter.destroyed, hasLength(4));
    });

    test("only destroys existing entries when there are no fees", () async {
      final transfer = makeTransfer();
      final entryWriter = FakeEntryWriter();

      await DestroyTransfer(
        FakeTransferRepository(seed: [transfer]),
        entryWriter: entryWriter,
        unitOfWork: FakeUnitOfWork(),
      ).execute(transfer.id);

      expect(entryWriter.destroyed, [transfer.credit, transfer.debit]);
    });

    test("raises EntryDestroyed per entry via the real writer", () async {
      final transfer = makeTransfer(debitFeeAmount: -1);
      final publisher = RecordingEventPublisher();
      final entryRepository = FakeEntryRepository(seed: transfer.entries);

      await DestroyTransfer(
        FakeTransferRepository(seed: [transfer]),
        entryWriter: EntryWriterImpl(
          entryRepository: entryRepository,
          eventPublisher: publisher,
        ),
        unitOfWork: FakeUnitOfWork(),
      ).execute(transfer.id);

      expect(entryRepository.store, isEmpty);
      expect(
        publisher.ofType<EntryDestroyed>().map((e) => e.entryId),
        unorderedEquals(transfer.entryIds),
      );
    });

    test("fails without touching entries when missing", () async {
      final entryWriter = FakeEntryWriter();
      await expectLater(
        DestroyTransfer(
          FakeTransferRepository(),
          entryWriter: entryWriter,
          unitOfWork: FakeUnitOfWork(),
        ).execute("missing"),
        throwsException,
      );
      expect(entryWriter.destroyed, isEmpty);
    });
  });
}
