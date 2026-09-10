import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_list_view_model.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/destroy_fund_transaction.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/sweep_fund.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter/material.dart';

class FundEntryListViewModel extends ControllableEntryListViewModel<Fund> {
  FundEntryListViewModel({
    required super.queryEntries,
    required super.getController,
    required this.destroyFundTransaction,
    required this.sweepFund,
  });

  final DestroyFundTransaction destroyFundTransaction;
  final SweepFund sweepFund;

  factory FundEntryListViewModel.build(DependencyContainer c) {
    return FundEntryListViewModel(
      queryEntries: c.get<QueryEntities<Entry>>(),
      getController: c.get<GetEntity<Fund>>(),
      destroyFundTransaction: c.get<DestroyFundTransaction>(),
      sweepFund: c.get<SweepFund>(),
    );
  }

  Future<void> disburse() async {
    controller = AsyncSnapshot.waiting();
    notifyListeners();

    try {
      final fund = await sweepFund.execute(controllerId);
      controller = AsyncSnapshot.withData(
        ConnectionState.done,
        Item<Fund>(fund),
      );
    } catch (error, stackTrace) {
      controller = AsyncSnapshot.withError(
        ConnectionState.done,
        error,
        stackTrace,
      );
    }

    notifyListeners();
  }

  @override
  Future<void> destroy(Item<Entry> entry) async {
    await destroyFundTransaction.execute(
      fundId: controller.requireData.entity.id,
      entryId: entry.entity.id,
    );
  }
}
