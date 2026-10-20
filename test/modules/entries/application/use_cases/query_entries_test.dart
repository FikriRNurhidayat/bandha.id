import 'package:bandha/modules/entries/application/use_cases/query_entries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  test("forwards filter and size to the repository", () async {
    final a = makeEntry();
    final b = makeEntry();
    final repository = FakeEntryRepository(seed: [a, b]);

    final result = await QueryEntries(
      entryRepository: repository,
    ).execute(filter: {"id_eq": b.id}, size: 10);

    expect(result.toList(), [b]);
    expect(repository.lastQuery?.filter, {"id_eq": b.id});
    expect(repository.lastQuery?.size, 10);
  });

  test("uses default query values", () async {
    final repository = FakeEntryRepository(seed: [makeEntry()]);

    final result = await QueryEntries(entryRepository: repository).execute();

    expect(result.length, 1);
    expect(repository.lastQuery?.filter, isEmpty);
    expect(repository.lastQuery?.size, 25);
    expect(repository.lastQuery?.cursor, isNull);
  });
}
