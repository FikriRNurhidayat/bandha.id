import 'package:banda/entity/loan.dart';
import 'package:banda/repositories/loan_repository.dart';
import 'package:flutter/material.dart';

class LoanProvider extends ChangeNotifier {
  final LoanRepository _repository;

  LoanProvider(this._repository);

  Future<List<Loan>> search(Map? spec) async {
    return _repository.search(spec);
  }

  Future<void> add({
    required double amount,
    required DateTime issuedAt,
    required DateTime settledAt,
    required LoanKind kind,
    required LoanStatus status,
    required String partyId,
    required String accountId,
    double? fee,
  }) async {
    _repository.create(
      amount: amount,
      kind: kind,
      status: status,
      partyId: partyId,
      accountId: accountId,
      fee: fee,
      issuedAt: issuedAt,
      settledAt: settledAt,
    );
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required double amount,
    required DateTime issuedAt,
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
      kind: kind,
      status: status,
      partyId: partyId,
      accountId: accountId,
      fee: fee,
      issuedAt: issuedAt,
      settledAt: settledAt,
    );
    notifyListeners();
  }

  Future<Loan?> get(String id) async {
    return _repository.get(id);
  }

  Future<void> remove(String id) async {
    _repository.remove(id);
    notifyListeners();
  }
}
