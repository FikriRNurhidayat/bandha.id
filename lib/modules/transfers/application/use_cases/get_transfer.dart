import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class GetTransfer extends GetEntity<Transfer> {
  final TransferRepository transferRepository;

  GetTransfer({required this.transferRepository}) : super(transferRepository);

  @override
  Repository<Transfer> get repository => transferRepository;

  factory GetTransfer.fromContainer(DependencyContainer c) {
    return GetTransfer(transferRepository: c.get<TransferRepository>());
  }
}
