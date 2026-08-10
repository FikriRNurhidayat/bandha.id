import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class GetFund extends GetEntity<Fund> {
  final FundRepository fundRepository;

  GetFund({required this.fundRepository}) : super(fundRepository);

  @override
  Repository<Fund> get repository => fundRepository;

  factory GetFund.build(DependencyContainer c) {
    return GetFund(fundRepository: c.get<FundRepository>());
  }
}
