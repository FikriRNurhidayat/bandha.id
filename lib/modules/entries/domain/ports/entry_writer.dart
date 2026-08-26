import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';

abstract class EntryWriter {
  Entry readOnly({
    required String journalId,
    required String categoryId,
    required double amount,
    required DateTime issuedAt,
    String? note,
  });

  Future<Iterable<Entry>> createAll(Iterable<Entry> entries);
  Future<Entry> create(Entry entry);
  Future<Iterable<Entry>> updateAll(DataChangeList<Entry> changes);
  Future<Entry> update(DataChange<Entry> change);
  Future<void> destroyAll(Iterable<Entry> entries);
  Future<void> destroy(Entry entry);
  Future<void> execute(DataChangeSet<Entry> changeSet);
  DataChangeSet<Entry> plan();
}
