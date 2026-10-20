import 'package:bandha/core/domain/types/data_cursor.dart';

class Pager<T> extends Iterable<T> {
  List<T> current = [];
  List<T> next = [];
  List<T> previous = [];

  DataCursor? nextCursor;
  DataCursor? previousCursor;

  Pager();

  factory Pager.of(List<T> t) {
    final pager = Pager<T>();
    pager.current = t;
    return pager;
  }

  bool get isFilled =>
      current.isNotEmpty && next.isNotEmpty && previous.isNotEmpty;

  Pager<T> withPrevious(List<T> v) {
    if (previous.isEmpty) {
      final pager = Pager<T>.of(current);
      pager.previous = v;
      return pager;
    }

    final pager = Pager<T>.of(previous);
    pager.previous = v;
    pager.next = current;
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
    if (next.isEmpty) {
      final pager = Pager<T>.of(current);
      pager.next = v;
      return pager;
    }

    final pager = Pager<T>.of(next);
    pager.previous = current;
    pager.next = v;
    return pager;
  }

  T operator [](int index) {
    if (index < 0 || index >= length) {
      throw RangeError.index(index, this, 'index');
    }

    if (index < previous.length) {
      return previous[index];
    }

    final relativeIndex = index - previous.length;
    if (relativeIndex < current.length) {
      return current[relativeIndex];
    }

    return next[relativeIndex - current.length];
  }

  @override
  bool get isEmpty => length == 0;

  @override
  int get length {
    return previous.length + current.length + next.length;
  }

  @override
  Iterator<T> get iterator {
    return [...previous, ...current, ...next].iterator;
  }

  @override
  Pager<T> where(bool Function(T) test) {
    final pager = Pager<T>.of(current.where(test).toList());
    pager.previous = previous.where(test).toList();
    pager.next = next.where(test).toList();
    pager.nextCursor = nextCursor;
    pager.previousCursor = previousCursor;
    return pager;
  }

  @override
  Pager<R> map<R>(R Function(T) toElement) {
    final pager = Pager<R>.of(current.map(toElement).toList());
    pager.previous = previous.map(toElement).toList();
    pager.next = next.map(toElement).toList();
    pager.nextCursor = nextCursor;
    pager.previousCursor = previousCursor;
    return pager;
  }

  @override
  Pager<T> followedBy(Iterable<T> other) {
    final pager = Pager<T>.of(current);
    pager.previous = previous;
    pager.next = [...next, ...other];
    pager.previousCursor = previousCursor;
    pager.nextCursor = nextCursor;
    return pager;
  }
}
