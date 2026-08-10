import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';

abstract class EntryRepository extends Repository<Entry> {
  Future<Iterable<Entry>> controlledBy(
    Controller controller, {
    DataFilter? filter,
  });

  Future<Iterable<Entry>> controllableBy(
    Controllable controllable, {
    DataFilter? filter,
  });

  Future<DataList<Entry>> queryByController(
    Controller controller,
    DataQuery? query,
  );

  Future<DataList<Entry>> queryByControlable(
    Controllable controlable,
    DataQuery? query,
  );
}
