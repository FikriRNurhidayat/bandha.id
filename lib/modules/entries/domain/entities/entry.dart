import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';

enum EntryStatus {
  pending('Pending'),
  done('Done'),
  unknown('Unknown');

  static EntryStatus parse(String value) {
    return values.firstWhere(
      (e) => e.label == value,
      orElse: () => EntryStatus.unknown,
    );
  }

  bool isPending() {
    return this == EntryStatus.pending;
  }

  bool isDone() {
    return this == EntryStatus.done;
  }

  @override
  toString() {
    return label;
  }

  final String label;
  const EntryStatus(this.label);
}

class Entry extends Entity {
  @override
  final String id;
  String? note;
  final double amount;
  final EntryStatus status;
  final bool readOnly;
  final String journalId;
  final String categoryId;
  final DateTime issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  Controller? controller;

  late Journal journal;
  late Category category;
  Iterable<Label> labels = [];

  Entry({
    required this.id,
    this.note,
    required this.amount,
    required this.status,
    required this.readOnly,
    required this.journalId,
    required this.categoryId,
    this.controller,
    required this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static Entry? tryRow(Map? row) {
    if (row == null) return null;
    return Entry.fromRow(row);
  }

  factory Entry.fromRow(Map row) {
    final controller = Controller.tryRow(row);

    final entry = Entry(
      id: row["id"],
      note: row["name"],
      amount: row["amount"],
      status: EntryStatus.parse(row["status"]),
      readOnly: row["readonly"] == 1,
      journalId: row["journal_id"],
      categoryId: row["category_id"],
      controller: controller,
      issuedAt: DateTime.parse(row["issued_at"]),
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );

    if (row.containsKey("journal") && row["journal"] is Journal) {
      return entry.withJournal(row["journal"]);
    }

    if (row.containsKey("category") && row["category"] is Category) {
      return entry.withCategory(row["category"]);
    }

    if (row.containsKey("labels") && row["labels"] is List<Label>) {
      return entry.withLabels(row["labels"]);
    }

    return entry;
  }

  factory Entry.create({
    required String note,
    required double amount,
    required EntryStatus status,
    Controller? controller,
    required String journalId,
    required String categoryId,
    required DateTime issuedAt,
  }) {
    final now = DateTime.now();

    return Entry(
      id: Entity.getId(),
      note: note,
      amount: amount,
      status: status,
      readOnly: false,
      controller: controller,
      journalId: journalId,
      categoryId: categoryId,
      issuedAt: issuedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Entry.readonly({
    String? note,
    required double amount,
    required EntryStatus status,
    required Controller? controller,
    required String journalId,
    required String categoryId,
    required DateTime issuedAt,
  }) {
    final now = DateTime.now();

    return Entry(
      id: Entity.getId(),
      note: note,
      amount: amount,
      status: status,
      readOnly: true,
      controller: controller,
      journalId: journalId,
      categoryId: categoryId,
      issuedAt: issuedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  Entry withCategory(Category category) {
    this.category = category;
    return this;
  }

  Entry withJournal(Journal journal) {
    this.journal = journal;
    return this;
  }

  Entry withLabels(Iterable<Label> labels) {
    this.labels = labels;
    return this;
  }

  Entry addLabel(Label label) {
    return addLabels([label]);
  }

  Entry addLabels(Iterable<Label> labels) {
    this.labels = this.labels.followedBy(labels);
    return this;
  }

  Entry of(Controllable controllable) {
    controller = controllable.controller;
    return this;
  }

  Entry clone({
    String? note,
    double? amount,
    EntryStatus? status,
    Controller? controller,
    bool? readOnly,
    String? journalId,
    String? categoryId,
    DateTime? issuedAt,
  }) {
    return Entry(
      id: Entity.getId(),
      note: note ?? this.note,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      readOnly: readOnly ?? this.readOnly,
      controller: controller ?? this.controller,
      journalId: journalId ?? this.journalId,
      categoryId: categoryId ?? this.categoryId,
      issuedAt: issuedAt ?? this.issuedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).withJournal(journal).withCategory(category).withLabels(labels);
  }

  Entry copyWith({
    String? note,
    double? amount,
    EntryStatus? status,
    Controller? controller,
    bool? readOnly,
    String? journalId,
    String? categoryId,
    DateTime? issuedAt,
  }) {
    return Entry(
      id: id,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      readOnly: readOnly ?? this.readOnly,
      controller: controller ?? this.controller,
      journalId: journalId ?? this.journalId,
      categoryId: categoryId ?? this.categoryId,
      issuedAt: issuedAt ?? this.issuedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    ).withJournal(journal).withCategory(category).withLabels(labels);
  }

  bool get hasMutableLabels => labels.any((label) => !label.readOnly);
  bool get hasReadOnlyLabels => labels.any((label) => label.readOnly);
  Iterable<Label> get mutableLabels => labels.where((label) => !label.readOnly);
  Iterable<Label> get readOnlyLabels => labels.where((label) => label.readOnly);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "note": note,
      "amount": amount,
      "status": status.toString(),
      "readOnly": readOnly,
      "journal": journal.toJson(),
      "journalId": journalId,
      "categoryId": categoryId,
      "category": category.toJson(),
      "controller": controller?.toJson(),
      "labels": labels.map((label) => label.toJson()).toList(),
      "issuedAt": issuedAt.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
