import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/repositories/repository.dart';

class Saving {
  final String id;
  final String note;
  final double goal;
  final double balance;
  final SavingStatus status;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? releasedAt;

  late final List<Entry>? entries;
  late final List<Label>? labels;
  late final Account? account;

  Saving({
    required this.id,
    required this.note,
    required this.goal,
    required this.balance,
    required this.status,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    required this.releasedAt,
  });

  toMap() {
    return {
      id: id,
      note: note,
      goal: goal,
      balance: balance,
      status: status,
      accountId: accountId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      releasedAt: releasedAt,
    };
  }

  factory Saving.create({
    required String note,
    required double goal,
    required double balance,
    required SavingStatus status,
    required String accountId,
  }) {
    return Saving(
      id: Repository.getId(),
      note: note,
      goal: goal,
      balance: balance,
      status: status,
      accountId: accountId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      releasedAt: null,
    );
  }

  canDispense() {
    return status != SavingStatus.released;
  }

  canGrow() {
    return status != SavingStatus.released && balance < goal;
  }

  copyWith({
    String? note,
    double? goal,
    double? balance,
    SavingStatus? status,
    String? accountId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? releasedAt,
  }) {
    return Saving(
      id: id,
      note: note ?? this.note,
      goal: goal ?? this.goal,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }

  double getProgress() {
    return (balance.toDouble() / goal.toDouble());
  }

  Saving applyDelta(EntryType type, double delta) {
    return copyWith(
      balance: balance + (delta * (type == EntryType.income ? -1 : 1)),
    );
  }

  Saving applyEntry(Entry entry) {
    return copyWith(balance: balance + (entry.amount * -1));
  }

  Saving revokeEntry(Entry entry) {
    return copyWith(balance: balance - (entry.amount * -1));
  }

  Saving withLabels(List<Label>? value) {
    labels = value;
    return this;
  }

  Saving withEntries(List<Entry>? value) {
    entries = value;
    return this;
  }

  Saving withAccount(Account? value) {
    account = value;
    return this;
  }

  factory Saving.fromRow(Map<dynamic, dynamic> row) {
    return Saving(
      id: row["id"],
      note: row["note"],
      goal: row["goal"],
      balance: row["balance"],
      status: SavingStatus.values.firstWhere((e) => e.label == row["status"]),
      accountId: row["account_id"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
      releasedAt: DateTime.tryParse(row["released_at"] ?? ""),
    );
  }
}

enum SavingStatus {
  active('Active'),
  released('Released');

  final String label;
  const SavingStatus(this.label);
}
