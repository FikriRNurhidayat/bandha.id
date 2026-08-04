import 'package:bandha/core/domain/events/domain_event.dart';

abstract class EventHandler<E extends DomainEvent> {
  Future<void> handle(E event);
  Future<void> handleAll(Iterable<E> events) async {
    for (final event in events) {
      await handle(event);
    }
  }
}
