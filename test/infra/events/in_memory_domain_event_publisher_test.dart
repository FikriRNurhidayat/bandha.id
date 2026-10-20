import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/infra/events/in_memory_domain_event_publisher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/core_helpers.dart';

class UnhandledEvent extends DomainEvent {}

void main() {
  group("InMemoryDomainEventPublisher", () {
    late InMemoryDomainEventPublisher publisher;
    setUp(() => publisher = InMemoryDomainEventPublisher());

    test("raise and raiseAll queue without dispatching", () async {
      final handler = RecordingHandler<PingEvent>();
      publisher.register<PingEvent>(handler);
      await publisher.raise(PingEvent(1));
      await publisher.raiseAll([PingEvent(2), PingEvent(3)]);
      expect(publisher.events, hasLength(3));
      expect(handler.handleCalls, 0);
    });

    test("single event of a type uses handle", () async {
      final handler = RecordingHandler<PingEvent>();
      publisher.register<PingEvent>(handler);
      await publisher.raise(PingEvent(1));
      await publisher.dispatch();
      expect(handler.handled.map((e) => e.n), [1]);
      expect(handler.batches, isEmpty);
      expect(publisher.events, isEmpty);
    });

    test("multiple events of a type are batched into handleAll", () async {
      final handler = RecordingHandler<PingEvent>();
      publisher.register<PingEvent>(handler);
      await publisher.raiseAll([PingEvent(1), PingEvent(2), PingEvent(3)]);
      await publisher.dispatch();
      expect(handler.batches, hasLength(1));
      expect(handler.batches.single.map((e) => e.n), [1, 2, 3]);
    });

    test("batches events per runtime type", () async {
      final pings = RecordingHandler<PingEvent>();
      final pongs = RecordingHandler<PongEvent>();
      publisher.register<PingEvent>(pings);
      publisher.register<PongEvent>(pongs);
      await publisher.raiseAll([PingEvent(1), PongEvent(10), PingEvent(2)]);
      await publisher.dispatch();
      expect(pings.batches.single.map((e) => e.n), [1, 2]);
      expect(pongs.handled.map((e) => e.n), [10]);
      expect(pongs.batches, isEmpty);
    });

    test("all handlers for a type run in registration order", () async {
      final log = <String>[];
      publisher.register<PingEvent>(
        RecordingHandler(onHandle: (_) async => log.add("first")),
      );
      publisher.register<PingEvent>(
        RecordingHandler(onHandle: (_) async => log.add("second")),
      );
      await publisher.raise(PingEvent(1));
      await publisher.dispatch();
      expect(log, ["first", "second"]);
    });

    test("events without handlers are dropped", () async {
      final handler = RecordingHandler<PingEvent>();
      publisher.register<PingEvent>(handler);
      await publisher.raiseAll([UnhandledEvent(), PingEvent(1)]);
      await publisher.dispatch();
      expect(handler.handled, hasLength(1));
      expect(publisher.events, isEmpty);
    });

    test("dispatch with no events is a no-op", () async {
      await publisher.dispatch();
      expect(publisher.events, isEmpty);
    });

    test("events raised during dispatch are dispatched too", () async {
      final pongs = RecordingHandler<PongEvent>();
      publisher.register<PingEvent>(
        RecordingHandler(onHandle: (e) => publisher.raise(PongEvent(e.n * 10))),
      );
      publisher.register<PongEvent>(pongs);
      await publisher.raiseAll([PingEvent(1), PingEvent(2)]);
      await publisher.dispatch();
      expect(pongs.batches.single.map((e) => e.n), [10, 20]);
      expect(publisher.events, isEmpty);
    });

    test("cascades of the same type run in later rounds", () async {
      final seen = <int>[];
      publisher.register<PingEvent>(
        RecordingHandler(
          onHandle: (e) async {
            seen.add(e.n);
            if (e.n < 3) await publisher.raise(PingEvent(e.n + 1));
          },
        ),
      );
      await publisher.raise(PingEvent(1));
      await publisher.dispatch();
      expect(seen, [1, 2, 3]);
    });

    test("rethrows handler errors", () async {
      publisher.register<PingEvent>(
        RecordingHandler(onHandle: (_) async => throw StateError("boom")),
      );
      await publisher.raise(PingEvent(1));
      await expectLater(publisher.dispatch(), throwsStateError);
    });

    test("an error stops later handlers in the round", () async {
      final pongs = RecordingHandler<PongEvent>();
      publisher.register<PingEvent>(
        RecordingHandler(onHandle: (_) async => throw StateError("boom")),
      );
      publisher.register<PongEvent>(pongs);
      await publisher.raiseAll([PingEvent(1), PongEvent(1)]);
      await expectLater(publisher.dispatch(), throwsStateError);
      expect(pongs.handleCalls, 0);
    });

    test("clear drops queued events", () async {
      final handler = RecordingHandler<PingEvent>();
      publisher.register<PingEvent>(handler);
      await publisher.raise(PingEvent(1));
      publisher.clear();
      expect(publisher.events, isEmpty);
      await publisher.dispatch();
      expect(handler.handleCalls, 0);
    });

    test("register keys handlers by the type argument", () {
      publisher.register<PingEvent>(RecordingHandler<PingEvent>());
      publisher.register<PingEvent>(RecordingHandler<PingEvent>());
      expect(publisher.handlers.keys, [PingEvent]);
      expect(publisher.handlers[PingEvent], hasLength(2));
    });
  });
}
