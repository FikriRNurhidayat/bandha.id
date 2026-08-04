import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';

class EntryCreated extends DomainEvent {
  final String entryId;
  final EntrySnapshot snapshot;
  final bool skip;

  EntryCreated({
    required this.entryId,
    required this.snapshot,
    this.skip = false,
  });

  factory EntryCreated.fromEntry(Entry entry) {
    return EntryCreated(
      entryId: entry.id,
      snapshot: EntrySnapshot.fromEntry(entry),
    );
  }
}
