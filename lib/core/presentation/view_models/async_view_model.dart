import 'package:bandha/core/presentation/view_model.dart';
import 'package:flutter/widgets.dart';

abstract class AsyncViewModel<T> extends ViewModel<AsyncSnapshot<T>> {
  bool get hasError => notifier.value.hasError;
  Object? get error => notifier.value.error;
  StackTrace? get stackTrace => notifier.value.stackTrace;

  Future<void> execute(Future<T> Function(T? data) block) async {
    if (isDisposed) return;
    final data = notifier.value.data;
    notifier.value = const AsyncSnapshot.waiting();

    try {
      final result = await block(data);
      notifier.value = AsyncSnapshot.withData(ConnectionState.done, result);
    } catch (error, stackTrace) {
      notifier.value = AsyncSnapshot.withError(
        ConnectionState.done,
        error,
        stackTrace,
      );
    }
  }
}
