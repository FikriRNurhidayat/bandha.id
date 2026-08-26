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
    final keyboard = context
        .dependOnInheritedWidgetOfExactType<PlatformKeyboard>();
    final data = keyboard?._notifier.value ?? PlatformKeyboardData.hidden;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return PlatformKeyboardData(
      height: data.height / dpr,
      visible: data.visible,
    );
  }

  static ValueNotifier<PlatformKeyboardData>? notifier(BuildContext context) {
    final keyboard = context.findAncestorWidgetOfExactType<PlatformKeyboard>();
    return keyboard?._notifier;
  }

  @override
  bool updateShouldNotify(PlatformKeyboard oldWidget) => false;
}

mixin PlatformKeyboardObserver<T extends StatefulWidget> on State<T> {
  FocusNode get effectiveFocusNode;

  ValueNotifier<PlatformKeyboardData>? _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = PlatformKeyboard.notifier(context);
    _notifier?.addListener(_onKeyboardChanged);
  }

  void _onKeyboardChanged() {
    if (!PlatformKeyboard.of(context).visible && effectiveFocusNode.hasFocus) {
      effectiveFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onKeyboardChanged);
    super.dispose();
  }
}
