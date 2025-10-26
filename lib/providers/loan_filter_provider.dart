import 'package:flutter/material.dart';

class LoanFilterProvider extends ChangeNotifier {
  Map? _filter;

  LoanFilterProvider();

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
