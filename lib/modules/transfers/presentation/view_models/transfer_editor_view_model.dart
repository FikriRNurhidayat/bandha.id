import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:bandha/modules/transfers/application/use_cases/create_transfer.dart';
import 'package:bandha/modules/transfers/application/use_cases/update_transfer.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:flutter/material.dart';

class TransferEditorViewModel extends AsyncEditorViewModel<Transfer> {
  final CreateTransfer createTransfer;
  final UpdateTransfer updateTransfer;

  @override
  final GetEntity<Transfer> getEntity;

  TransferEditorViewModel._({
    required this.createTransfer,
    required this.updateTransfer,
    required this.getEntity,
  });

  factory TransferEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<TransferEditorViewModel>();
  }

  factory TransferEditorViewModel.build(DependencyContainer c) {
    return TransferEditorViewModel._(
      createTransfer: c.get<CreateTransfer>(),
      updateTransfer: c.get<UpdateTransfer>(),
      getEntity: c.get<GetEntity<Transfer>>(),
    );
  }

  @override
  Future<Draft<Transfer>> onCreate() async {
    debugPrint("creditJournal: ${formData["credit_journal"].first}");
    debugPrint("debitJournal: ${formData["debit_journal"].first}");

    final transfer = await createTransfer.execute(
      note: formData["note"],
      debitJournalId: formData["debit_journal"].first.id,
      debitAmount: formData["debit_amount"],
      debitFeeAmount: formData["debit_fee_amount"] != null
          ? formData["debit_fee_amount"] * -1
          : null,
      creditJournalId: formData["credit_journal"].first.id,
      creditAmount: formData["credit_amount"] * -1,
      creditFeeAmount: formData["credit_fee_amount"] != null
          ? formData["credit_fee_amount"] * -1
          : null,
      issuedAt: formData["timestamp"].dateTime,
    );
    return Draft<Transfer>(transfer);
  }

  @override
  Future<Draft<Transfer>> onUpdate() async {
    final transfer = await updateTransfer.execute(
      id!,
      note: formData["note"],
      debitJournalId: formData["debit_journal"].id,
      debitAmount: formData["debit_amount"],
      debitFeeAmount: formData["debit_fee_amount"] != null
          ? formData["debit_fee_amount"] * -1
          : null,
      creditJournalId: formData["credit_journal"].id,
      creditAmount: formData["credit_amount"] * -1,
      creditFeeAmount: formData["credit_fee_amount"] != null
          ? formData["credit_fee_amount"] * -1
          : null,
      issuedAt: formData["timestamp"].dateTime,
    );
    return Draft<Transfer>(transfer);
  }

  @override
  Future<Draft<Transfer>> fill(Draft<Transfer> draft) async {
    formData["note"] = draft.entity.note;
    formData["debit_journal"] = [draft.entity.debit.journal];
    formData["debit_amount"] = draft.entity.debit.amount;
    formData["debit_fee_amount"] = draft.entity.debitFee?.amount;
    formData["credit_journal"] = [draft.entity.credit.journal];
    formData["credit_amount"] = draft.entity.credit.amount;
    formData["credit_fee_amount"] = draft.entity.creditFee?.amount;
    formData["timestamp"] = Timestamp.specific(draft.entity.issuedAt);

    return draft;
  }
}
