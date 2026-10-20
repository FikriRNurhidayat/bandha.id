import 'package:bandha/modules/journals/application/use_cases/create_journal.dart';
import 'package:bandha/modules/journals/domain/events/journal_created.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeUnitOfWork unitOfWork;
  late FakeJournalRepository journals;
  late RecordingEventPublisher events;
  late CreateJournal useCase;
  final asset = makeAsset();

  setUp(() {
    unitOfWork = FakeUnitOfWork();
    journals = FakeJournalRepository();
    events = RecordingEventPublisher();
    useCase = CreateJournal(
      assetReader: FakeAssetReader([asset]),
      eventPublisher: events,
      journalRepository: journals,
      unitOfWork: unitOfWork,
    );
  });

  test("saves a journal with its asset and raises JournalCreated", () async {
    final journal = await useCase.execute(
      name: "Wallet",
      holderName: "Me",
      balance: 20000,
      assetId: asset.id,
    );

    expect(unitOfWork.executions, 1);
    expect(journals.saved, [journal]);
    expect(journal.name, "Wallet");
    expect(journal.holderName, "Me");
    expect(journal.balance, 20000);
    expect(journal.assetId, asset.id);
    expect(journal.asset, asset);

    final event = events.ofType<JournalCreated>().single;
    expect(event.journalId, journal.id);
    expect(event.snapshot.balance, 20000);
    expect(event.snapshot.assetId, asset.id);
  });

  test("fails without saving when the asset is missing", () async {
    await expectLater(
      useCase.execute(
        name: "Wallet",
        holderName: "Me",
        balance: 0,
        assetId: "missing",
      ),
      throwsException,
    );

    expect(journals.saved, isEmpty);
    expect(events.raised, isEmpty);
  });
}
