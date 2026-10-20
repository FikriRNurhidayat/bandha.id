import 'package:bandha/modules/classifiers/application/use_cases/get_classifier.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  group("GetClassifier", () {
    test("returns the classifier by id", () async {
      final category = makeCategory(id: "c1");
      final repository = FakeClassifierRepository<Category>(seed: [category]);
      final useCase = GetClassifier<Category>(classifierRepository: repository);

      expect(await useCase.execute("c1"), same(category));
      expect(useCase.repository, same(repository));
    });

    test("propagates not found errors", () async {
      final useCase = GetClassifier<Category>(
        classifierRepository: FakeClassifierRepository<Category>(),
      );

      await expectLater(useCase.execute("missing"), throwsException);
    });
  });
}
