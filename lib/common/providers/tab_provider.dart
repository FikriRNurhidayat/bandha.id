import 'package:flutter/material.dart';

class TabProvider<T> extends ChangeNotifier {
  Set<T> _tabs;

  TabProvider(this._tabs);

  void change(Set<T> v) {
    _tabs = v;
    notifyListeners();
  }

  Set<T> get current {
    return {_tabs.first};
  }
}
