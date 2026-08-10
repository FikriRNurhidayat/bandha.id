import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class CreateFund {
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

  factory CreateFund.build(DependencyContainer c) {
    return CreateFund(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
      journalReader: c.get<JournalReader>(),
    );
  }

  Future<Fund> execute({
    required String? note,
    required double amount,
    required String categoryId,
    required String journalId,
    Iterable<String> labelIds = const [],
  }) {
    return unitOfWork.execute(() async {
      final category = await categoryReader.get(categoryId);
      final labels = await labelReader.getAll(labelIds);
      final journal = await journalReader.get(journalId);

      final fund = Fund.create(
        note: note,
        amount: amount,
        categoryId: category.id,
        journalId: journalId,
      ).withJournal(journal).withCategory(category).withLabels(labels);

      await fundRepository.save(fund);

      return fund;
    });
  }
}
