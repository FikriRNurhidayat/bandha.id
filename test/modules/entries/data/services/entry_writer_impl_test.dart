import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/modules/entries/data/services/entry_writer_impl.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeEntryRepository entries;
  late RecordingEventPublisher events;
  late EntryWriterImpl writer;

  setUp(() {
    entries = FakeEntryRepository();
    events = RecordingEventPublisher();
    writer = EntryWriterImpl(entryRepository: entries, eventPublisher: events);
  });

  test("readOnly builds an uncontrolled, done, read-only entry", () {
    final entry = writer.readOnly(
      journalId: "j",
      categoryId: "c",
      amount: 10,
      issuedAt: fixedTime,
      note: "Transfer",
    );

    expect(entry.readOnly, isTrue);
    expect(entry.status, EntryStatus.done);
    expect(entry.controller, isNull);
    expect(entry.journalId, "j");
    expect(entry.categoryId, "c");
    expect(entry.amount, 10);
    expect(entry.issuedAt, fixedTime);
    expect(entry.note, "Transfer");
    expect(entries.saved, isEmpty);
  });

  test("create saves and raises EntryCreated", () async {
    final entry = makeEntry(amount: 5);

    expect(await writer.create(entry), entry);
    expect(entries.saved, [entry]);
    final event = events.ofType<EntryCreated>().single;
    expect(event.entryId, entry.id);
    expect(event.snapshot.amount, 5);
    expect(event.skip, isFalse);
  });

  test("createAll raises one event per entry", () async {
    final a = makeEntry();
    final b = makeEntry();

    await writer.createAll([a, b]);

    expect(entries.saved, [a, b]);
    expect(events.ofType<EntryCreated>().map((e) => e.entryId), [a.id, b.id]);
  });

  test("update saves the after state and raises EntryUpdated", () async {
    final before = makeEntry(amount: 1);
    final after = before.copyWith(amount: 2);

    expect(await writer.update(DataChange(before, after)), after);
    expect(entries.saved, [after]);
    final event = events.ofType<EntryUpdated>().single;
    expect(event.entryId, before.id);
    expect(event.before.amount, 1);
    expect(event.after.amount, 2);
  });

  test("destroy removes and raises EntryDestroyed", () async {
    final entry = makeEntry();
    entries.store[entry.id] = entry;

    await writer.destroy(entry);

    expect(entries.destroyed, [entry]);
    expect(events.ofType<EntryDestroyed>().single.entryId, entry.id);
  });

  test("plan returns an empty change set", () {
    expect(writer.plan().isEmpty, isTrue);
  });

  test("execute applies creates, updates and destroys", () async {
    final created = makeEntry();
    final before = makeEntry(amount: 1);
    final gone = makeEntry();
    entries.store[before.id] = before;
    entries.store[gone.id] = gone;

    final plan = writer.plan();
    plan.create(created);
    final after = plan.update(before, before.copyWith(amount: 9));
    plan.destroy(gone);

    await writer.execute(plan);

    expect(entries.saved, [created, after]);
    expect(entries.destroyed, [gone]);
    expect(events.ofType<EntryCreated>().single.entryId, created.id);
    expect(events.ofType<EntryUpdated>().single.after.amount, 9);
    expect(events.ofType<EntryDestroyed>().single.entryId, gone.id);
  });

  test("execute with an empty plan does nothing", () async {
    await writer.execute(writer.plan());

    expect(entries.saved, isEmpty);
    expect(entries.destroyed, isEmpty);
    expect(events.raised, isEmpty);
  });
}
