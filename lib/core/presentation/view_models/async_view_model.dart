import 'package:bandha/core/presentation/view_model.dart';
import 'package:flutter/widgets.dart';

abstract class AsyncViewModel<T> extends ViewModel<AsyncSnapshot<T>> {
  @override
  final notifier = ValueNotifier<AsyncSnapshot<T>>(AsyncSnapshot.nothing());

  bool get hasData => notifier.value.hasData;
  T? get data => notifier.value.data;
  T get requireData => notifier.value.requireData;

  bool get hasError => notifier.value.hasError;
  Object? get error => notifier.value.error;
  StackTrace? get stackTrace => notifier.value.stackTrace;

  Future<void> manualExecute(Future<void> Function() block) async {
    if (isDisposed) return;
    notifier.value = const AsyncSnapshot.waiting();

    try {
      await block();
    } catch (error, stackTrace) {
      notifier.value = AsyncSnapshot.withError(
        ConnectionState.done,
        error,
        stackTrace,
      );
    }
  }

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
