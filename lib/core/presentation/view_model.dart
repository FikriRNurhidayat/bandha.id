import 'package:flutter/foundation.dart';

abstract class ViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  Object? error;
  StackTrace? stackTrace;

  Future<void> execute(Future<void> Function() block) async {
    isLoading = true;
    notifyListeners();

    try {
      await block();
    } catch (e, st) {
      print(e);
      print(st);

      isError = true;
      error = e;
      stackTrace = st;
    }

    isLoading = false;
    notifyListeners();
  }
}
