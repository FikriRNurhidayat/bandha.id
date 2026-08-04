import 'package:bandha/core/data/repository_impl.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/transfers/data/data_sources/transfer_local_storage.dart';
import 'package:bandha/modules/transfers/data/services/transfer_hydrator.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl extends HydratedRepositoryImpl<Transfer>
    implements TransferRepository {
  @override
  final TransferHydrator hydrator;

  @override
  final TransferLocalStorage localStorage;

  TransferRepositoryImpl({required this.hydrator, required this.localStorage});

  factory TransferRepositoryImpl.fromContainer(DependencyContainer c) {
    return TransferRepositoryImpl(
      hydrator: c.get<TransferHydrator>(),
      localStorage: c.get<TransferLocalStorage>(),
    );
  }
}
