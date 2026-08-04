import 'dart:collection';

import 'package:bandha/core/domain/types/data_cursor.dart';

class DataList<T> extends IterableBase<T> {
  final DataCursor? previous;
  final DataCursor? next;
  final bool hasNext;
  final bool hasPrevious;
  final Iterable<T> hits;

  DataList({
    this.previous,
    this.next,
    required this.hasNext,
    required this.hasPrevious,
    required this.hits,
  });

  @override
  Iterator<T> get iterator => hits.iterator;

  DataList<T> copyWith({
    DataCursor? previous,
    DataCursor? next,
    bool? hasNext,
    bool? hasPrevious,
    Iterable<T>? hits,
  }) {
    return DataList<T>(
      previous: previous ?? this.previous,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      next: next ?? this.next,
      hasNext: hasNext ?? this.hasNext,
      hits: hits ?? this.hits,
    );
  }
}
