import 'package:bandha/modules/tools/application/use_cases/restore_ledger.dart';
import 'package:bandha/modules/tools/domain/exceptions/invalid_database_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';

void main() {
  group("RestoreLedger", () {
    late FakeSqliteDatabaseManager databaseManager;
    late FakeFilePicker filePicker;
    late RestoreLedger useCase;

    setUp(() {
      databaseManager = FakeSqliteDatabaseManager();
      filePicker = FakeFilePicker(pickedFile: "/sdcard/backup.db");
      useCase = RestoreLedger(
        databaseManager: databaseManager,
        filePicker: filePicker,
      );
    });

    test("restores the picked file", () async {
      await useCase.execute();

      expect(filePicker.getFileCalls, 1);
      expect(databaseManager.restores, ["/sdcard/backup.db"]);
    });

    test("throws and does not restore when picking is cancelled", () async {
      filePicker.pickedFile = null;

      await expectLater(
        useCase.execute(),
        throwsA(isA<InvalidDatabaseException>()),
      );
      expect(databaseManager.restores, isEmpty);
    });

    test("propagates restore failures", () async {
      databaseManager.error = StateError("corrupt");

      await expectLater(useCase.execute(), throwsStateError);
    });
  });
}
