import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class SweepFund {
  final FundRepository fundRepository;
  final EntryWriter entryWriter;
  final UnitOfWork unitOfWork;
  final CategoryReader categoryReader;
  final LabelReader labelReader;
  final JournalReader journalReader;

  SweepFund({
    required this.fundRepository,
    required this.unitOfWork,
    required this.categoryReader,
    required this.labelReader,
    required this.journalReader,
    required this.entryWriter,
  });

  factory SweepFund.build(DependencyContainer c) {
    return SweepFund(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
      journalReader: c.get<JournalReader>(),
      entryWriter: c.get<EntryWriter>(),
    );
  }

  Future<Fund> execute(String fundId) {
    return unitOfWork.execute(() async {
      final fund = await fundRepository.get(fundId);
      final label = await labelReader.get(SystemLabels.releasedId);

      await entryWriter.create(
        entryWriter
            .readOnly(
              categoryId: fund.categoryId,
              journalId: fund.journalId,
              amount: fund.balance,
              issuedAt: DateTime.now(),
            )
            .of(fund)
            .withLabels(fund.labels.followedBy([label]))
            .withCategory(fund.category)
            .withJournal(fund.journal),
      );

      final newFund = fund.copyWith(
        status: FundStatus.released,
        releasedAt: DateTime.now(),
      );

      await fundRepository.save(newFund);

      return newFund;
    });
  }
}
