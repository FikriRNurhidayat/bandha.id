import 'package:banda/entity/loan.dart';
import 'package:banda/services/loan_service.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class LoanProvider extends ChangeNotifier {
  final LoanService loanService;

  LoanProvider({required this.loanService});

  Future<List<Loan>> search(Specification? spec) async {
    return loanService.search(spec);
  }

  Future<void> create({
    required double amount,
    required DateTime issuedAt,
    required DateTime settledAt,
    required LoanKind kind,
    required LoanStatus status,
    required String partyId,
    required String debitAccountId,
    required String creditAccountId,
    double? fee,
  }) async {
    await loanService.create(
      amount: amount,
      kind: kind,
      status: status,
      partyId: partyId,
      debitAccountId: debitAccountId,
      creditAccountId: creditAccountId,
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
    required String debitAccountId,
    required String creditAccountId,
    double? fee,
  }) async {
    await loanService.update(
      id: id,
      amount: amount,
      kind: kind,
      status: status,
      partyId: partyId,
      debitAccountId: debitAccountId,
      creditAccountId: creditAccountId,
      fee: fee,
      issuedAt: issuedAt,
      settledAt: settledAt,
    );
    notifyListeners();
  }

  Future<Loan?> get(String id) async {
    return loanService.get(id);
  }

  Future<void> delete(String id) async {
    await loanService.delete(id);
    notifyListeners();
  }

  debugReminder(String id) {
    return loanService.debugReminder(id);
  }
}
