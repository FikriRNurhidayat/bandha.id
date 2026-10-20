import 'package:bandha/modules/tools/application/use_cases/backup_ledger.dart';
import 'package:bandha/modules/tools/domain/exceptions/invalid_database_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';

void main() {
  group("BackupLedger", () {
    late FakeSqliteDatabaseManager databaseManager;
    late FakeFilePicker filePicker;
    late BackupLedger useCase;

    setUp(() {
      databaseManager = FakeSqliteDatabaseManager();
      filePicker = FakeFilePicker(savedPath: "/sdcard/backup.db");
      useCase = BackupLedger(
        databaseManager: databaseManager,
        filePicker: filePicker,
      );
    });

    test("snapshots the database and saves it via the file picker", () async {
      final output = await useCase.execute();

      expect(output, "/sdcard/backup.db");
      final snapshot = databaseManager.backups.single;
      expect(snapshot, matches(RegExp(r"^\d{4}-\d{2}-\d{2}-\d{2}-\d{2}\.db$")));
      expect(filePicker.saveCalls.single, {
        "filePath": "/tmp/backups/$snapshot",
        "fileName": snapshot,
        "mimeType": "application/vnd.sqlite3",
      });
    });

    test("names the snapshot after the current minute", () async {
      final before = DateTime.now();
      await useCase.execute();
      final after = DateTime.now();

      String format(DateTime t) =>
          "${t.year.toString().padLeft(4, '0')}-"
          "${t.month.toString().padLeft(2, '0')}-"
          "${t.day.toString().padLeft(2, '0')}-"
          "${t.hour.toString().padLeft(2, '0')}-"
          "${t.minute.toString().padLeft(2, '0')}.db";

      expect(
        databaseManager.backups.single,
        anyOf(format(before), format(after)),
      );
    });

    test("throws when the save dialog is cancelled", () async {
      filePicker.savedPath = null;

      await expectLater(
        useCase.execute(),
        throwsA(isA<InvalidDatabaseException>()),
      );
      expect(databaseManager.backups, hasLength(1));
    });

    test("propagates backup failures without opening the picker", () async {
      databaseManager.error = StateError("disk full");

      await expectLater(useCase.execute(), throwsStateError);
      expect(filePicker.saveCalls, isEmpty);
    });
  });
}
