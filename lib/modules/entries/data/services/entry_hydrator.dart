import 'package:bandha/core/data/services/hydrator.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';
import 'package:flutter/widgets.dart';

class EntryHydrator implements Hydrator<Entry> {
  final JournalReader journalReader;
  final CategoryReader categoryReader;
  final LabelReader labelReader;

  EntryHydrator({
    required this.journalReader,
    required this.categoryReader,
    required this.labelReader,
  });

  factory EntryHydrator.build(DependencyContainer c) {
    return EntryHydrator(
      journalReader: c.get<JournalReader>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
    );
  }

  @override
  Future<Entry> hydrate(Entry entry) async {
    final result = await hydrateAll([entry]);
    return result.first;
  }

  @override
  Future<Iterable<Entry>> hydrateAll(Iterable<Entry> entries) async {
    try {
      final journalById = await mapJournals(
        entries.map((e) => e.journalId).toSet(),
      );

      final categoryById = await mapCategories(
        entries.map((e) => e.categoryId).toSet(),
      );

      final labelByEntryIds = await mapLabels(entries.map((e) => e.id).toSet());

      return entries.map((entry) {
        final journal = journalById[entry.journalId]!;
        final category = categoryById[entry.categoryId]!;
        final labels = labelByEntryIds[entry.id] ?? [];

        return entry
            .withJournal(journal)
            .withCategory(category)
            .withLabels(labels);
      });
    } catch (error, stackTrace) {
      debugPrint("entryHydrator/hydrateAll: error: $error");
      debugPrint("entryHydrator/hydrateAll: stackTrace: $stackTrace");
      rethrow;
    }
  }

  Future<Map<String, Journal>> mapJournals(Iterable<String> journalIds) async {
    final journals = await journalReader.getAll(journalIds);
    return {for (final journal in journals) journal.id: journal};
  }

  Future<Map<String, Category>> mapCategories(
    Iterable<String> categoryIds,
  ) async {
    final categories = await categoryReader.getAll(categoryIds);
    return {for (final category in categories) category.id: category};
  }

  Future<Map<String, Iterable<Label>>> mapLabels(Iterable<String> entryIds) {
    return labelReader.groupByEntryIds(entryIds);
  }
}
