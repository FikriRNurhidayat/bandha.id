import 'package:flutter/widgets.dart';

abstract class ViewModel<T> {
  var isDisposed = false;
  abstract final ValueNotifier<T> notifier;

  @mustCallSuper
  void dispose() async {
    if (isDisposed) return;
    notifier.dispose();
  }
}
