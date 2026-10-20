import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_reader.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

import 'fakes.dart';
import 'fixtures.dart';

/// Builds a fully hydrated fund (journal, category, labels set).
Fund makeFund({
  String? id,
  String? note = "Holiday",
  double amount = 1000000,
  double balance = 0,
  double raised = 0,
  FundStatus status = FundStatus.active,
  Journal? journal,
  Category? category,
  Iterable<Label> labels = const [],
  DateTime? releasedAt,
}) {
  final j = journal ?? makeJournal();
  final c = category ?? makeCategory(name: "Savings");
  return Fund(
    id: id ?? Entity.getId(),
    note: note,
    amount: amount,
    balance: balance,
    raised: raised,
    status: status,
    categoryId: c.id,
    journalId: j.id,
    createdAt: fixedTime,
    updatedAt: fixedTime,
    releasedAt: releasedAt,
  ).withJournal(j).withCategory(c).withLabels(labels);
}

/// System labels used by fund transactions.
final depositLabel = makeLabel(
  id: SystemLabels.depositId,
  name: "Deposit",
  readOnly: true,
);
final withdrawLabel = makeLabel(
  id: SystemLabels.withdrawId,
  name: "Withdraw",
  readOnly: true,
);
final disbursementLabel = makeLabel(
  id: SystemLabels.disbursementId,
  name: "Disbursement",
  readOnly: true,
);
final releasedLabel = makeLabel(
  id: SystemLabels.releasedId,
  name: "Released",
  readOnly: true,
);
final voidLabel = makeLabel(
  id: SystemLabels.voidId,
  name: "Void",
  readOnly: true,
);

class FakeFundRepository extends InMemoryRepository<Fund>
    implements FundRepository {
  FakeFundRepository({super.seed});
}

/// Map-backed reader; `get` throws when missing, `getAll` keeps request order.
class MapReader<T extends Entity> {
  final Map<String, T> store = {};
  final List<Iterable<String>> getAllCalls = [];

  MapReader([Iterable<T> seed = const []]) {
    for (final entity in seed) {
      store[entity.id] = entity;
    }
  }

  Future<T> get(String id) async {
    final entity = store[id];
    if (entity == null) throw Exception("$T $id not found");
    return entity;
  }

  Future<Iterable<T>> getAll(Iterable<String> ids) async {
    getAllCalls.add(ids.toList());
    return ids.where(store.containsKey).map((id) => store[id]!).toList();
  }
}

class FakeCategoryReader extends MapReader<Category> implements CategoryReader {
  FakeCategoryReader([super.seed]);
}

class FakeJournalReader extends MapReader<Journal> implements JournalReader {
  FakeJournalReader([super.seed]);
}

class FakeLabelReader extends MapReader<Label> implements LabelReader {
  final Map<String, Iterable<Label>> byFundId;
  final Map<String, Iterable<Label>> byEntryId;

  FakeLabelReader([
    super.seed,
    this.byFundId = const {},
    this.byEntryId = const {},
  ]);

  @override
  Future<Map<String, Iterable<Label>>> groupByFundIds(
    Iterable<String> fundIds,
  ) async => {
    for (final id in fundIds)
      if (byFundId.containsKey(id)) id: byFundId[id]!,
  };

  @override
  Future<Map<String, Iterable<Label>>> groupByEntryIds(
    Iterable<String> entryIds,
  ) async => {
    for (final id in entryIds)
      if (byEntryId.containsKey(id)) id: byEntryId[id]!,
  };
}

class FakeEntryReader extends MapReader<Entry> implements EntryReader {
  Entry? lastControlled;
  Controllable? lastControllable;

  FakeEntryReader([super.seed]);

  @override
  Future<Entry?> whereLastControlledBy(
    Controllable controllable, {
    DataFilter? filter,
  }) async {
    lastControllable = controllable;
    return lastControlled;
  }
}

/// Mirrors EntryWriterImpl.readOnly and records every write.
class FakeEntryWriter implements EntryWriter {
  final List<Entry> created = [];
  final List<DataChange<Entry>> updated = [];
  final List<Entry> destroyed = [];

  @override
  Entry readOnly({
    required String journalId,
    required String categoryId,
    required double amount,
    required DateTime issuedAt,
    String? note,
  }) {
    return Entry.readonly(
      note: note,
      amount: amount,
      status: EntryStatus.done,
      controller: null,
      journalId: journalId,
      categoryId: categoryId,
      issuedAt: issuedAt,
    );
  }

  @override
  Future<Entry> create(Entry entry) async {
    created.add(entry);
    return entry;
  }

  @override
  Future<Iterable<Entry>> createAll(Iterable<Entry> entries) async {
    created.addAll(entries);
    return entries;
  }

  @override
  Future<Entry> update(DataChange<Entry> change) async {
    updated.add(change);
    return change.after;
  }

  @override
  Future<Iterable<Entry>> updateAll(DataChangeList<Entry> changes) async {
    updated.addAll(changes);
    return changes.after;
  }

  @override
  Future<void> destroy(Entry entry) async => destroyed.add(entry);

  @override
  Future<void> destroyAll(Iterable<Entry> entries) async =>
      destroyed.addAll(entries);

  @override
  Future<void> execute(DataChangeSet<Entry> changeSet) async {
    created.addAll(changeSet.createList);
    updated.addAll(changeSet.updateList);
    destroyed.addAll(changeSet.destroyList);
  }

  @override
  DataChangeSet<Entry> plan() => DataChangeSet<Entry>();
}
