import 'package:bandha/modules/funds/domain/events/fund_destroyed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';
import '../../../../support/funds_fakes.dart';

void main() {
  group("FundDestroyed", () {
    test("fromFund captures id, journal snapshot and timestamp", () {
      final journal = makeJournal(id: "j1");
      final fund = makeFund(id: "f1", journal: journal);
      final before = DateTime.now();

      final event = FundDestroyed.fromFund(fund);

      expect(event.fundId, "f1");
      expect(event.snapshot.journalId, "j1");
      expect(event.occurredAt.isBefore(before), isFalse);
    });

    test("controller matches the fund's controller", () {
      final fund = makeFund(id: "f1");
      final event = FundDestroyed.fromFund(fund);

      expect(event.controller.id, fund.controller.id);
      expect(event.controller.type, fund.controller.type);
    });
  });
}
