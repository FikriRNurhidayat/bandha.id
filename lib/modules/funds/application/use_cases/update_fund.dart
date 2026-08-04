import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class UpdateFundParams {
  final String id;
  final String? note;
  final double amount;
  final String categoryId;
  final Iterable<String> labelIds;

  UpdateFundParams(
    this.id, {
    required this.note,
    required this.amount,
    required this.categoryId,
    this.labelIds = const [],
  });
}

class UpdateFund extends UseCase<UpdateFundParams, Fund> {
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

  factory UpdateFund.fromContainer(DependencyContainer c) {
    return UpdateFund(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
    );
  }

  @override
  Future<Fund> execute(UpdateFundParams params) {
    return unitOfWork.execute(() async {
      final category = await categoryReader.get(params.categoryId);
      final labels = await labelReader.getAll(params.labelIds);
      final fund = await fundRepository.get(params.id);

      final change = DataChange<Fund>(
        fund,
        fund
            .copyWith(
              note: params.note,
              amount: params.amount,
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
