import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  Map? _filter;

  FilterProvider();

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
