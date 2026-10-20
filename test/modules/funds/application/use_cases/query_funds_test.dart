import 'package:bandha/modules/funds/application/use_cases/query_funds.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/funds_fakes.dart';

void main() {
  group("QueryFunds", () {
    final active = makeFund(id: "f1");
    final released = makeFund(id: "f2", status: FundStatus.released);
    late FakeFundRepository repository;
    late QueryFunds useCase;

    setUp(() {
      repository = FakeFundRepository(seed: [active, released]);
      useCase = QueryFunds(fundRepository: repository);
    });

    test("exposes the fund repository", () {
      expect(useCase.repository, same(repository));
    });

    test("forwards filter and size to the repository", () async {
      final result = await useCase.execute(filter: {"id_eq": "f2"}, size: 5);

      expect(result.toList(), [released]);
      expect(repository.lastQuery!.filter, {"id_eq": "f2"});
      expect(repository.lastQuery!.size, 5);
    });

    test("defaults to an empty filter and size 25", () async {
      final result = await useCase.execute();

      expect(result.toList(), unorderedEquals([active, released]));
      expect(repository.lastQuery!.filter, isEmpty);
      expect(repository.lastQuery!.size, 25);
      expect(repository.lastQuery!.cursor, isNull);
    });
  });
}
