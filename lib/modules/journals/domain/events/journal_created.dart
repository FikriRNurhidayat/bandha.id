import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/value_objects/journal_snapshot.dart';

class JournalCreated extends DomainEvent {
  final String journalId;
  final JournalSnapshot snapshot;

  JournalCreated({required this.journalId, required this.snapshot});

  factory JournalCreated.fromJournal(Journal journal) {
    return JournalCreated(
      journalId: journal.id,
      snapshot: JournalSnapshot.fromJournal(journal),
    );
  }
}
