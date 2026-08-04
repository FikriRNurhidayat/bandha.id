import 'package:bandha/modules/entries/domain/entities/entry.dart';

class EntrySnapshot {
  final String journalId;
  final String assetId;
  final double amount;

  EntrySnapshot({
    required this.journalId,
    required this.assetId,
    required this.amount,
  });

  factory EntrySnapshot.fromEntry(Entry entry) {
    return EntrySnapshot(
      journalId: entry.journal.id,
      assetId: entry.journal.asset.id,
      amount: entry.amount,
    );
  }
}
