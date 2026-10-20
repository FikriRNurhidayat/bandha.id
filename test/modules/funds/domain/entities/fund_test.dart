import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';
import '../../../../support/funds_fakes.dart';

void main() {
  group("Fund.create", () {
    test("starts active with zero balance and raised", () {
      final fund = Fund.create(
        note: "Trip",
        amount: 500,
        categoryId: "c1",
        journalId: "j1",
      );

      expect(fund.id, isNotEmpty);
      expect(fund.note, "Trip");
      expect(fund.amount, 500);
      expect(fund.balance, 0);
      expect(fund.raised, 0);
      expect(fund.status, FundStatus.active);
      expect(fund.categoryId, "c1");
      expect(fund.journalId, "j1");
      expect(fund.releasedAt, isNull);
      expect(fund.createdAt, fund.updatedAt);
    });

    test("generates unique ids", () {
      final a = Fund.create(amount: 1, categoryId: "c", journalId: "j");
      final b = Fund.create(amount: 1, categoryId: "c", journalId: "j");
      expect(a.id, isNot(b.id));
    });
  });

  group("Fund.fromRow", () {
    final row = {
      "id": "f1",
      "note": "Car",
      "amount": 1000.0,
      "balance": 250.0,
      "raised": 300.0,
      "status": "Released",
      "category_id": "c1",
      "journal_id": "j1",
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-02T00:00:00.000Z",
      "released_at": "2026-01-03T00:00:00.000Z",
    };

    test("maps every column", () {
      final fund = Fund.fromRow(row);

      expect(fund.id, "f1");
      expect(fund.note, "Car");
      expect(fund.amount, 1000);
      expect(fund.balance, 250);
      expect(fund.raised, 300);
      expect(fund.status, FundStatus.released);
      expect(fund.categoryId, "c1");
      expect(fund.journalId, "j1");
      expect(fund.createdAt, DateTime.utc(2026, 1, 1));
      expect(fund.updatedAt, DateTime.utc(2026, 1, 2));
      expect(fund.releasedAt, DateTime.utc(2026, 1, 3));
    });

    test("leaves releasedAt null when absent", () {
      final fund = Fund.fromRow({...row, "released_at": null});
      expect(fund.releasedAt, isNull);
    });

    test("tryRow returns null for null and parses otherwise", () {
      expect(Fund.tryRow(null), isNull);
      expect(Fund.tryRow(row)!.id, "f1");
    });
  });

  group("progress", () {
    test("is raised over target amount", () {
      expect(makeFund(amount: 1000, raised: 250).progress, 0.25);
      expect(makeFund(amount: 1000, raised: 1500).progress, 1.5);
    });
  });

  group("transitions", () {
    final fund = makeFund(amount: 1000, balance: 400, raised: 500);

    test("deposit adds absolute amount to balance and raised", () {
      expect(fund.deposit(100).balance, 500);
      expect(fund.deposit(100).raised, 600);
      expect(fund.deposit(-100).balance, 500);
      expect(fund.deposit(-100).raised, 600);
    });

    test("withdraw subtracts absolute amount from balance and raised", () {
      expect(fund.withdraw(100).balance, 300);
      expect(fund.withdraw(100).raised, 400);
      expect(fund.withdraw(-100).balance, 300);
      expect(fund.withdraw(-100).raised, 400);
    });

    test("disburse subtracts absolute amount from balance only", () {
      expect(fund.disburse(100).balance, 300);
      expect(fund.disburse(-100).balance, 300);
      expect(fund.disburse(100).raised, 500);
    });

    test("does not mutate the original", () {
      fund.deposit(1);
      fund.withdraw(1);
      fund.disburse(1);
      expect(fund.balance, 400);
      expect(fund.raised, 500);
    });

    test("keeps identity, target and relations", () {
      final next = fund.deposit(1);
      expect(next.id, fund.id);
      expect(next, fund);
      expect(next.amount, fund.amount);
      expect(next.createdAt, fund.createdAt);
      expect(next.journal, fund.journal);
      expect(next.category, fund.category);
      expect(next.labels, fund.labels);
    });
  });

  group("copyWith", () {
    test("overrides given fields and bumps updatedAt", () {
      final fund = makeFund(note: "A", amount: 1);
      final releasedAt = DateTime.utc(2026, 2, 1);
      final next = fund.copyWith(
        note: "B",
        amount: 2,
        balance: 3,
        raised: 4,
        status: FundStatus.released,
        categoryId: "c2",
        journalId: "j2",
        releasedAt: releasedAt,
      );

      expect(next.note, "B");
      expect(next.amount, 2);
      expect(next.balance, 3);
      expect(next.raised, 4);
      expect(next.status, FundStatus.released);
      expect(next.categoryId, "c2");
      expect(next.journalId, "j2");
      expect(next.releasedAt, releasedAt);
      expect(next.createdAt, fixedTime);
      expect(next.updatedAt.isAfter(fixedTime), isTrue);
    });

    test("keeps fields that are not given", () {
      final fund = makeFund(note: "A", balance: 5, raised: 6);
      final next = fund.copyWith();
      expect(next.note, "A");
      expect(next.balance, 5);
      expect(next.raised, 6);
      expect(next.status, FundStatus.active);
      expect(next.categoryId, fund.categoryId);
      expect(next.journalId, fund.journalId);
    });
  });

  group("relations", () {
    test("with* setters return the same instance", () {
      final fund = makeFund();
      final label = makeLabel();
      final category = makeCategory();
      final journal = makeJournal();

      expect(identical(fund.withLabels([label]), fund), isTrue);
      expect(identical(fund.withCategory(category), fund), isTrue);
      expect(identical(fund.withJournal(journal), fund), isTrue);
      expect(fund.labelIds, [label.id]);
      expect(fund.category, category);
      expect(fund.journal, journal);
    });
  });

  group("controller", () {
    test("identifies the fund by id and type", () {
      final fund = makeFund(id: "f1");
      expect(fund.controller.id, "f1");
      expect(fund.controller.type, "Fund");
      expect(fund.dataFilter, {
        "controller_id_eq": "f1",
        "controller_type_eq": "Fund",
      });
    });
  });

  group("FundStatus", () {
    test("labels and isReleased", () {
      expect(FundStatus.active.toString(), "Active");
      expect(FundStatus.released.toString(), "Released");
      expect(FundStatus.active.isReleased, isFalse);
      expect(FundStatus.released.isReleased, isTrue);
    });

    test("parse round-trips labels", () {
      for (final status in FundStatus.values) {
        expect(FundStatus.parse(status.label), status);
      }
    });

    test("parse throws on unknown value", () {
      expect(() => FundStatus.parse("Nope"), throwsStateError);
    });
  });
}
