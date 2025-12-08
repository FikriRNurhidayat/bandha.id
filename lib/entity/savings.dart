import 'package:banda/entity/account.dart';
import 'package:banda/entity/controlable.dart';
import 'package:banda/entity/entity.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/types/controller.dart';

class Savings extends Controlable {
  final String id;
  final String note;
  final double goal;
  final double balance;
  final SavingsStatus status;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? releasedAt;

  late List<Entry> entries;
  late List<Label> labels;
  late Account account;

  Savings({
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

  get labelIds {
    return labels.map((label) => label.id).toList();
  }

  factory Savings.create({
    required String note,
    required double goal,
    required double balance,
    required SavingsStatus status,
    required String accountId,
  }) {
    return Savings(
      id: Entity.getId(),
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
    return status != SavingsStatus.released;
  }

  canGrow() {
    return status != SavingsStatus.released && balance < goal;
  }

  copyWith({
    String? note,
    double? goal,
    double? balance,
    SavingsStatus? status,
    String? accountId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? releasedAt,
  }) {
    return Savings(
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

  Savings applyDelta(EntryType type, double delta) {
    return copyWith(
      balance: balance + (delta * (type == EntryType.income ? -1 : 1)),
    );
  }

  Savings applyEntry(Entry entry) {
    return copyWith(balance: balance + (entry.amount * -1));
  }

  Savings revokeEntry(Entry entry) {
    return copyWith(balance: balance - (entry.amount * -1));
  }

  Savings withLabels(List<Label>? value) {
    if (value != null) labels = value;
    return this;
  }

  Savings withEntries(List<Entry>? value) {
    if (value != null) entries = value;
    return this;
  }

  Savings withAccount(Account? value) {
    if (value != null) account = value;
    return this;
  }

  factory Savings.row(Map<dynamic, dynamic> row) {
    return Savings(
      id: row["id"],
      note: row["note"],
      goal: row["goal"],
      balance: row["balance"],
      status: SavingsStatus.values.firstWhere((e) => e.label == row["status"]),
      accountId: row["account_id"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
      releasedAt: DateTime.tryParse(row["released_at"] ?? ""),
    );
  }

  @override
  Controller toController() {
    return Controller.savings(id);
  }
}

enum SavingsStatus {
  active('Active'),
  released('Released');

  final String label;
  const SavingsStatus(this.label);
}
