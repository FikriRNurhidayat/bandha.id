import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:bandha/core/types/transaction_type.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_editor_view_model.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/deposit_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/withdraw_fund.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter/material.dart';

class FundEntryEditorViewModel extends ControllableEntryEditorViewModel<Fund> {
  FundEntryEditorViewModel({
    required super.getController,
    required super.getEntry,
    required this.depositFund,
    required this.withdrawFund,
  });

  final DepositFund depositFund;
  final WithdrawFund withdrawFund;

  factory FundEntryEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<FundEntryEditorViewModel>();
  }

  factory FundEntryEditorViewModel.build(DependencyContainer c) {
    return FundEntryEditorViewModel(
      getController: c.get<GetEntity<Fund>>(),
      getEntry: c.get<GetEntity<Entry>>(),
      depositFund: c.get<DepositFund>(),
      withdrawFund: c.get<WithdrawFund>(),
    );
  }

  @override
  Future<Draft<Entry>> create() async {
    if (formData["type"].first.isWithdraw) {
      final entry = await withdrawFund.execute(
        controllerId,
        note: formData["note"],
        amount: formData["amount"],
      );

      return Draft<Entry>(entry);
    }

    final entry = await depositFund.execute(
      controllerId,
      note: formData["note"],
      amount: formData["amount"],
    );

    return Draft<Entry>(entry);
  }

  @override
  Draft<Entry>? fill(Draft<Entry>? draft) {
    formData["category"] = [controller.requireData.category];
    formData["labels"] = controller.requireData.labels;

    if (draft != null) {
      formData["amount"] = draft.entity.amount;
      formData["note"] = draft.entity.note;
      formData["type"] = draft.entity.amount > 0
          ? [TransactionType.withdraw]
          : [TransactionType.deposit];
      formData["timestamp"] = Timestamp.specific(draft.entity.issuedAt);
    }

    return draft;
  }
}
