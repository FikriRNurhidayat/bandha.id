import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_editor_view_model.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/deposit_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/disburse_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/withdraw_fund.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/types/fund_transaction_type.dart';
import 'package:flutter/material.dart';

class FundEntryEditorViewModel extends ControllableEntryEditorViewModel<Fund> {
  FundEntryEditorViewModel({
    required super.getController,
    required super.getEntry,
    required this.depositFund,
    required this.withdrawFund,
    required this.disburseFund,
  });

  final DepositFund depositFund;
  final WithdrawFund withdrawFund;
  final DisburseFund disburseFund;

  factory FundEntryEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<FundEntryEditorViewModel>();
  }

  factory FundEntryEditorViewModel.build(DependencyContainer c) {
    return FundEntryEditorViewModel(
      getController: c.get<GetEntity<Fund>>(),
      getEntry: c.get<GetEntity<Entry>>(),
      depositFund: c.get<DepositFund>(),
      withdrawFund: c.get<WithdrawFund>(),
      disburseFund: c.get<DisburseFund>(),
    );
  }

  @override
  Future<Draft<Entry>> create() async {
    final transactionType = formData["type"].first;

    switch (transactionType) {
      case _ when transactionType.isWithdraw:
        final entry = await withdrawFund.execute(
          controllerId,
          note: formData["note"],
          amount: formData["amount"],
        );

        return Draft<Entry>(entry);
      case _ when transactionType.isDisbursement:
        final labelIds = (formData["mutableLabels"] as Iterable? ?? const [])
            .map((i) => i.id as String)
            .toList();

        final entry = await disburseFund.execute(
          controllerId,
          note: formData["note"],
          amount: formData["amount"],
          categoryId: formData["category"].first?.id,
          labelIds: labelIds,
          issuedAt: formData["timestamp"].dateTime,
        );

        return Draft<Entry>(entry);
      case _ when transactionType.isDeposit:
        final entry = await depositFund.execute(
          controllerId,
          note: formData["note"],
          amount: formData["amount"],
        );

        return Draft<Entry>(entry);
      default:
        throw Exception();
    }
  }

  @override
  Draft<Entry>? fill(Draft<Entry>? draft) {
    formData["category"] = [controller.requireData.category];
    formData["readOnlyLabels"] = controller.requireData.labels;

    if (draft != null) {
      formData["labels"] = draft.entity.labels;
      formData["amount"] = draft.entity.amount;
      formData["note"] = draft.entity.note;
      formData["type"] = draft.entity.amount > 0
          ? [FundTransactionType.withdraw]
          : [FundTransactionType.deposit];
      formData["timestamp"] = Timestamp.specific(draft.entity.issuedAt);
      formData["mutableLabels"] = draft.entity.labels.where(
        (label) => !controller.requireData.labels.contains(label),
      );
    }

    return draft;
  }
}
