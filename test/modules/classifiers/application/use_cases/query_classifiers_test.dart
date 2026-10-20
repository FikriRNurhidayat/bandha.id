import 'package:bandha/modules/classifiers/application/use_cases/query_classifiers.dart';
import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';

void main() {
  group("QueryClassifiers", () {
    test("forwards the query and returns hits", () async {
      final alice = makeParty(id: "p1", name: "Alice");
      final repository = FakeClassifierRepository<Party>(
        seed: [
          alice,
          makeParty(id: "p2", name: "Bob"),
        ],
      );
      final useCase = QueryClassifiers<Party>(classifierRepository: repository);

      final result = await useCase.execute(
        filter: {
          "id_in": ["p1"],
        },
        size: 5,
      );

      expect(result.toList(), [alice]);
      expect(repository.lastQuery!.size, 5);
      expect(repository.lastQuery!.filter, {
        "id_in": ["p1"],
      });
      expect(useCase.repository, same(repository));
    });

    test("defaults to an empty filter and size 25", () async {
      final repository = FakeClassifierRepository<Party>(seed: [makeParty()]);

      final result = await QueryClassifiers<Party>(
        classifierRepository: repository,
      ).execute();

      expect(result.length, 1);
      expect(repository.lastQuery!.filter, isEmpty);
      expect(repository.lastQuery!.size, 25);
    });
  });
}
