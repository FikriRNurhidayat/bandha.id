import 'package:bandha/modules/funds/application/use_cases/destroy_fund.dart';
import 'package:bandha/modules/funds/domain/events/fund_destroyed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';
import '../../../../support/funds_fakes.dart';

void main() {
  group("DestroyFund", () {
    late FakeFundRepository repository;
    late FakeUnitOfWork unitOfWork;
    late RecordingEventPublisher publisher;
    late DestroyFund useCase;
    final fund = makeFund(
      id: "f1",
      journal: makeJournal(id: "j1"),
    );

    setUp(() {
      repository = FakeFundRepository(seed: [fund]);
      unitOfWork = FakeUnitOfWork();
      publisher = RecordingEventPublisher();
      useCase = DestroyFund(
        repository,
        unitOfWork: unitOfWork,
        eventPublisher: publisher,
      );
    });

    test("destroys the fund and raises FundDestroyed", () async {
      await useCase.execute("f1");

      expect(unitOfWork.executions, 1);
      expect(repository.destroyed, [fund]);
      expect(repository.store, isEmpty);

      final events = publisher.ofType<FundDestroyed>().toList();
      expect(events, hasLength(1));
      expect(events.single.fundId, "f1");
      expect(events.single.snapshot.journalId, "j1");
      expect(events.single.controller.type, "Fund");
    });

    test("raises nothing when the fund is missing", () async {
      await expectLater(useCase.execute("missing"), throwsException);
      expect(repository.destroyed, isEmpty);
      expect(publisher.raised, isEmpty);
    });
  });
}
