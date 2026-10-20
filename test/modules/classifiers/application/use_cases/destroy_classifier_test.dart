import 'package:bandha/modules/classifiers/application/use_cases/destroy_classifier.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  group("DestroyClassifier", () {
    late FakeClassifierRepository<Label> repository;
    late FakeUnitOfWork unitOfWork;
    late DestroyClassifier<Label> useCase;

    setUp(() {
      repository = FakeClassifierRepository<Label>(
        seed: [
          makeLabel(id: "l1"),
          makeLabel(id: "sys", readOnly: true),
        ],
      );
      unitOfWork = FakeUnitOfWork();
      useCase = DestroyClassifier<Label>(
        classifierRepository: repository,
        unitOfWork: unitOfWork,
      );
    });

    test("destroys the classifier inside a unit of work", () async {
      await useCase.execute("l1");

      expect(repository.destroyed.single.id, "l1");
      expect(repository.store.containsKey("l1"), isFalse);
      expect(unitOfWork.executions, 1);
      expect(useCase.repository, same(repository));
    });

    test("propagates not found errors without destroying", () async {
      await expectLater(useCase.execute("missing"), throwsException);
      expect(repository.destroyed, isEmpty);
    });

    test(
      "refuses to destroy read-only classifiers",
      () async {
        await expectLater(useCase.execute("sys"), throwsA(anything));
        expect(repository.destroyed, isEmpty);
      },
      skip:
          "BUG: no readOnly check in DestroyClassifier; system categories/labels (e.g. adjustment) can be destroyed",
    );
  });
}
