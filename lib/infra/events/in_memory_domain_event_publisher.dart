import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:flutter/widgets.dart';

class InMemoryDomainEventPublisher implements DomainEventPublisher {
  final List<DomainEvent> events = [];
  final Map<Type, List<InMemoryDomainEventHandlerRegistrar<DomainEvent>>>
  handlers = {};

  @override
  Future<void> raise(DomainEvent event) async => events.add(event);

  @override
  Future<void> raiseAll(Iterable<DomainEvent> events) async =>
      this.events.addAll(events);

  @override
  Future<void> dispatch() async {
    try {
      while (events.isNotEmpty) {
        final batchEvents = <Type, List<DomainEvent>>{};
        for (final event in events) {
          batchEvents.putIfAbsent(event.runtimeType, () => []).add(event);
        }
        events.clear();

        for (final MapEntry(:key, :value) in batchEvents.entries) {
          final registrars = handlers[key];
          if (registrars == null) continue;

          for (final registrar in registrars) {
            await registrar.dispatch(value);
          }
        }
      }
    } catch (error, stackTrace) {
      debugPrint("dispatch:error: $error");
      debugPrint("dispatch:stackTrace: $stackTrace");
      rethrow;
    }
  }

  @override
  void clear() => events.clear();

  @override
  void register<T extends DomainEvent>(EventHandler<T> handler) {
    handlers
        .putIfAbsent(T, () => <InMemoryDomainEventHandlerRegistrar<T>>[])
        .add(InMemoryDomainEventHandlerRegistrar<T>(handler));
  }
}

class InMemoryDomainEventHandlerRegistrar<T extends DomainEvent> {
  InMemoryDomainEventHandlerRegistrar(this.handler);
  final EventHandler<T> handler;

  Future<void> dispatch(List<DomainEvent> events) async {
    if (events.length == 1) {
      await handler.handle(events.first as T);
    } else {
      await handler.handleAll(events.cast<T>());
    }
  }
}
