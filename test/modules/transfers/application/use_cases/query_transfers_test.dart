import 'package:bandha/modules/transfers/application/use_cases/query_transfers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/transfers_fakes.dart';

void main() {
  group("QueryTransfers", () {
    test("forwards filter and size to the repository", () async {
      final a = makeTransfer(id: "a");
      final b = makeTransfer(id: "b");
      final repository = FakeTransferRepository(seed: [a, b]);
      final useCase = QueryTransfers(transferRepository: repository);

      final result = await useCase.execute(filter: {"id_eq": "b"}, size: 5);

      expect(result.toList(), [b]);
      expect(repository.lastQuery!.filter, {"id_eq": "b"});
      expect(repository.lastQuery!.size, 5);
      expect(repository.lastQuery!.cursor, isNull);
    });

    test("defaults to an empty filter and page size 25", () async {
      final repository = FakeTransferRepository(seed: [makeTransfer()]);
      final result = await QueryTransfers(
        transferRepository: repository,
      ).execute();

      expect(result, hasLength(1));
      expect(repository.lastQuery!.filter, isEmpty);
      expect(repository.lastQuery!.size, 25);
    });
  });
}
