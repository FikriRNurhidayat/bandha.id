import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class QueryTransfers extends QueryEntities<Transfer> {
  final TransferRepository transferRepository;

  QueryTransfers({required this.transferRepository})
    : super(transferRepository);

  @override
  Repository<Transfer> get repository => transferRepository;

  factory QueryTransfers.build(DependencyContainer c) {
    return QueryTransfers(
      transferRepository: c.get<TransferRepository>(),
    );
  }
}
