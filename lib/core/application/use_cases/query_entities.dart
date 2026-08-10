import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';

abstract class QueryEntities<E> {
  final Repository<E> repository;

  QueryEntities(this.repository);

  Future<DataList<E>> execute({
    DataFilter? filter,
    DataCursor? cursor,
    int? size,
  }) async {
    final entities = await repository.query(
      DataQuery(filter: filter, cursor: cursor, size: size),
    );

    return entities;
  }
}
