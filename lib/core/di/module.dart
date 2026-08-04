import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';

abstract class Module {
  Future<void> provide(DependencyContainer c) async {}
  Future<void> compose(DependencyContainer c);
  Future<void> event(DependencyContainer c, DomainEventPublisher e) async {}
}
