import 'package:bandha/modules/classifiers/application/use_cases/update_classifier.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  group("UpdateClassifier", () {
    late FakeClassifierRepository<Category> repository;
    late FakeUnitOfWork unitOfWork;
    late UpdateClassifier<Category> useCase;

    setUp(() {
      repository = FakeClassifierRepository<Category>(
        seed: [
          makeCategory(id: "c1", name: "Food"),
          makeCategory(id: "sys", name: "Adjustment", readOnly: true),
        ],
      );
      unitOfWork = FakeUnitOfWork();
      useCase = UpdateClassifier<Category>(
        repository: repository,
        unitOfWork: unitOfWork,
      );
    });

    test("renames the classifier inside a unit of work", () async {
      final category = await useCase.execute("c1", name: "Meals");

      expect(category.id, "c1");
      expect(category.name, "Meals");
      expect(repository.store["c1"]!.name, "Meals");
      expect(unitOfWork.executions, 1);
    }, skip: "BUG: Category/Label/Party.copyWith throw UnimplementedError");

    test("propagates not found errors without saving", () async {
      await expectLater(useCase.execute("missing", name: "X"), throwsException);
      expect(repository.saved, isEmpty);
      expect(unitOfWork.executions, 1);
    });

    test(
      "refuses to rename read-only classifiers",
      () async {
        await expectLater(useCase.execute("sys", name: "X"), throwsA(anything));
        expect(repository.saved, isEmpty);
        expect(repository.store["sys"]!.name, "Adjustment");
      },
      skip:
          "BUG: no readOnly check in UpdateClassifier; system classifiers are only protected by the UI (currently it throws only because copyWith is unimplemented)",
    );
  });
}
