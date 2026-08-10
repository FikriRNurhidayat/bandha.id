import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class QueryFunds extends QueryEntities<Fund> {
  final FundRepository fundRepository;

  QueryFunds({required this.fundRepository}) : super(fundRepository);

  @override
  Repository<Fund> get repository => fundRepository;

  factory QueryFunds.build(DependencyContainer c) {
    return QueryFunds(fundRepository: c.get<FundRepository>());
  }
}
