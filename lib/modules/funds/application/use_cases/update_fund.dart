import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class UpdateFund {
  final FundRepository fundRepository;
  final UnitOfWork unitOfWork;
  final CategoryReader categoryReader;
  final LabelReader labelReader;

  UpdateFund({
    required this.fundRepository,
    required this.unitOfWork,
    required this.categoryReader,
    required this.labelReader,
  });

  factory UpdateFund.build(DependencyContainer c) {
    return UpdateFund(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
    );
  }

  Future<Fund> execute(
    String id, {
    required String? note,
    required double amount,
    required String categoryId,
    Iterable<String> labelIds = const [],
  }) {
    return unitOfWork.execute(() async {
      final category = await categoryReader.get(categoryId);
      final labels = await labelReader.getAll(labelIds);
      final fund = await fundRepository.get(id);

      final change = DataChange<Fund>(
        fund,
        fund
            .copyWith(
              note: note,
              amount: amount,
              categoryId: category.id,
            )
            .withCategory(category)
            .withLabels(labels),
      );

      await fundRepository.save(change.after);

      return change.after;
    });
  }
}
