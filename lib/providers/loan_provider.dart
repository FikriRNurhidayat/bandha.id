import 'package:banda/entity/loan.dart';
import 'package:banda/repositories/loan_repository.dart';
import 'package:flutter/material.dart';

class LoanProvider extends ChangeNotifier {
  final LoanRepository _repository;

  LoanProvider(this._repository);

  Future<List<Loan>> search() async {
    return _repository.search();
  }

  Future<void> add({
    required double amount,
    required DateTime timestamp,
    required DateTime settledAt,
    required LoanKind kind,
    required LoanStatus status,
    required String partyId,
    required String accountId,
    double? fee,
  }) async {
    _repository.create(
      amount: amount,
      timestamp: timestamp,
      settledAt: settledAt,
      kind: kind,
      status: status,
      partyId: partyId,
      accountId: accountId,
      fee: fee,
    );
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required double amount,
    required DateTime timestamp,
    required DateTime settledAt,
    required LoanKind kind,
    required LoanStatus status,
    required String partyId,
    required String accountId,
    double? fee,
  }) async {
    _repository.update(
      id: id,
      amount: amount,
      timestamp: timestamp,
      settledAt: settledAt,
      kind: kind,
      status: status,
      partyId: partyId,
      accountId: accountId,
      fee: fee,
    );
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _repository.remove(id);
    notifyListeners();
  }
}
