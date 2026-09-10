import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_reader.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/funds/domain/exceptions/fund_transaction_not_voidable_exception.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class VoidFundTransaction {
  final FundRepository fundRepository;
  final EntryWriter entryWriter;
  final EntryReader entryReader;
  final LabelReader labelReader;
  final UnitOfWork unitOfWork;

  VoidFundTransaction({
    required this.fundRepository,
    required this.unitOfWork,
    required this.entryWriter,
    required this.entryReader,
    required this.labelReader,
  });

  factory VoidFundTransaction.build(DependencyContainer c) {
    return VoidFundTransaction(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      entryWriter: c.get<EntryWriter>(),
      entryReader: c.get<EntryReader>(),
      labelReader: c.get<LabelReader>(),
    );
  }

  Future<Entry> execute({
    required String fundId,
    required String entryId,
  }) async {
    return unitOfWork.execute(() async {
      final fund = await fundRepository.get(fundId);
      final entry = await entryReader.get(entryId);

      if (entry.labels.any((label) => label.id == SystemLabels.voidId)) {
        throw FundTransactionNotVoidableException(entry.id);
      }

      final latestEntry = await entryReader.whereLastControlledBy(fund);
      if (latestEntry != entry) {
        throw FundTransactionNotVoidableException(entry.id);
      }

      final voidLabel = await labelReader.get(SystemLabels.voidId);

      await fundRepository.save(
        entry.amount >= 0
            ? fund.deposit(entry.amount)
            : fund.withdraw(entry.amount),
      );

      final voidEntry = entry
          .clone(issuedAt: DateTime.now())
          .addLabel(voidLabel);
      await entryWriter.create(voidEntry);

      return voidEntry;
    });
  }
}
