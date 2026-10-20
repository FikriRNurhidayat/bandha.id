import 'package:bandha/modules/classifiers/application/use_cases/create_classifier.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';

void main() {
  group("CreateClassifier", () {
    test("creates a category through the factory and saves it", () async {
      final repository = FakeClassifierRepository<Category>();
      final useCase = CreateClassifier<Category>(
        repository: repository,
        factory: Category.create,
      );

      final category = await useCase.execute(name: "Food");

      expect(category.name, "Food");
      expect(category.readOnly, isFalse);
      expect(repository.saved, [category]);
    });

    test("works for labels and parties", () async {
      final labels = FakeClassifierRepository<Label>();
      final parties = FakeClassifierRepository<Party>();

      final label = await CreateClassifier<Label>(
        repository: labels,
        factory: Label.create,
      ).execute(name: "Trip");
      final party = await CreateClassifier<Party>(
        repository: parties,
        factory: Party.create,
      ).execute(name: "Alice");

      expect(labels.store[label.id]!.name, "Trip");
      expect(parties.store[party.id]!.name, "Alice");
    });
  });
}
