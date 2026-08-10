import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:bandha/modules/transfers/application/use_cases/create_transfer.dart';
import 'package:bandha/modules/transfers/application/use_cases/destroy_transfer.dart';
import 'package:bandha/modules/transfers/application/use_cases/get_transfer.dart';
import 'package:bandha/modules/transfers/application/use_cases/query_transfers.dart';
import 'package:bandha/modules/transfers/application/use_cases/update_transfer.dart';
import 'package:bandha/modules/transfers/data/data_sources/transfer_local_storage.dart';
import 'package:bandha/modules/transfers/data/data_sources/transfer_sqlite_storage.dart';
import 'package:bandha/modules/transfers/data/repositories/transfer_repository_impl.dart';
import 'package:bandha/modules/transfers/data/services/transfer_hydrator.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class TransferModule extends Module {
  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateTransfer>(CreateTransfer.build(c));
    c.registerSingleton<UpdateTransfer>(UpdateTransfer.build(c));
    c.registerSingleton<GetEntity<Transfer>>(GetTransfer.build(c));
    c.registerSingleton<DestroyEntity<Transfer>>(DestroyTransfer.build(c));
    c.registerSingleton<QueryEntities<Transfer>>(QueryTransfers.build(c));
    c.registerFactory<AsyncListViewModel<Transfer>>(
      AsyncListViewModel<Transfer>.build,
    );
  }

  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<TransferSqliteStorage>(TransferSqliteStorage.build(c));
    c.registerSingleton<TransferLocalStorage>(c.get<TransferSqliteStorage>());
    c.registerSingleton<TransferHydrator>(TransferHydrator.build(c));
    c.registerSingleton<TransferRepositoryImpl>(
      TransferRepositoryImpl.build(c),
    );
    c.registerSingleton<TransferRepository>(c.get<TransferRepositoryImpl>());
  }
}
