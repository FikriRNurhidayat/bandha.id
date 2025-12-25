import 'package:banda/features/loans/entities/loan.dart';
import 'package:banda/features/loans/entities/loan_payment.dart';
import 'package:banda/features/loans/services/loan_service.dart';
import 'package:banda/common/types/specification.dart';
import 'package:flutter/material.dart';

class LoanProvider extends ChangeNotifier {
  final LoanService loanService;

  LoanProvider(this.loanService);

  Future<List<Loan>> search(Filter? spec) async {
    return loanService.search(spec);
  }

  Future<void> sync(String id) async {
    await loanService.sync(id);
    notifyListeners();
  }

  Future<void> create({
    required double amount,
    double? fee,
    required DateTime issuedAt,
    DateTime? settledAt,
    required LoanType type,
    required LoanStatus status,
    required String partyId,
    required String accountId,
  }) async {
    await loanService.create(
      amount: amount,
      type: type,
      status: status,
      partyId: partyId,
      accountId: accountId,
      fee: fee ?? 0,
      issuedAt: issuedAt,
      settledAt: settledAt,
    );

    notifyListeners();
  }

  Future<void> update(
    String id, {
    required double amount,
    double? fee,
    required DateTime issuedAt,
    DateTime? settledAt,
    required LoanType type,
    required LoanStatus status,
    required String partyId,
    required String accountId,
  }) async {
    await loanService.update(
      id,
      amount: amount,
      type: type,
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
    return loanService.get(id);
  }

  Future<void> delete(String id) async {
    await loanService.delete(id);
    notifyListeners();
  }

  Future<void> deletePayment(String loanId, String entryId) async {
    await loanService.deletePayment(loanId, entryId);
    notifyListeners();
  }

  Future<LoanPayment> getPayment(String loanId, String entryId) async {
    return loanService.getPayment(loanId, entryId);
  }

  Future<void> updatePayment(
    String loanId,
    String entryId, {
    required double amount,
    double fee = 0,
    required String accountId,
    required DateTime issuedAt,
  }) async {
    await loanService.updatePayment(
      loanId,
      entryId,
      amount: amount,
      fee: fee,
      accountId: accountId,
      issuedAt: issuedAt,
    );

    notifyListeners();
  }

  Future<void> createPayment(
    String loanId, {
    required double amount,
    double fee = 0,
    required String accountId,
    required DateTime issuedAt,
  }) async {
    await loanService.createPayment(
      loanId,
      amount: amount,
      fee: fee,
      accountId: accountId,
      issuedAt: issuedAt,
    );

    notifyListeners();
  }

  Future<List<LoanPayment>> searchPayments(String loanId) {
    final Filter specification = {
      "loan_in": [loanId],
    };

    return loanService.searchPayments(specification: specification);
  }

  debugReminder(String id) {
    return loanService.debugReminder(id);
  }
}
