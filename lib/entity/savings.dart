import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/repositories/repository.dart';

class Savings {
  final String id;
  final String note;
  final double goal;
  final double balance;
  final SavingsStatus status;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? releasedAt;

  late final List<Entry>? entries;
  late final List<Label>? labels;
  late final Account? account;

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

  factory Savings.create({
    required String note,
    required double goal,
    required double balance,
    required SavingsStatus status,
    required String accountId,
  }) {
    return Savings(
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
    labels = value;
    return this;
  }

  Savings withEntries(List<Entry>? value) {
    entries = value;
    return this;
  }

  Savings withAccount(Account? value) {
    account = value;
    return this;
  }

  factory Savings.fromRow(Map<dynamic, dynamic> row) {
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
}

enum SavingsStatus {
  active('Active'),
  released('Released');

  final String label;
  const SavingsStatus(this.label);
}
