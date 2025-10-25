import 'package:banda/entity/account.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:flutter/material.dart';

class AccountProvider extends ChangeNotifier {
  final AccountRepository _repository;

  AccountProvider(this._repository);

  Future<List<Account>> search() async {
    return _repository.search();
  }

  Future<List<Account>> withBalances() async {
    return _repository.withBalances();
  }

  Future<void> add({
    required String name,
    required String holderName,
    required AccountKind kind,
  }) async {
    await _repository.create(name: name, holderName: holderName, kind: kind);
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String name,
    required String holderName,
    required AccountKind kind,
  }) async {
    await _repository.update(
      id: id,
      name: name,
      holderName: holderName,
      kind: kind,
    );
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    notifyListeners();
  }
}
