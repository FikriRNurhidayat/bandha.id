import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/value_objects/fund_snapshot.dart';

class FundDestroyed extends DomainEvent {
  final String fundId;
  final FundSnapshot snapshot;

  FundDestroyed({required this.fundId, required this.snapshot});

  factory FundDestroyed.fromFund(Fund fund) {
    return FundDestroyed(
      fundId: fund.id,
      snapshot: FundSnapshot.fromFund(fund),
    );
  }

  Controller get controller {
    return Controller(id: fundId, type: "Fund");
  }
}
