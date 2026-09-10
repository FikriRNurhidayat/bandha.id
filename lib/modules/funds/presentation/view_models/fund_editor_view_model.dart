import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/modules/funds/application/use_cases/create_fund.dart';
import 'package:bandha/modules/funds/application/use_cases/update_fund.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter/material.dart';

class FundEditorViewModel extends AsyncEditorViewModel<Fund> {
  final CreateFund createFund;
  final UpdateFund updateFund;

  @override
  final GetEntity<Fund> getEntity;

  FundEditorViewModel._({
    required this.createFund,
    required this.updateFund,
    required this.getEntity,
  });

  factory FundEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<FundEditorViewModel>();
  }

  factory FundEditorViewModel.build(DependencyContainer c) {
    return FundEditorViewModel._(
      createFund: c.get<CreateFund>(),
      updateFund: c.get<UpdateFund>(),
      getEntity: c.get<GetEntity<Fund>>(),
    );
  }

  @override
  Future<Draft<Fund>> onCreate() async {
    final labelIds = (formData["labels"] as Iterable? ?? const [])
        .map((i) => i.id as String)
        .toList();

    final fund = await createFund.execute(
      note: formData["note"],
      amount: formData["amount"],
      categoryId: formData["category"].first.id,
      journalId: formData["journal"].first.id,
      labelIds: labelIds,
    );
    return Draft<Fund>(fund);
  }

  @override
  Future<Draft<Fund>> onUpdate() async {
    final labelIds = (formData["labels"] as Iterable? ?? const [])
        .map((i) => i.id as String)
        .toList();

    final fund = await updateFund.execute(
      id!,
      note: formData["note"],
      amount: formData["amount"],
      categoryId: formData["category"].first.id,
      labelIds: labelIds,
    );
    return Draft<Fund>(fund);
  }

  @override
  Future<Draft<Fund>> fill(Draft<Fund> draft) async {
    formData["note"] = draft.entity.note;
    formData["amount"] = draft.entity.amount;
    formData["category"] = [draft.entity.category];
    formData["journal"] = [draft.entity.journal];
    formData["labels"] = draft.entity.labels;

    return draft;
  }
}
