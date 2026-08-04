import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/modules/transfers/application/use_cases/create_transfer.dart';
import 'package:bandha/modules/transfers/application/use_cases/destroy_transfer.dart';
import 'package:bandha/modules/transfers/application/use_cases/get_transfer.dart';
import 'package:bandha/modules/transfers/application/use_cases/query_transfers.dart';
import 'package:bandha/modules/transfers/application/use_cases/update_transfer.dart';
import 'package:bandha/modules/transfers/data/data_sources/transfer_local_storage.dart';
import 'package:bandha/modules/transfers/data/data_sources/transfer_sqlite_storage.dart';
import 'package:bandha/modules/transfers/data/repositories/transfer_repository_impl.dart';
import 'package:bandha/modules/transfers/data/services/transfer_hydrator.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class TransferModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<TransferSqliteStorage>(
      TransferSqliteStorage.fromContainer(c),
    );
    c.registerSingleton<TransferLocalStorage>(c.get<TransferSqliteStorage>());
    c.registerSingleton<TransferHydrator>(TransferHydrator.fromContainer(c));
    c.registerSingleton<TransferRepositoryImpl>(
      TransferRepositoryImpl.fromContainer(c),
    );
    c.registerSingleton<TransferRepository>(c.get<TransferRepositoryImpl>());
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateTransfer>(CreateTransfer.fromContainer(c));
    c.registerSingleton<UpdateTransfer>(UpdateTransfer.fromContainer(c));
    c.registerSingleton<GetTransfer>(GetTransfer.fromContainer(c));
    c.registerSingleton<DestroyTransfer>(DestroyTransfer.fromContainer(c));
    c.registerSingleton<QueryTransfers>(QueryTransfers.fromContainer(c));
  }
}
