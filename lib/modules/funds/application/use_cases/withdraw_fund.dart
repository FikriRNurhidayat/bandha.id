import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class WithdrawFund {
  final FundRepository fundRepository;
  final EntryWriter entryWriter;
  final UnitOfWork unitOfWork;
  final CategoryReader categoryReader;
  final LabelReader labelReader;
  final JournalReader journalReader;

  WithdrawFund({
    required this.fundRepository,
    required this.unitOfWork,
    required this.categoryReader,
    required this.labelReader,
    required this.journalReader,
    required this.entryWriter,
  });

  factory WithdrawFund.build(DependencyContainer c) {
    return WithdrawFund(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
      journalReader: c.get<JournalReader>(),
      entryWriter: c.get<EntryWriter>(),
    );
  }

  Future<Entry> execute(String fundId, {required String? note, required double amount}) {
    return unitOfWork.execute(() async {
      final fund = await fundRepository.get(fundId);
      final label = await labelReader.get(SystemLabels.withdraw);

      await fundRepository.save(fund.withdraw(amount));

      final entry = await entryWriter.create(
        entryWriter
            .readOnly(
              journalId: fund.journalId,
              amount: amount.abs(),
              issuedAt: DateTime.now(),
              note: note,
            )
            .of(fund)
            .withLabels(fund.labels.followedBy([label]))
            .withCategory(fund.category)
            .withJournal(fund.journal),
      );

      return entry;
    });
  }
}
