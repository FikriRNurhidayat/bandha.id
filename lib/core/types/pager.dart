class Pager<T> extends Iterable<T> {
  List<T>? _current;
  List<T>? _next;
  List<T>? _previous;

  Pager();

  List<T>? get next {
    return _next;
  }

  List<T>? get previous {
    return _previous;
  }

  List<T>? get current {
    return _current;
  }

  set current(List<T> v) {
    _current = v;
  }

  set next(List<T> v) {
    if (_next != null) {
      _previous = _current;
      _current = v;
      _next = null;
      return;
    }

    _next = v;
  }

  set previous(List<T> v) {
    if (_previous != null) {
      _next = _current;
      _current = _previous!;
      _previous = v;

      return;
    }

    _previous = v;
  }

  @override
  Iterator<T> get iterator {
    return [...?_previous, ...?_current, ...?_next].iterator;
  }
}
