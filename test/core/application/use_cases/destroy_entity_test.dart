import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/core_helpers.dart';
import '../../../support/fakes.dart';

void main() {
  group("DestroyEntity", () {
    test("loads then destroys the entity", () async {
      final thing = Thing("a");
      final repo = InMemoryRepository<Thing>(seed: [thing, Thing("b")]);
      await DestroyEntity(repo).execute("a");
      expect(repo.destroyed, [thing]);
      expect(repo.store.keys, ["b"]);
    });

    test("throws and destroys nothing when missing", () async {
      final repo = InMemoryRepository<Thing>(seed: [Thing("b")]);
      await expectLater(DestroyEntity(repo).execute("a"), throwsException);
      expect(repo.destroyed, isEmpty);
    });
  });
}
