import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/events/fund_destroyed.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class DestroyFund extends DestroyEntity<Fund> {
  final UnitOfWork unitOfWork;
  final DomainEventPublisher eventPublisher;

  DestroyFund(
    super.repository, {
    required this.unitOfWork,
    required this.eventPublisher,
  });

  factory DestroyFund.build(DependencyContainer c) {
    return DestroyFund(
      c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      eventPublisher: c.get<DomainEventPublisher>(),
    );
  }

  @override
  Future<void> execute(String id) async {
    return unitOfWork.execute(() async {
      final fund = await repository.get(id);
      await repository.destroy(fund);
      await eventPublisher.raise(FundDestroyed.fromFund(fund));
    });
  }
}
