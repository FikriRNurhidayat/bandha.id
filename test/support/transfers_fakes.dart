import 'package:bandha/core/domain/constants/system_categories.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_reader.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

import 'fakes.dart';
import 'fixtures.dart';

Category makeTransferCategory() => makeCategory(
  id: SystemCategories.transferId,
  name: "Transfer",
  readOnly: true,
);

Label makeFeeLabel() =>
    makeLabel(id: SystemLabels.feeId, name: "Fee", readOnly: true);
Label makeCreditLabel() =>
    makeLabel(id: SystemLabels.creditId, name: "Credit", readOnly: true);
Label makeDebitLabel() =>
    makeLabel(id: SystemLabels.debitId, name: "Debit", readOnly: true);

/// Builds a hydrated transfer. Fee entries are attached only when their
/// amount is given.
Transfer makeTransfer({
  String? id,
  String? note = "Move",
  Journal? debitJournal,
  Journal? creditJournal,
  double debitAmount = 10000,
  double creditAmount = -10000,
  double? debitFeeAmount,
  double? creditFeeAmount,
  DateTime? issuedAt,
}) {
  final dj = debitJournal ?? makeJournal(name: "Debit");
  final cj = creditJournal ?? makeJournal(name: "Credit");
  final category = makeTransferCategory();
  final at = issuedAt ?? fixedTime;

  Entry entry(Journal j, double amount, Iterable<Label> labels) => makeEntry(
    note: note,
    amount: amount,
    readOnly: true,
    journal: j,
    category: category,
    labels: labels,
    issuedAt: at,
  );

  final debit = entry(dj, debitAmount, [makeDebitLabel()]);
  final credit = entry(cj, creditAmount, [makeCreditLabel()]);
  final debitFee = debitFeeAmount == null
      ? null
      : entry(dj, debitFeeAmount, [makeDebitLabel(), makeFeeLabel()]);
  final creditFee = creditFeeAmount == null
      ? null
      : entry(cj, creditFeeAmount, [makeCreditLabel(), makeFeeLabel()]);

  final transfer = Transfer(
    id: id ?? "transfer-1",
    note: note,
    creditId: credit.id,
    creditFeeId: creditFee?.id,
    debitId: debit.id,
    debitFeeId: debitFee?.id,
    issuedAt: at,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  );

  for (final e in [debit, debitFee, credit, creditFee].whereType<Entry>()) {
    e.of(transfer);
  }

  return transfer
      .withDebit(debit)
      .withDebitFee(debitFee)
      .withCredit(credit)
      .withCreditFee(creditFee);
}

class FakeTransferRepository extends InMemoryRepository<Transfer>
    implements TransferRepository {
  FakeTransferRepository({super.seed});
}

class FakeCategoryReader extends InMemoryRepository<Category>
    implements CategoryReader {
  FakeCategoryReader({super.seed});
}

class FakeJournalReader extends InMemoryRepository<Journal>
    implements JournalReader {
  FakeJournalReader({super.seed});
}

class FakeLabelReader extends InMemoryRepository<Label> implements LabelReader {
  FakeLabelReader({super.seed});

  @override
  Future<Map<String, Iterable<Label>>> groupByEntryIds(
    Iterable<String> entryIds,
  ) => throw UnimplementedError();

  @override
  Future<Map<String, Iterable<Label>>> groupByFundIds(
    Iterable<String> fundIds,
  ) => throw UnimplementedError();
}

class FakeEntryReader extends InMemoryRepository<Entry> implements EntryReader {
  FakeEntryReader({super.seed});

  final List<List<String>> requestedIds = [];

  @override
  Future<Iterable<Entry>> getAll(Iterable<String> ids) {
    requestedIds.add(ids.toList());
    return super.getAll(ids);
  }

  @override
  Future<Entry?> whereLastControlledBy(
    Controllable controllable, {
    DataFilter? filter,
  }) => throw UnimplementedError();
}

class FakeEntryRepository extends InMemoryRepository<Entry>
    implements EntryRepository {
  FakeEntryRepository({super.seed});

  @override
  Future<Iterable<Entry>> controlledBy(
    Controller controller, {
    DataFilter? filter,
  }) => throw UnimplementedError();

  @override
  Future<Iterable<Entry>> controllableBy(
    Controllable controllable, {
    DataFilter? filter,
  }) => throw UnimplementedError();

  @override
  Future<DataList<Entry>> queryByController(
    Controller controller,
    DataQuery? query,
  ) => throw UnimplementedError();

  @override
  Future<DataList<Entry>> queryByControlable(
    Controllable controlable,
    DataQuery? query,
  ) => throw UnimplementedError();
}

/// Records what it is asked to write without raising events.
class FakeEntryWriter implements EntryWriter {
  final List<Entry> created = [];
  final List<DataChange<Entry>> updated = [];
  final List<Entry> destroyed = [];
  final List<DataChangeSet<Entry>> executed = [];

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
  Future<Iterable<Entry>> createAll(Iterable<Entry> entries) async {
    created.addAll(entries);
    return entries;
  }

  @override
  Future<Entry> create(Entry entry) async {
    created.add(entry);
    return entry;
  }

  @override
  Future<Iterable<Entry>> updateAll(DataChangeList<Entry> changes) async {
    updated.addAll(changes);
    return changes.after;
  }

  @override
  Future<Entry> update(DataChange<Entry> change) async {
    updated.add(change);
    return change.after;
  }

  @override
  Future<void> destroyAll(Iterable<Entry> entries) async =>
      destroyed.addAll(entries);

  @override
  Future<void> destroy(Entry entry) async => destroyed.add(entry);

  @override
  Future<void> execute(DataChangeSet<Entry> changeSet) async {
    executed.add(changeSet);
    created.addAll(changeSet.createList);
    updated.addAll(changeSet.updateList);
    destroyed.addAll(changeSet.destroyList);
  }

  @override
  DataChangeSet<Entry> plan() => DataChangeSet<Entry>();
}

/// Seeded readers for the system category/labels used by transfers.
FakeCategoryReader transferCategoryReader() =>
    FakeCategoryReader(seed: [makeTransferCategory()]);

FakeLabelReader transferLabelReader() => FakeLabelReader(
  seed: [makeFeeLabel(), makeCreditLabel(), makeDebitLabel()],
);
