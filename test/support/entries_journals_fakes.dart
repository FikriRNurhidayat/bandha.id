import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/ports/domain_reader.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/ports/asset_reader.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

import 'fakes.dart';

/// Map-backed reader that records requested ids.
class FakeReader<T extends Entity> implements DomainReader<T> {
  final Map<String, T> store = {};
  final List<Iterable<String>> getAllCalls = [];

  FakeReader([Iterable<T> seed = const []]) {
    for (final entity in seed) {
      store[entity.id] = entity;
    }
  }

  @override
  Future<T> get(String id) async {
    final entity = store[id];
    if (entity == null) throw Exception("$T $id not found");
    return entity;
  }

  @override
  Future<Iterable<T>> getAll(Iterable<String> ids) async {
    getAllCalls.add(ids.toList());
    return ids.where(store.containsKey).map((id) => store[id]!).toList();
  }
}

class FakeJournalReader extends FakeReader<Journal> implements JournalReader {
  FakeJournalReader([super.seed]);
}

class FakeCategoryReader extends FakeReader<Category>
    implements CategoryReader {
  FakeCategoryReader([super.seed]);
}

class FakeAssetReader extends FakeReader<Asset> implements AssetReader {
  FakeAssetReader([super.seed]);
}

class FakeLabelReader extends FakeReader<Label> implements LabelReader {
  final Map<String, Iterable<Label>> labelsByEntryId;
  final Map<String, Iterable<Label>> labelsByFundId;

  FakeLabelReader([
    super.seed,
    this.labelsByEntryId = const {},
    this.labelsByFundId = const {},
  ]);

  @override
  Future<Map<String, Iterable<Label>>> groupByEntryIds(
    Iterable<String> entryIds,
  ) async {
    return {
      for (final id in entryIds)
        if (labelsByEntryId.containsKey(id)) id: labelsByEntryId[id]!,
    };
  }

  @override
  Future<Map<String, Iterable<Label>>> groupByFundIds(
    Iterable<String> fundIds,
  ) async {
    return {
      for (final id in fundIds)
        if (labelsByFundId.containsKey(id)) id: labelsByFundId[id]!,
    };
  }
}

class FakeEntryRepository extends InMemoryRepository<Entry>
    implements EntryRepository {
  FakeEntryRepository({super.seed});

  @override
  Future<Iterable<Entry>> controlledBy(
    Controller controller, {
    DataFilter? filter,
  }) async {
    return store.values
        .where(
          (e) =>
              e.controller?.id == controller.id &&
              e.controller?.type == controller.type,
        )
        .toList();
  }

  @override
  Future<Iterable<Entry>> controllableBy(
    Controllable controllable, {
    DataFilter? filter,
  }) {
    return controlledBy(controllable.controller, filter: filter);
  }

  @override
  Future<DataList<Entry>> queryByController(
    Controller controller,
    DataQuery? query,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<DataList<Entry>> queryByControlable(
    Controllable controlable,
    DataQuery? query,
  ) {
    throw UnimplementedError();
  }
}

typedef BalanceIncrement = ({String id, double delta});

class FakeJournalRepository extends InMemoryRepository<Journal>
    implements JournalRepository {
  final List<String> balanced = [];
  final List<BalanceIncrement> increments = [];

  FakeJournalRepository({super.seed});

  @override
  Future<void> balance(String id) async => balanced.add(id);

  @override
  Future<void> incrementBalance(String id, double delta) async {
    increments.add((id: id, delta: delta));
  }
}
