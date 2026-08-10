import 'package:flutter/material.dart';

class KeyboardObserver extends WidgetsBindingObserver {
  static double height = 0;
  static final instance = KeyboardObserver._();

  KeyboardObserver._() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    for (final view in WidgetsBinding.instance.platformDispatcher.views) {
      final inset = view.viewInsets.bottom / view.devicePixelRatio;
      if (inset > 0) height = inset;
    }
  }
}
