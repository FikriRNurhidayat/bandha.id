import 'package:banda/entity/saving.dart';
import 'package:banda/repositories/saving_repository.dart';
import 'package:flutter/material.dart';

class SavingProvider extends ChangeNotifier {
  final SavingRepository _repository;

  SavingProvider(this._repository);

  Future<List<Saving>> search(Map? spec) async {
    return _repository.search(spec);
  }

  Future<void> add({
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    _repository.create(
      note: note,
      goal: goal,
      accountId: accountId,
      labelIds: labelIds,
    );
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    _repository.update(
      id: id,
      note: note,
      goal: goal,
      accountId: accountId,
      labelIds: labelIds,
    );
    notifyListeners();
  }

  Future<Saving?> get(String id) async {
    return _repository.get(id);
  }

  Future<void> remove(String id) async {
    _repository.remove(id);
    notifyListeners();
  }
}
