import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class WithdrawFundParams {
  final String fundId;
  final double amount;
  final String? note;

  WithdrawFundParams(this.fundId, {required this.note, required this.amount});
}

class WithdrawFund extends UseCase<WithdrawFundParams, Entry> {
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

  factory WithdrawFund.fromContainer(DependencyContainer c) {
    return WithdrawFund(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
      journalReader: c.get<JournalReader>(),
      entryWriter: c.get<EntryWriter>(),
    );
  }

  @override
  Future<Entry> execute(WithdrawFundParams params) {
    return unitOfWork.execute(() async {
      final fund = await fundRepository.get(params.fundId);
      final label = await labelReader.get(SystemLabels.withdraw);

      await fundRepository.save(fund.withdraw(params.amount));

      final entry = await entryWriter.create(
        entryWriter
            .readOnly(
              journalId: fund.journalId,
              amount: params.amount.abs(),
              issuedAt: DateTime.now(),
              note: params.note,
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
