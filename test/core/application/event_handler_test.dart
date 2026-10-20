import 'package:flutter_test/flutter_test.dart';

import '../../support/core_helpers.dart';

void main() {
  group("EventHandler.handleAll", () {
    test("handles each event in order", () async {
      final handler = RecordingHandler<PingEvent>();
      await handler.handleAll([PingEvent(1), PingEvent(2), PingEvent(3)]);
      expect(handler.handled.map((e) => e.n), [1, 2, 3]);
      expect(handler.handleCalls, 3);
    });

    test("awaits each handle before the next", () async {
      final log = <String>[];
      final handler = RecordingHandler<PingEvent>(
        onHandle: (e) async {
          log.add("start ${e.n}");
          await Future<void>.delayed(Duration.zero);
          log.add("end ${e.n}");
        },
      );
      await handler.handleAll([PingEvent(1), PingEvent(2)]);
      expect(log, ["start 1", "end 1", "start 2", "end 2"]);
    });

    test("does nothing for no events", () async {
      final handler = RecordingHandler<PingEvent>();
      await handler.handleAll([]);
      expect(handler.handleCalls, 0);
    });

    test("stops at the first error", () async {
      final handler = RecordingHandler<PingEvent>(
        onHandle: (e) async {
          if (e.n == 2) throw StateError("boom");
        },
      );
      await expectLater(
        handler.handleAll([PingEvent(1), PingEvent(2), PingEvent(3)]),
        throwsStateError,
      );
      expect(handler.handled.map((e) => e.n), [1, 2]);
    });
  });
}
