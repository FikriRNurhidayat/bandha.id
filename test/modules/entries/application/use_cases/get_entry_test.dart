import 'package:bandha/modules/entries/application/use_cases/get_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  test("returns the entry by id", () async {
    final entry = makeEntry();
    final useCase = GetEntry(
      entryRepository: FakeEntryRepository(seed: [entry]),
    );

    expect(await useCase.execute(entry.id), entry);
  });

  test("propagates repository errors", () async {
    final useCase = GetEntry(entryRepository: FakeEntryRepository());
    await expectLater(useCase.execute("missing"), throwsException);
  });
}
