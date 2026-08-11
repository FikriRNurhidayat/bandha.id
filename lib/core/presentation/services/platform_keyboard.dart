import 'package:bandha/core/presentation/services/platform_keyboard_data.dart';
import 'package:flutter/widgets.dart';

class PlatformKeyboard extends InheritedWidget {
  final ValueNotifier<PlatformKeyboardData> _notifier;

  const PlatformKeyboard({
    super.key,
    required ValueNotifier<PlatformKeyboardData> notifier,
    required super.child,
  }) : _notifier = notifier;

  static PlatformKeyboardData of(BuildContext context) {
    final keyboard =
        context.dependOnInheritedWidgetOfExactType<PlatformKeyboard>();
    return keyboard?._notifier.value ?? PlatformKeyboardData.hidden;
  }

  static ValueNotifier<PlatformKeyboardData>? _bindingOf(BuildContext context) {
    final keyboard =
        context.findAncestorWidgetOfExactType<PlatformKeyboard>();
    return keyboard?._notifier;
  }

  @override
  bool updateShouldNotify(PlatformKeyboard oldWidget) => false;
}

mixin PlatformKeyboardObserver<T extends StatefulWidget> on State<T> {
  ValueNotifier<PlatformKeyboardData>? _notifier;

  void didChangeKeyboard() {}

  @override
  void initState() {
    super.initState();
    _notifier = PlatformKeyboard._bindingOf(context);
    _notifier?.addListener(_onKeyboardChanged);
  }

  void _onKeyboardChanged() {
    didChangeKeyboard();
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onKeyboardChanged);
    super.dispose();
  }
}
