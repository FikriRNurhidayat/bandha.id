import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class CreateFundParams {
  final String? note;
  final double amount;
  final String categoryId;
  final String journalId;
  final Iterable<String> labelIds;

  CreateFundParams({
    required this.note,
    required this.amount,
    required this.categoryId,
    required this.journalId,
    this.labelIds = const [],
  });
}

class CreateFund extends UseCase<CreateFundParams, Fund> {
  final FundRepository fundRepository;
  final UnitOfWork unitOfWork;
  final CategoryReader categoryReader;
  final LabelReader labelReader;
  final JournalReader journalReader;

  CreateFund({
    required this.fundRepository,
    required this.unitOfWork,
    required this.categoryReader,
    required this.labelReader,
    required this.journalReader,
  });

  factory CreateFund.fromContainer(DependencyContainer c) {
    return CreateFund(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
      journalReader: c.get<JournalReader>(),
    );
  }

  @override
  Future<Fund> execute(CreateFundParams params) {
    return unitOfWork.execute(() async {
      final category = await categoryReader.get(params.categoryId);
      final labels = await labelReader.getAll(params.labelIds);
      final journal = await journalReader.get(params.journalId);

      final fund = Fund.create(
        note: params.note,
        amount: params.amount,
        categoryId: category.id,
        journalId: params.journalId,
      ).withJournal(journal).withCategory(category).withLabels(labels);

      await fundRepository.save(fund);

      return fund;
    });
  }
}
