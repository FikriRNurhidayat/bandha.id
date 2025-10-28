import 'package:banda/entity/transfer.dart';
import 'package:banda/services/transfer_service.dart';
import 'package:flutter/material.dart';

class TransferProvider extends ChangeNotifier {
  final TransferService transferService;

  TransferProvider({required this.transferService});

  Future<List<Transfer>> search() async {
    return transferService.search();
  }

  Future<void> create({
    required double amount,
    required DateTime issuedAt,
    required String debitAccountId,
    required String creditAccountId,
    double? fee,
  }) {
    return transferService
        .create(
          amount: amount,
          issuedAt: issuedAt,
          fee: fee,
          debitAccountId: debitAccountId,
          creditAccountId: creditAccountId,
        )
        .then((_) => notifyListeners());
  }

  Future<void> update({
    required String id,
    required double amount,
    required DateTime issuedAt,
    required String debitAccountId,
    required String creditAccountId,
    double? fee,
  }) {
    return transferService
        .update(
          id: id,
          amount: amount,
          fee: fee,
          issuedAt: issuedAt,
          debitAccountId: debitAccountId,
          creditAccountId: creditAccountId,
        )
        .then((_) => notifyListeners());
  }

  Future<void> remove(String id) {
    return transferService.delete(id).then((_) => notifyListeners());
  }
}
