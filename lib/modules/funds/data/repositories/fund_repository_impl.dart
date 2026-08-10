import 'package:bandha/core/data/repository_impl.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/funds/data/data_sources/fund_local_storage.dart';
import 'package:bandha/modules/funds/data/services/fund_hydrator.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class FundRepositoryImpl extends HydratedRepositoryImpl<Fund>
    implements FundRepository {
  @override
  final FundHydrator hydrator;

  @override
  final FundLocalStorage localStorage;

  FundRepositoryImpl({required this.hydrator, required this.localStorage});

  factory FundRepositoryImpl.build(DependencyContainer c) {
    return FundRepositoryImpl(
      hydrator: c.get<FundHydrator>(),
      localStorage: c.get<FundLocalStorage>(),
    );
  }
}
