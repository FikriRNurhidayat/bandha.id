import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_editor_view_model.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_list_view_model.dart';
import 'package:bandha/modules/funds/application/use_cases/create_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/destroy_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/deposit_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/destroy_fund_transaction.dart';
import 'package:bandha/modules/funds/application/use_cases/get_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/query_funds.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/disburse_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/sweep_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/withdraw_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/update_fund.dart';
import 'package:bandha/modules/funds/data/data_sources/fund_local_storage.dart';
import 'package:bandha/modules/funds/data/data_sources/fund_sqlite_storage.dart';
import 'package:bandha/modules/funds/data/repositories/fund_repository_impl.dart';
import 'package:bandha/modules/funds/data/services/fund_hydrator.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';
import 'package:bandha/modules/funds/presentation/view_models/fund_editor_view_model.dart';
import 'package:bandha/modules/funds/presentation/view_models/fund_entry_editor_view_model.dart';
import 'package:bandha/modules/funds/presentation/view_models/fund_entry_list_view_model.dart';

class FundModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<FundSqliteStorage>(FundSqliteStorage.build(c));
    c.registerSingleton<FundLocalStorage>(c.get<FundSqliteStorage>());
    c.registerSingleton<FundHydrator>(FundHydrator.build(c));
    c.registerSingleton<FundRepositoryImpl>(FundRepositoryImpl.build(c));
    c.registerSingleton<FundRepository>(c.get<FundRepositoryImpl>());
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    // Data
    c.registerSingleton<CreateFund>(CreateFund.build(c));
    c.registerSingleton<UpdateFund>(UpdateFund.build(c));
    c.registerSingleton<DestroyEntity<Fund>>(DestroyFund.build(c));
    c.registerSingleton<GetEntity<Fund>>(GetFund.build(c));
    c.registerSingleton<QueryEntities<Fund>>(QueryFunds.build(c));

    // Transaction
    c.registerSingleton<DestroyFundTransaction>(
      DestroyFundTransaction.build(c),
    );
    c.registerSingleton<WithdrawFund>(WithdrawFund.build(c));
    c.registerSingleton<DepositFund>(DepositFund.build(c));
    c.registerSingleton<DisburseFund>(DisburseFund.build(c));
    c.registerSingleton<SweepFund>(SweepFund.build(c));

    // View Model
    c.registerFactory<AsyncListViewModel<Fund>>(AsyncListViewModel<Fund>.build);
    c.registerFactory<AsyncEditorViewModel<Fund>>(FundEditorViewModel.build);
    c.registerFactory<ControllableEntryListViewModel<Fund>>(
      FundEntryListViewModel.build,
    );
    c.registerFactory<ControllableEntryEditorViewModel<Fund>>(
      FundEntryEditorViewModel.build,
    );
  }
}
