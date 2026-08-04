class DependencyContainer {
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function(DependencyContainer)> _factories = {};

  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  void registerSingletonFactory<T>(T instance) {
    _singletons[T] = instance;
  }

  void registerFactory<T>(T Function(DependencyContainer) factory) {
    _factories[T] = factory;
  }

  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    final factory = _factories[T];
    if (factory != null) {
      return factory(this) as T;
    }

    throw Exception('$T is not registered in DependencyContainer');
  }

  void reset() {
    _singletons.clear();
    _factories.clear();
  }
}
