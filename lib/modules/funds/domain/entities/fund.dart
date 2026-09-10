import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';

class Fund extends Controllable {
  @override
  final String id;
  final String? note;
  final double amount;
  final double balance;
  final double raised;
  final FundStatus status;
  final String categoryId;
  final String journalId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? releasedAt;

  Fund({
    required this.id,
    required this.note,
    required this.amount,
    required this.balance,
    required this.raised,
    required this.status,
    required this.categoryId,
    required this.journalId,
    required this.createdAt,
    required this.updatedAt,
    required this.releasedAt,
  });

  late Iterable<Label> labels;
  late Category category;
  late Journal journal;

  Iterable<String> get labelIds => labels.map((label) => label.id);

  static Fund? tryRow(Map<String, dynamic>? row) {
    if (row == null) return null;
    return Fund.fromRow(row);
  }

  factory Fund.create({
    String? note,
    required double amount,
    required String categoryId,
    required String journalId,
    DateTime? releasedAt,
  }) {
    final now = DateTime.now();

    return Fund(
      id: Entity.getId(),
      note: note,
      amount: amount,
      balance: 0,
      raised: 0,
      status: FundStatus.active,
      categoryId: categoryId,
      journalId: journalId,
      createdAt: now,
      updatedAt: now,
      releasedAt: releasedAt,
    );
  }

  factory Fund.fromRow(Map<String, dynamic> row) {
    return Fund(
      id: row["id"],
      note: row["note"],
      amount: row["amount"],
      balance: row["balance"],
      raised: row["raised"],
      status: FundStatus.parse(row["status"]),
      categoryId: row["category_id"],
      journalId: row["journal_id"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
      releasedAt: row["released_at"] != null
          ? DateTime.parse(row["released_at"])
          : null,
    );
  }

  double get progress => (raised / amount);

  Fund deposit(double amount) {
    return copyWith(
      balance: balance + amount.abs(),
      raised: raised + amount.abs(),
    );
  }

  Fund disburse(double amount) {
    return copyWith(balance: balance - amount.abs());
  }

  Fund withdraw(double amount) {
    return copyWith(
      balance: balance - amount.abs(),
      raised: raised - amount.abs(),
    );
  }

  Fund withCategory(Category category) {
    this.category = category;
    return this;
  }

  Fund withJournal(Journal journal) {
    this.journal = journal;
    return this;
  }

  Fund withLabels(Iterable<Label> labels) {
    this.labels = labels;
    return this;
  }

  Fund copyWith({
    String? note,
    double? amount,
    double? balance,
    double? raised,
    FundStatus? status,
    String? categoryId,
    String? journalId,
    DateTime? releasedAt,
  }) {
    return Fund(
      id: id,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      raised: raised ?? this.raised,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      journalId: journalId ?? this.journalId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      releasedAt: releasedAt ?? this.releasedAt,
    ).withLabels(labels).withCategory(category).withJournal(journal);
  }
}

enum FundStatus {
  active('Active'),
  released('Released');

  final String label;
  const FundStatus(this.label);

  bool get isReleased {
    return FundStatus.released == this;
  }

  @override
  String toString() {
    return label;
  }

  factory FundStatus.parse(String value) {
    return values.firstWhere((e) => e.label == value);
  }
}
