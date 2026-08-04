import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';

class InMemoryDomainEventPublisher implements DomainEventPublisher {
  final List<DomainEvent> _events = [];
  final Map<Type, List<EventHandler<DomainEvent>>> _handlers = {};

  @override
  Future<void> raise(DomainEvent event) async => _events.add(event);

  @override
  Future<void> raiseAll(Iterable<DomainEvent> events) async =>
      _events.addAll(events);

  @override
  Future<void> dispatch() async {
    final batchEvents = <Type, List<DomainEvent>>{};
    for (final event in _events) {
      batchEvents.putIfAbsent(event.runtimeType, () => []).add(event);
    }

    for (final MapEntry(:key, :value) in batchEvents.entries) {
      final handlers = _handlers[key];
      if (handlers == null) continue;

      for (final handler in handlers) {
        if (value.length == 1) {
          await handler.handle(value.first);
        } else {
          await handler.handleAll(value);
        }
      }
    }

    _events.clear();
  }

  @override
  void clear() => _events.clear();

  @override
  void register<T extends DomainEvent>(EventHandler<T> handler) {
    _handlers
        .putIfAbsent(T, () => <EventHandler<DomainEvent>>[])
        .add(handler as EventHandler<DomainEvent>);
  }
}
