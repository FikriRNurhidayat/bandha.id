import 'package:bandha/modules/journals/application/use_cases/get_journal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  test("returns the journal by id", () async {
    final journal = makeJournal();
    final useCase = GetJournal(
      journalRepository: FakeJournalRepository(seed: [journal]),
    );

    expect(await useCase.execute(journal.id), journal);
  });

  test("propagates repository errors", () async {
    final useCase = GetJournal(journalRepository: FakeJournalRepository());
    await expectLater(useCase.execute("missing"), throwsException);
  });
}
