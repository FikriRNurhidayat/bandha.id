import 'package:bandha/modules/journals/application/use_cases/query_journals.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  test("forwards the query to the repository", () async {
    final a = makeJournal();
    final b = makeJournal();
    final repository = FakeJournalRepository(seed: [a, b]);

    final result = await QueryJournals(journalRepository: repository).execute(
      filter: {
        "id_in": [a.id],
      },
      size: 5,
    );

    expect(result.toList(), [a]);
    expect(repository.lastQuery?.filter, {
      "id_in": [a.id],
    });
    expect(repository.lastQuery?.size, 5);
  });
}
