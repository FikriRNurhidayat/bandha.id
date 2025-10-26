import 'package:flutter/material.dart';

class EntryFilterProvider extends ChangeNotifier {
  Map? _filter;

  EntryFilterProvider();

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
