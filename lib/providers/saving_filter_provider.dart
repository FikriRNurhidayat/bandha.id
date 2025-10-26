import 'package:flutter/material.dart';

class SavingFilterProvider extends ChangeNotifier {
  Map? _filter;

  SavingFilterProvider();

  void set(Map value) {
    _filter = value;
    notifyListeners();
  }

  Map? get() {
    return _filter;
  }

  reset() {
    _filter = null;
    notifyListeners();
  }
}
