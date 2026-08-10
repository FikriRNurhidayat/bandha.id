class DependencyContainer {
  final Map<String, dynamic> _singletons = {};
  final Map<String, dynamic Function(DependencyContainer)> _factories = {};

  void registerSingleton<T>(T instance) {
    _singletons[T.toString()] = instance;
  }

  void registerSingletonFactory<T>(T instance) {
    _singletons[T.toString()] = instance;
  }

  void registerFactory<T>(T Function(DependencyContainer) factory) {
    _factories[T.toString()] = factory;
  }

  T get<T>() {
    if (_singletons.containsKey(T.toString())) {
      return _singletons[T.toString()] as T;
    }

    final factory = _factories[T.toString()];
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
