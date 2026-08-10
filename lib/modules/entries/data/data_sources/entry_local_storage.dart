import 'package:bandha/core/data/data_sources/local_storage.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';

abstract class EntryLocalStorage extends LocalStorage<Entry> {
  Future<Iterable<Entry>> controlledBy(Controller controller);
  Future<Iterable<Entry>> controllableBy(Controllable controllable);

  Future<DataList<Entry>> queryByController(
    Controller controller,
    DataQuery? query,
  );

  Future<DataList<Entry>> queryByControllable(
    Controllable controlable,
    DataQuery? query,
  );
}
