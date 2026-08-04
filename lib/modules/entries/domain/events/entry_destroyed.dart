import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';

class EntryDestroyed extends DomainEvent {
  final String entryId;
  final EntrySnapshot snapshot;

  EntryDestroyed({required this.entryId, required this.snapshot});

  factory EntryDestroyed.fromEntry(Entry entry) {
    return EntryDestroyed(
      entryId: entry.id,
      snapshot: EntrySnapshot.fromEntry(entry),
    );
  }
}
