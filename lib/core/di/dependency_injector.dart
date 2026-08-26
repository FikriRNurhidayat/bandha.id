import 'package:bandha/core/di/dependency_container.dart';
import 'package:flutter/widgets.dart';

class DependencyInjector extends InheritedWidget {
  const DependencyInjector({super.key, required this.c, required super.child});

  final DependencyContainer c;

  static DependencyContainer of(BuildContext context) {
    final injector = context
        .dependOnInheritedWidgetOfExactType<DependencyInjector>();
    assert(
      injector != null,
      'No Injector found in context. Did you forget to wrap your app with Injector?',
    );
    return injector!.c;
  }

  @override
  bool updateShouldNotify(DependencyInjector oldWidget) => false;
}
