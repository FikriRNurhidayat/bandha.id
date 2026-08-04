import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:bandha/core/domain/types/data_filter.dart';

class DataQuery {
  DataFilter filter;
  DataCursor? cursor;
  int size;

  DataQuery({DataFilter? filter, this.cursor, int? size})
    : filter = filter ?? {},
      size = size ?? 20;
}
