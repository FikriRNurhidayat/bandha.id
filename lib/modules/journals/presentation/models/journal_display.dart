import 'package:bandha/modules/journals/domain/entities/journal.dart';

class JournalDisplay {
  final Journal journal;

  JournalDisplay(this.journal);

  factory JournalDisplay.of(Journal journal) {
    return JournalDisplay(journal);
  }
}
