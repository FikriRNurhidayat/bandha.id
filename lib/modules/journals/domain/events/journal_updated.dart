import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/value_objects/journal_snapshot.dart';

class JournalUpdated extends DomainEvent {
  final String journalId;
  final JournalSnapshot before;
  final JournalSnapshot after;

  JournalUpdated({
    required this.journalId,
    required this.before,
    required this.after,
  });

  bool get balanceChanged => before.balance != after.balance;
  double get deltaAmount => after.balance - before.balance;

  factory JournalUpdated.of(Journal before, Journal after) {
    return JournalUpdated(
      journalId: before.id,
      before: JournalSnapshot.fromJournal(before),
      after: JournalSnapshot.fromJournal(after),
    );
  }
}
