import 'package:bandha/modules/journals/application/use_cases/destroy_journal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  test("destroys the journal by id", () async {
    final journal = makeJournal();
    final journals = FakeJournalRepository(seed: [journal]);

    await DestroyJournal(journals).execute(journal.id);

    expect(journals.destroyed, [journal]);
    expect(journals.store, isEmpty);
  });

  test("fails for a missing journal", () async {
    final journals = FakeJournalRepository();

    await expectLater(DestroyJournal(journals).execute("x"), throwsException);
    expect(journals.destroyed, isEmpty);
  });
}
