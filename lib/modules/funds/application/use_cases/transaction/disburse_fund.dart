import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';
import 'package:flutter/material.dart';

class DisburseFund {
  final FundRepository fundRepository;
  final EntryWriter entryWriter;
  final UnitOfWork unitOfWork;
  final LabelReader labelReader;
  final JournalReader journalReader;
  final CategoryReader categoryReader;

  DisburseFund({
    required this.categoryReader,
    required this.entryWriter,
    required this.fundRepository,
    required this.journalReader,
    required this.labelReader,
    required this.unitOfWork,
  });

  factory DisburseFund.build(DependencyContainer c) {
    return DisburseFund(
      categoryReader: c.get<CategoryReader>(),
      entryWriter: c.get<EntryWriter>(),
      fundRepository: c.get<FundRepository>(),
      journalReader: c.get<JournalReader>(),
      labelReader: c.get<LabelReader>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  Future<Entry> execute(
    String fundId, {
    required String? note,
    required double amount,
    required String? categoryId,
    required Iterable<String>? labelIds,
    required DateTime issuedAt,
  }) {
    return unitOfWork.execute(() async {
      final fund = await fundRepository.get(fundId);
      final category = await categoryReader.get(categoryId ?? fund.category.id);
      final effectiveLabelIds =
          labelIds?.where((labelId) => !fund.labelIds.contains(labelId)) ?? [];
      final labels = await labelReader.getAll(
        effectiveLabelIds.followedBy([SystemLabels.disbursementId]),
      );

      await fundRepository.save(fund.disburse(amount));

      final disburseEntry = await entryWriter.create(
        entryWriter
            .readOnly(
              categoryId: category.id,
              journalId: fund.journalId,
              amount: amount.abs(),
              issuedAt: DateTime.now(),
              note: note,
            )
            .of(fund)
            .withLabels(fund.labels.followedBy(labels))
            .withCategory(category)
            .withJournal(fund.journal),
      );

      return disburseEntry;
    });
  }
}
