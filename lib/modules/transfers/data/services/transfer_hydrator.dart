import 'package:bandha/core/data/services/hydrator.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/entries/domain/ports/entry_reader.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';

class TransferHydrator implements Hydrator<Transfer> {
  final EntryReader entryReader;

  TransferHydrator({required this.entryReader});

  factory TransferHydrator.build(DependencyContainer c) {
    return TransferHydrator(entryReader: c.get<EntryReader>());
  }

  @override
  Future<Transfer> hydrate(Transfer transfer) async {
    final transfers = await hydrateAll([transfer]);
    return transfers.first;
  }

  @override
  Future<Iterable<Transfer>> hydrateAll(Iterable<Transfer> transfers) async {
    final entryIds = transfers.expand((transfer) => transfer.entryIds);
    final entries = await entryReader.getAll(entryIds);
    final entriesMapping = {for (final entry in entries) entry.id: entry};

    return transfers.map((transfer) {
      final debit = entriesMapping[transfer.debitId]!;
      final debitFee = entriesMapping[transfer.debitFeeId];
      final credit = entriesMapping[transfer.creditId]!;
      final creditFee = entriesMapping[transfer.creditFeeId];

      return transfer
          .withCredit(credit)
          .withDebit(debit)
          .withDebitFee(debitFee)
          .withCreditFee(creditFee);
    });
  }
}
