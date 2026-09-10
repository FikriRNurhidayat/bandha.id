import 'package:flutter/widgets.dart';

class SelectOption<T> {
  final String text;
  final T value;

  SelectOption({required this.text, required this.value});
}

class SelectController<T> extends ChangeNotifier {
  Set<T> value;
  Iterable<T> availableValues;
  Iterable<SelectOption<T>> selectOptions;
  bool isLoading = false;

  SelectController({
    Set<T>? value,
    this.availableValues = const [],
    this.selectOptions = const [],
  }) : value = value ?? <T>{};

  Iterable<SelectOption<T>> get selected =>
      selectOptions.where((option) => value.contains(option.value));

  void updateAll(Iterable<SelectOption<T>> selectOptions) {
    this.selectOptions = selectOptions;
    notifyListeners();
  }

  void override(Set<T> value) {
    this.value = value;
    notifyListeners();
  }

  void replace(T item) {
    return replaceAll([item]);
  }

  void replaceAll(Iterable<T> items) {
    value = items.toSet();
    notifyListeners();
  }

  void selectAll(Iterable<T> items) {
    for (final item in items) {
      if (!value.contains(item)) {
        value.add(item);
      }
    }

    notifyListeners();
  }

  void select(T item) {
    return selectAll([item]);
  }

  void deselect(T item) {
    return deselectAll([item]);
  }

  void deselectAll(Iterable<T> items) {
    for (final item in items) {
      if (value.contains(item)) {
        value.remove(item);
      }
    }

    notifyListeners();
  }
}
