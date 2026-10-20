import 'package:bandha/modules/transfers/application/use_cases/get_transfer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/transfers_fakes.dart';

void main() {
  group("GetTransfer", () {
    test("returns the transfer by id", () async {
      final transfer = makeTransfer(id: "t1");
      final repository = FakeTransferRepository(seed: [transfer]);
      final useCase = GetTransfer(transferRepository: repository);

      expect(useCase.repository, same(repository));
      expect(await useCase.execute("t1"), same(transfer));
    });

    test("propagates a missing transfer error", () async {
      final useCase = GetTransfer(transferRepository: FakeTransferRepository());
      await expectLater(useCase.execute("missing"), throwsException);
    });
  });
}
