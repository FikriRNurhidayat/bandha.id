import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';

class EntryWriterImpl implements EntryWriter {
  final EntryRepository entryRepository;
  final DomainEventPublisher eventPublisher;

  EntryWriterImpl({
    required this.entryRepository,
    required this.eventPublisher,
  });

  factory EntryWriterImpl.build(DependencyContainer c) {
    return EntryWriterImpl(
      entryRepository: c.get<EntryRepository>(),
      eventPublisher: c.get<DomainEventPublisher>(),
    );
  }

  @override
  Entry readOnly({
    required String journalId,
    required double amount,
    required DateTime issuedAt,
    required String categoryId,
    String? note,
  }) {
    return Entry.readonly(
      note: note,
      amount: amount,
      status: EntryStatus.done,
      controller: null,
      journalId: journalId,
      categoryId: categoryId,
      issuedAt: issuedAt,
    );
  }

  @override
  Future<Iterable<Entry>> createAll(Iterable<Entry> entries) async {
    await entryRepository.saveAll(entries);

    for (final entry in entries) {
      eventPublisher.raise(EntryCreated.fromEntry(entry));
    }

    return entries;
  }

  @override
  Future<void> destroyAll(Iterable<Entry> entries) async {
    await entryRepository.destroyAll(entries);
    eventPublisher.raiseAll(entries.map((e) => EntryDestroyed.fromEntry(e)));
  }

  @override
  Future<Iterable<Entry>> updateAll(DataChangeList<Entry> c) async {
    await entryRepository.saveAll(c.after);
    eventPublisher.raiseAll(c.map((c) => EntryUpdated.of(c.before, c.after)));
    return c.after;
  }

  @override
  Future<void> execute(DataChangeSet<Entry> c) async {
    if (c.shouldCreate) await createAll(c.createList);
    if (c.shouldUpdate) await updateAll(c.updateList);
    if (c.shouldDestroy) await destroyAll(c.destroyList);
  }

  @override
  DataChangeSet<Entry> plan() {
    return DataChangeSet<Entry>();
  }

  @override
  Future<Entry> create(Entry entry) async {
    await createAll([entry]);
    return entry;
  }

  @override
  Future<void> destroy(Entry entry) async {
    await destroyAll([entry]);
  }

  @override
  Future<Entry> update(DataChange<Entry> change) async {
    await updateAll(DataChangeList([change]));
    return change.after;
  }
}
