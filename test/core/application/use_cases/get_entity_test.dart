import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/core_helpers.dart';
import '../../../support/fakes.dart';

void main() {
  group("GetEntity", () {
    test("returns the entity from the repository", () async {
      final thing = Thing("a");
      final useCase = GetEntity(InMemoryRepository<Thing>(seed: [thing]));
      expect(await useCase.execute("a"), same(thing));
    });

    test("propagates repository errors", () async {
      final useCase = GetEntity(InMemoryRepository<Thing>());
      await expectLater(useCase.execute("missing"), throwsException);
    });
  });
}
