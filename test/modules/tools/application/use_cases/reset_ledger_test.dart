import 'package:bandha/modules/tools/application/use_cases/reset_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';

void main() {
  group("ResetLedger", () {
    test("resets the database", () async {
      final databaseManager = FakeSqliteDatabaseManager();

      await ResetLedger(databaseManager: databaseManager).execute();

      expect(databaseManager.resets, 1);
    });

    test("propagates reset failures", () async {
      final databaseManager = FakeSqliteDatabaseManager()
        ..error = StateError("locked");

      await expectLater(
        ResetLedger(databaseManager: databaseManager).execute(),
        throwsStateError,
      );
    });
  });
}
