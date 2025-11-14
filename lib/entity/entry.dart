import 'package:banda/entity/account.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entity.dart';
import 'package:banda/entity/label.dart';

class Entry extends Entity {
  final String id;
  final String note;
  final double amount;
  final EntryStatus status;
  final DateTime issuedAt;
  final bool readonly;
  final String accountId;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  late List<Label> labels;
  late Category category;
  late Account account;

  Entry({
    required this.id,
    required this.note,
    required this.amount,
    required this.status,
    required this.issuedAt,
    required this.readonly,
    required this.accountId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  static compute(EntryType type, double amount) {
    return amount * (type == EntryType.income ? 1 : -1);
  }

  isDone() {
    return status == EntryStatus.done;
  }

  Entry withLabels(List<Label>? labels) {
    if (labels != null) this.labels = labels;
    return this;
  }

  Entry withAccount(Account? account) {
    if (account != null) this.account = account;
    return this;
  }

  Entry withCategory(Category? category) {
    if (category != null) this.category = category;
    return this;
  }

  Entry copyWith({
    String? id,
    String? note,
    double? amount,
    EntryStatus? status,
    DateTime? issuedAt,
    bool? readonly,
    String? accountId,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entry(
      id: id ?? this.id,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      readonly: readonly ?? this.readonly,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      issuedAt: issuedAt ?? this.issuedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "note": note,
      "amount": amount,
      "status": status,
      "issuedAt": issuedAt,
      "readonly": readonly,
      "accountId": accountId,
      "categoryId": categoryId,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "labelIds": labels.map((label) => label.id).toList(),
    };
  }

  factory Entry.forUser({
    required String note,
    required double amount,
    required EntryStatus status,
    required DateTime issuedAt,
    required String accountId,
    required String categoryId,
  }) {
    return Entry.create(
      note: note,
      amount: amount,
      status: status,
      issuedAt: issuedAt,
      readonly: false,
      accountId: accountId,
      categoryId: categoryId,
    );
  }

  factory Entry.bySystem({
    required String note,
    required double amount,
    required EntryStatus status,
    required DateTime issuedAt,
    required String accountId,
    required String categoryId,
  }) {
    return Entry.create(
      note: note,
      amount: amount,
      status: status,
      issuedAt: issuedAt,
      readonly: true,
      accountId: accountId,
      categoryId: categoryId,
    );
  }

  factory Entry.create({
    required String note,
    required double amount,
    required EntryStatus status,
    required DateTime issuedAt,
    required bool readonly,
    required String accountId,
    required String categoryId,
  }) {
    return Entry(
      id: Entity.getId(),
      note: note,
      amount: amount,
      status: status,
      readonly: readonly,
      accountId: accountId,
      categoryId: categoryId,
      issuedAt: issuedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static tryRow(Map? row) {
    if (row == null) return null;
    return Entry.row(row);
  }

  factory Entry.row(Map row) {
    return Entry(
      id: row["id"],
      note: row["note"],
      amount: row["amount"],
      status: EntryStatus.values.firstWhere(
        (e) => e.label == row["status"],
        orElse: () => EntryStatus.unknown,
      ),
      issuedAt: DateTime.parse(row["issued_at"]),
      readonly: row["readonly"] == 1,
      accountId: row["account_id"],
      categoryId: row["category_id"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }
}

enum EntryType {
  income('Income'),
  expense('Expense');

  final String label;
  const EntryType(this.label);
}

enum EntryStatus {
  pending('Pending'),
  done('Done'),
  unknown('Unknown');

  final String label;
  const EntryStatus(this.label);
}
