import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class LoanFilterProvider extends ChangeNotifier {
  Specification? _specification;

  LoanFilterProvider();

  void set(Specification value) {
    _specification = value;
    notifyListeners();
  }

  Specification? get() {
    return _specification;
  }

  reset() {
    _specification = null;
    notifyListeners();
  }
}
