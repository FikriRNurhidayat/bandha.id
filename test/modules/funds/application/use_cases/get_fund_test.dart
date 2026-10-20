import 'package:bandha/modules/funds/application/use_cases/get_fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/funds_fakes.dart';

void main() {
  group("GetFund", () {
    final fund = makeFund(id: "f1");
    final repository = FakeFundRepository(seed: [fund]);
    final useCase = GetFund(fundRepository: repository);

    test("exposes the fund repository", () {
      expect(useCase.repository, same(repository));
    });

    test("returns the fund by id", () async {
      expect(await useCase.execute("f1"), same(fund));
    });

    test("propagates missing fund errors", () {
      expect(useCase.execute("missing"), throwsException);
    });
  });
}
