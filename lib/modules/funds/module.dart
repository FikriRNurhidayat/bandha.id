import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:bandha/modules/funds/application/use_cases/create_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/deposit_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/destroy_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/destroy_fund_deposit.dart';
import 'package:bandha/modules/funds/application/use_cases/destroy_fund_withdraw.dart';
import 'package:bandha/modules/funds/application/use_cases/get_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/query_funds.dart';
import 'package:bandha/modules/funds/application/use_cases/update_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/withdraw_fund.dart';
import 'package:bandha/modules/funds/data/data_sources/fund_local_storage.dart';
import 'package:bandha/modules/funds/data/data_sources/fund_sqlite_storage.dart';
import 'package:bandha/modules/funds/data/repositories/fund_repository_impl.dart';
import 'package:bandha/modules/funds/data/services/fund_hydrator.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

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
    c.registerSingleton<CreateFund>(CreateFund.build(c));
    c.registerSingleton<UpdateFund>(UpdateFund.build(c));
    c.registerSingleton<DestroyEntity<Fund>>(DestroyFund.build(c));
    c.registerSingleton<GetEntity<Fund>>(GetFund.build(c));
    c.registerSingleton<QueryEntities<Fund>>(QueryFunds.build(c));
    c.registerSingleton<DepositFund>(DepositFund.build(c));
    c.registerSingleton<WithdrawFund>(WithdrawFund.build(c));
    c.registerSingleton<DestroyFundDeposit>(DestroyFundDeposit.build(c));
    c.registerSingleton<DestroyFundWithdraw>(DestroyFundWithdraw.build(c));

    c.registerFactory<AsyncListViewModel<Fund>>(AsyncListViewModel<Fund>.build);
  }
}
