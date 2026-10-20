import 'package:bandha/core/di/dependency_container.dart';
import 'package:flutter_test/flutter_test.dart';

class Service {}

class Other {}

void main() {
  group("DependencyContainer", () {
    late DependencyContainer c;
    setUp(() => c = DependencyContainer());

    test("returns the same singleton instance", () {
      final s = Service();
      c.registerSingleton<Service>(s);
      expect(c.get<Service>(), same(s));
      expect(c.get<Service>(), same(s));
    });

    test("registerSingletonFactory stores an instance like a singleton", () {
      final s = Service();
      c.registerSingletonFactory<Service>(s);
      expect(c.get<Service>(), same(s));
    });

    test("factory builds a new instance per get with the container", () {
      DependencyContainer? received;
      c.registerFactory<Service>((container) {
        received = container;
        return Service();
      });
      final a = c.get<Service>();
      final b = c.get<Service>();
      expect(a, isNot(same(b)));
      expect(received, same(c));
    });

    test("factories can resolve other dependencies", () {
      final other = Other();
      c.registerSingleton<Other>(other);
      c.registerFactory<List<Other>>((c) => [c.get<Other>()]);
      expect(c.get<List<Other>>().single, same(other));
    });

    test("singleton wins over factory for the same type", () {
      final s = Service();
      c.registerFactory<Service>((_) => Service());
      c.registerSingleton<Service>(s);
      expect(c.get<Service>(), same(s));
    });

    test("re-registering replaces the previous entry", () {
      final first = Service();
      final second = Service();
      c.registerSingleton<Service>(first);
      c.registerSingleton<Service>(second);
      expect(c.get<Service>(), same(second));
    });

    test("throws for unregistered types", () {
      expect(
        () => c.get<Service>(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            "message",
            contains("Service is not registered"),
          ),
        ),
      );
    });

    test("keys generic types separately", () {
      c.registerSingleton<List<int>>([1]);
      c.registerSingleton<List<String>>(["a"]);
      expect(c.get<List<int>>(), [1]);
      expect(c.get<List<String>>(), ["a"]);
    });

    test("reset clears everything", () {
      c.registerSingleton<Service>(Service());
      c.registerFactory<Other>((_) => Other());
      c.reset();
      expect(() => c.get<Service>(), throwsException);
      expect(() => c.get<Other>(), throwsException);
    });
  });
}
