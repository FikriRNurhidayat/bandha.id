import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class EntryFilterProvider extends ChangeNotifier {
  Specification? _filter;

  EntryFilterProvider();

  void set(Specification value) {
    _filter = value;
    notifyListeners();
  }

  Specification? get() {
    return _filter;
  }

  reset() {
    _filter = null;
    notifyListeners();
  }
}
