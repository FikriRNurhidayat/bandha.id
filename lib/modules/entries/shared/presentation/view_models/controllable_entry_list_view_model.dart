import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/types/pager.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/widgets.dart';

typedef CELVDataFilterBuilder<C extends Controllable> = DataFilter Function(C);

class ControllableEntryListViewModel<C extends Controllable>
    extends ChangeNotifier {
  ControllableEntryListViewModel({
    required this.queryEntries,
    required this.getController,
  });

  late final String controllerId;
  final QueryEntities<Entry> queryEntries;
  final GetEntity<C> getController;
  late CELVDataFilterBuilder<C>? dataFilterBuilder;

  AsyncSnapshot<Item<C>> controller = AsyncSnapshot.nothing();
  AsyncSnapshot<Pager<Item<Entry>>> entries = AsyncSnapshot.nothing();

  Set<Item<Entry>> candidates = {};

  factory ControllableEntryListViewModel.build(DependencyContainer c) {
    return ControllableEntryListViewModel(
      queryEntries: c.get<QueryEntities<Entry>>(),
      getController: c.get<GetEntity<C>>(),
    );
  }

  ControllableEntryListViewModel<C> withDataFilter(
    CELVDataFilterBuilder<C>? value,
  ) {
    dataFilterBuilder = value;
    return this;
  }

  ControllableEntryListViewModel<C> withController(String value) {
    controllerId = value;
    return this;
  }

  Future<void> initialize() async {
    controller = AsyncSnapshot.waiting();

    notifyListeners();

    try {
      final controllable = await getController.execute(controllerId);
      controller = AsyncSnapshot.withData(
        ConnectionState.done,
        Item<C>(controllable),
      );
    } catch (error, stackTrace) {
      controller = AsyncSnapshot.withError(
        ConnectionState.done,
        error,
        stackTrace,
      );
    }

    notifyListeners();

    if (controller.hasError) return;

    try {
      final query = await queryEntries.execute(
        filter:
            dataFilterBuilder?.call(controller.requireData.entity) ??
            controller.requireData.entity.dataFilter,
      );

      debugPrint("query: ${query.hits}");

      final models = query.hits.map((entity) {
        final item = entryItemBuilder(entity);
        return item;
      }).toList();
      entries = AsyncSnapshot.withData(
        ConnectionState.done,
        Pager<Item<Entry>>.of(
          models,
        ).withPreviousCursor(query.previous).withNextCursor(query.next),
      );
    } catch (error, stackTrace) {
      entries = AsyncSnapshot.withError(
        ConnectionState.done,
        error,
        stackTrace,
      );
    }

    notifyListeners();
  }

  Item<Entry> entryItemBuilder(Entry entry) {
    return Item<Entry>(entry);
  }

  Future<void> selectAll(Iterable<Item<Entry>> items) async {
    candidates.addAll(items);

    entries = AsyncSnapshot.withData(
      ConnectionState.done,
      entries.requireData.map((item) {
        if (items.contains(item)) {
          item.isSelected = true;
        }

        return item;
      }),
    );

    notifyListeners();
  }

  Future<void> select(Item<Entry> item) async {
    return selectAll([item]);
  }

  Future<void> deselect(Item<Entry> item) async {
    return deselectAll([item]);
  }

  Future<void> deselectAll(Iterable<Item<Entry>> items) async {
    candidates.removeAll(items);

    entries = AsyncSnapshot.withData(
      ConnectionState.done,
      entries.requireData.map((i) {
        if (items.any((item) => item.entity.id == i.entity.id)) {
          i.isSelected = false;
        }

        return i;
      }),
    );

    notifyListeners();
  }

  Future<void> resetSelection() async {
    candidates = {};

    entries = AsyncSnapshot.withData(
      ConnectionState.done,
      entries.requireData.map((i) {
        i.isSelected = false;

        return i;
      }),
    );

    notifyListeners();
  }

  Future<void> removeAll(Iterable<Item<Entry>> items) async {
    entries = AsyncSnapshot.withData(
      ConnectionState.done,
      entries.requireData.where((i) => !items.contains(i)),
    );

    notifyListeners();
  }

  Future<void> remove(Item<Entry> item) async {
    removeAll([item]);
  }

  Future<void> updateAll(Iterable<Item<Entry>> items) async {
    entries = AsyncSnapshot.withData(
      ConnectionState.done,
      entries.requireData.map((i) {
        if (items.contains(i)) {
          return items.firstWhere((item) => item == i);
        }

        return i;
      }),
    );

    notifyListeners();
  }

  Future<void> update(Item<Entry> item) async {
    return updateAll([item]);
  }

  Future<void> destroy(Item<Entry> entry) async {
    return initialize();
  }
}
