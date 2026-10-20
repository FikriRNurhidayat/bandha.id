import 'package:bandha/modules/funds/domain/value_objects/fund_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';
import '../../../../support/funds_fakes.dart';

void main() {
  group("FundSnapshot", () {
    test("fromFund takes the hydrated journal id", () {
      final fund = makeFund(journal: makeJournal(id: "j1"));
      expect(FundSnapshot.fromFund(fund).journalId, "j1");
    });
  });
}
