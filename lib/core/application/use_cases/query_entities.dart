import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';

class QueryEntitiesParams {
  DataFilter? filter;
  DataCursor? cursor;
  int? size;

  QueryEntitiesParams({this.filter, this.cursor, this.size});
}

abstract class QueryEntities<E>
    extends UseCase<QueryEntitiesParams?, DataList<E>> {
  final Repository<E> repository;

  QueryEntities(this.repository);

  @override
  Future<DataList<E>> execute(QueryEntitiesParams? params) async {
    final entities = await repository.query(
      DataQuery(
        filter: params?.filter,
        cursor: params?.cursor,
        size: params?.size,
      ),
    );

    return entities;
  }
}
