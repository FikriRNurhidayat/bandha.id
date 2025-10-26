import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';

class Saving {
  final String id;
  final String note;
  final double goal;
  final double balance;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  late final List<Entry>? entries;
  late final List<Label>? labels;
  late final Account? account;

  Saving({
    required this.id,
    required this.note,
    required this.goal,
    required this.balance,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
  });

  double getProgress() {
    return (balance.toDouble() / goal.toDouble());
  }

  Saving setLabels(List<Label> value) {
    labels = value;
    return this;
  }

  Saving setEntries(List<Entry> value) {
    entries = value;
    return this;
  }

  Saving setAccount(Account value) {
    account = value;
    return this;
  }

  factory Saving.fromRow(Map<dynamic, dynamic> row) {
    return Saving(
      id: row["id"],
      note: row["note"],
      goal: row["goal"],
      balance: row["balance"],
      accountId: row["account_id"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }
}
