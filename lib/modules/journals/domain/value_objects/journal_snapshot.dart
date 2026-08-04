import 'package:bandha/modules/journals/domain/entities/journal.dart';

class JournalSnapshot {
  final String name;
  final String holderName;
  final double balance;
  final String assetId;

  JournalSnapshot({
    required this.name,
    required this.holderName,
    required this.balance,
    required this.assetId,
  });

  factory JournalSnapshot.fromJournal(Journal journal) {
    return JournalSnapshot(
      name: journal.name,
      holderName: journal.holderName,
      balance: journal.balance,
      assetId: journal.assetId,
    );
  }
}
