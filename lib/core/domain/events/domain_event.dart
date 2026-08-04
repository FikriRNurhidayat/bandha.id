abstract class DomainEvent {
  final DateTime occurredAt;
  DomainEvent() : occurredAt = DateTime.now();
}
