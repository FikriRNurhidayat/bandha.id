import 'package:bandha/modules/funds/domain/entities/fund.dart';

class FundSnapshot {
  final String journalId;

  FundSnapshot({required this.journalId});

  factory FundSnapshot.fromFund(Fund fund) {
    return FundSnapshot(journalId: fund.journal.id);
  }
}
