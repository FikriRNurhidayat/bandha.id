import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';

final fixedTime = DateTime.utc(2026, 1, 15, 10, 30);

Asset makeAsset({
  String? id,
  String name = "Rupiah",
  String code = "IDR",
  double balance = 0,
}) {
  return Asset(
    id: id ?? Entity.getId(),
    name: name,
    code: code,
    balance: balance,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  );
}

Journal makeJournal({
  String? id,
  String name = "Wallet",
  String holderName = "Me",
  double balance = 0,
  Asset? asset,
}) {
  final a = asset ?? makeAsset();
  return Journal(
    id: id ?? Entity.getId(),
    name: name,
    holderName: holderName,
    balance: balance,
    assetId: a.id,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  ).withAsset(a);
}

Category makeCategory({String? id, String name = "Food", bool readOnly = false}) {
  return Category(
    id: id ?? Entity.getId(),
    name: name,
    readOnly: readOnly,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  );
}

Label makeLabel({String? id, String name = "Tag", bool readOnly = false}) {
  return Label(
    id: id ?? Entity.getId(),
    name: name,
    readOnly: readOnly,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  );
}

/// Builds a fully hydrated entry (journal, asset, category, labels set).
Entry makeEntry({
  String? id,
  String? note = "Lunch",
  double amount = -10000,
  EntryStatus status = EntryStatus.done,
  bool readOnly = false,
  Journal? journal,
  Category? category,
  Iterable<Label> labels = const [],
  Controller? controller,
  DateTime? issuedAt,
}) {
  final j = journal ?? makeJournal();
  final c = category ?? makeCategory();
  return Entry(
        id: id ?? Entity.getId(),
        note: note,
        amount: amount,
        status: status,
        readOnly: readOnly,
        journalId: j.id,
        categoryId: c.id,
        controller: controller,
        issuedAt: issuedAt ?? fixedTime,
        createdAt: fixedTime,
        updatedAt: fixedTime,
      )
      .withJournal(j)
      .withCategory(c)
      .withLabels(labels);
}
