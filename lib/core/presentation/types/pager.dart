import 'package:bandha/core/domain/types/data_cursor.dart';

class Pager<T> extends Iterable<T> {
  List<T> _current = [];
  List<T> _next = [];
  List<T> _previous = [];

  DataCursor? nextCursor;
  DataCursor? previousCursor;

  Pager();

  factory Pager.of(List<T> t) {
    final pager = Pager<T>();
    pager._current = t;
    return pager;
  }

  Pager<T> withPrevious(List<T> v) {
    if (_previous.isEmpty) {
      final pager = Pager<T>.of(_current);
      pager._previous = v;
      return pager;
    }

    final pager = Pager<T>.of(_previous);
    pager._previous = v;
    pager._next = _current;
    return pager;
  }

  Pager<T> withPreviousCursor(DataCursor? cursor) {
    previousCursor = cursor;
    return this;
  }

  Pager<T> withNextCursor(DataCursor? cursor) {
    nextCursor = cursor;
    return this;
  }

  Pager<T> withNext(List<T> v) {
    if (_next.isEmpty) {
      final pager = Pager<T>.of(_current);
      pager._next = v;
      return pager;
    }

    final pager = Pager<T>.of(_next);
    pager._previous = _current;
    pager._next = v;
    return pager;
  }

  T operator [](int index) {
    if (index < 0 || index >= length) {
      throw RangeError.index(index, this, 'index');
    }

    if (index < _previous.length) {
      return _previous[index];
    }

    final relativeIndex = index - _previous.length;
    if (relativeIndex < _current.length) {
      return _current[relativeIndex];
    }

    return _next[relativeIndex - _current.length];
  }

  @override
  bool get isEmpty => length == 0;

  @override
  int get length {
    return _previous.length + _current.length + _next.length;
  }

  @override
  Iterator<T> get iterator {
    return [..._previous, ..._current, ..._next].iterator;
  }

  @override
  Pager<R> map<R>(R Function(T) toElement) {
    final pager = Pager<R>.of(_current.map(toElement).toList());
    pager._previous = _previous.map(toElement).toList();
    pager._next = _next.map(toElement).toList();
    pager.nextCursor = nextCursor;
    pager.previousCursor = previousCursor;
    return pager;
  }

  @override
  Pager<T> followedBy(Iterable<T> other) {
    final pager = Pager<T>.of(_current);
    pager._previous = _previous;
    pager._next = [..._next, ...other];
    pager.previousCursor = previousCursor;
    pager.nextCursor = nextCursor;
    return pager;
  }
}
