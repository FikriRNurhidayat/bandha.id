import 'package:banda/entity/account.dart';
import 'package:banda/services/account_service.dart';
import 'package:flutter/material.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService accountService;

  AccountProvider({required this.accountService});

  Future<List<Account>> search() {
    return accountService.search();
  }

  Future<void> create({
    required String name,
    required String holderName,
    required AccountKind kind,
  }) {
    return accountService
        .create(name: name, holderName: holderName, kind: kind)
        .then((_) => notifyListeners());
  }

  Future<void> update({
    required String id,
    required String name,
    required String holderName,
    required AccountKind kind,
  }) {
    return accountService
        .update(id: id, name: name, holderName: holderName, kind: kind)
        .then((_) => notifyListeners());
  }

  Future<void> delete(String id) {
    return accountService.delete(id).then((_) => notifyListeners());
  }
}
