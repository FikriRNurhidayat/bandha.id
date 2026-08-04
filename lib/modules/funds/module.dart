import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
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
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class FundModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<FundSqliteStorage>(FundSqliteStorage.fromContainer(c));
    c.registerSingleton<FundLocalStorage>(c.get<FundSqliteStorage>());
    c.registerSingleton<FundHydrator>(FundHydrator.fromContainer(c));
    c.registerSingleton<FundRepositoryImpl>(
      FundRepositoryImpl.fromContainer(c),
    );
    c.registerSingleton<FundRepository>(c.get<FundRepositoryImpl>());
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateFund>(CreateFund.fromContainer(c));
    c.registerSingleton<UpdateFund>(UpdateFund.fromContainer(c));
    c.registerSingleton<DestroyFund>(DestroyFund.fromContainer(c));
    c.registerSingleton<GetFund>(GetFund.fromContainer(c));
    c.registerSingleton<QueryFunds>(QueryFunds.fromContainer(c));
    c.registerSingleton<DepositFund>(DepositFund.fromContainer(c));
    c.registerSingleton<WithdrawFund>(WithdrawFund.fromContainer(c));
    c.registerSingleton<DestroyFundDeposit>(
      DestroyFundDeposit.fromContainer(c),
    );
    c.registerSingleton<DestroyFundWithdraw>(
      DestroyFundWithdraw.fromContainer(c),
    );
  }
}
