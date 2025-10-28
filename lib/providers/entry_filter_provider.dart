import 'package:banda/services/entry_service.dart';
import 'package:flutter/material.dart';

class EntryFilterProvider extends ChangeNotifier {
  Spec? _filter;

  EntryFilterProvider();

  void set(Spec value) {
    _filter = value;
    notifyListeners();
  }

  Spec? get() {
    return _filter;
  }

  reset() {
    _filter = null;
    notifyListeners();
  }
}
