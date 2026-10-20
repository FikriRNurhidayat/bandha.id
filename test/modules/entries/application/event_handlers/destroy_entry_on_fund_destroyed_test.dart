import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/modules/entries/application/event_handlers/destroy_entry_on_fund_destroyed.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/funds/domain/events/fund_destroyed.dart';
import 'package:bandha/modules/funds/domain/value_objects/fund_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  test("destroys entries controlled by the fund and raises events", () async {
    final fundController = Controller(id: "fund-1", type: "Fund");
    final a = makeEntry(controller: fundController, amount: -10);
    final b = makeEntry(controller: fundController, amount: -20);
    final other = makeEntry(
      controller: Controller(id: "fund-2", type: "Fund"),
    );
    final free = makeEntry();
    final entries = FakeEntryRepository(seed: [a, b, other, free]);
    final events = RecordingEventPublisher();

    await DestroyEntryOnFundDestroyed(
      eventPublisher: events,
      entryRepository: entries,
    ).handle(
      FundDestroyed(
        fundId: "fund-1",
        snapshot: FundSnapshot(journalId: a.journalId),
      ),
    );

    expect(entries.destroyed, unorderedEquals([a, b]));
    expect(entries.store.values, unorderedEquals([other, free]));

    final destroyed = events.ofType<EntryDestroyed>().toList();
    expect(destroyed.map((e) => e.entryId), unorderedEquals([a.id, b.id]));
    expect(
      destroyed.map((e) => e.snapshot.amount),
      unorderedEquals([-10, -20]),
    );
  });

  test("does nothing when the fund controls no entries", () async {
    final entries = FakeEntryRepository(seed: [makeEntry()]);
    final events = RecordingEventPublisher();

    await DestroyEntryOnFundDestroyed(
      eventPublisher: events,
      entryRepository: entries,
    ).handle(
      FundDestroyed(
        fundId: "fund-x",
        snapshot: FundSnapshot(journalId: "j"),
      ),
    );

    expect(entries.destroyed, isEmpty);
    expect(events.raised, isEmpty);
  });
}
