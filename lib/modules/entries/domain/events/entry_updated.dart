import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';

class EntryUpdated extends DomainEvent {
  final String entryId;
  final EntrySnapshot before;
  final EntrySnapshot after;

  EntryUpdated({
    required this.entryId,
    required this.before,
    required this.after,
  });

  bool get journalChanged => before.journalId != after.journalId;
  bool get assetChanged => before.assetId != after.assetId;
  bool get amountChanged => before.amount != after.amount;
  bool get hasBalanceImpact => journalChanged || assetChanged || amountChanged;

  factory EntryUpdated.of(Entry before, Entry after) {
    return EntryUpdated(
      entryId: before.id,
      before: EntrySnapshot.fromEntry(before),
      after: EntrySnapshot.fromEntry(after),
    );
  }
}
