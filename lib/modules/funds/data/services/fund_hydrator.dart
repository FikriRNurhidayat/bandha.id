import 'package:bandha/core/data/services/hydrator.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class FundHydrator implements Hydrator<Fund> {
  final JournalReader journalReader;
  final CategoryReader categoryReader;
  final LabelReader labelReader;

  FundHydrator({
    required this.journalReader,
    required this.categoryReader,
    required this.labelReader,
  });

  factory FundHydrator.fromContainer(DependencyContainer c) {
    return FundHydrator(
      journalReader: c.get<JournalReader>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
    );
  }

  @override
  Future<Fund> hydrate(Fund fund) async {
    final result = await hydrateAll([fund]);
    return result.first;
  }

  @override
  Future<Iterable<Fund>> hydrateAll(Iterable<Fund> funds) async {
    final journalById = await mapJournals(
      funds.map((e) => e.journalId).toSet(),
    );

    final categoryById = await mapCategories(
      funds.map((e) => e.categoryId).toSet(),
    );

    final labelByFundIds = await mapLabels(funds.map((e) => e.id).toSet());

    return funds.map((fund) {
      final journal = journalById[fund.journalId]!;
      final category = categoryById[fund.categoryId]!;
      final labels = labelByFundIds[fund.id] ?? [];

      return fund
          .withJournal(journal)
          .withCategory(category)
          .withLabels(labels);
    });
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

  Future<Map<String, Iterable<Label>>> mapLabels(Iterable<String> fundIds) {
    return labelReader.groupByFundIds(fundIds);
  }
}
