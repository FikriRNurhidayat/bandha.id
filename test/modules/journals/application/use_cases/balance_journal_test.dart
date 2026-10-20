import 'package:bandha/modules/journals/application/use_cases/balance_journal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';

void main() {
  test("delegates to the repository", () async {
    final journals = FakeJournalRepository();

    await BalanceJournal(journalRepository: journals).execute("j1");

    expect(journals.balanced, ["j1"]);
  });
}
