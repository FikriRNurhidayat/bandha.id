import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/funds/domain/events/fund_destroyed.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class DestroyFundParams {
  final String id;

  DestroyFundParams(this.id);
}

class DestroyFund extends UseCase<DestroyFundParams, void> {
  final FundRepository fundRepository;
  final UnitOfWork unitOfWork;
  final DomainEventPublisher eventPublisher;

  DestroyFund({
    required this.fundRepository,
    required this.unitOfWork,
    required this.eventPublisher,
  });

  factory DestroyFund.fromContainer(DependencyContainer c) {
    return DestroyFund(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      eventPublisher: c.get<DomainEventPublisher>(),
    );
  }

  @override
  Future<void> execute(DestroyFundParams params) async {
    return unitOfWork.execute(() async {
      final fund = await fundRepository.get(params.id);
      await fundRepository.destroy(fund);
      await eventPublisher.raise(FundDestroyed.fromFund(fund));
    });
  }
}
