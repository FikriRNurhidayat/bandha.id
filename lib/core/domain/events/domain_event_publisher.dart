import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/domain/events/domain_event.dart';

abstract class DomainEventPublisher {
  Future<void> raise(DomainEvent event);
  Future<void> raiseAll(Iterable<DomainEvent> events);
  Future<void> dispatch();
  void clear();
  void register<E extends DomainEvent>(EventHandler<E> handler);
}
