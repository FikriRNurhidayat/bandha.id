import 'package:banda/entity/account.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entity.dart';
import 'package:banda/entity/label.dart';

class Entry extends Entity {
  String id;
  String note;
  double amount;
  EntryStatus status;
  DateTime issuedAt;
  bool readonly;
  String accountId;
  String categoryId;
  DateTime createdAt;
  DateTime updatedAt;
  late List<Label>? labels;
  late Category? category;
  late Account? account;

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

  Entry setLabels(List<Label>? labels) {
    this.labels = labels;
    return this;
  }

  Entry setAccount(Account? account) {
    this.account = account;
    return this;
  }

  Entry setCategory(Category? category) {
    this.category = category;
    return this;
  }

  Entry copyWith({
    String? id,
    String? note,
    double? amount,
    EntryStatus? status,
    DateTime? timestamp,
    bool? readonly,
    String? accountId,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Label>? labels,
  }) {
    return Entry(
      id: id ?? this.id,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      issuedAt: timestamp ?? this.issuedAt,
      readonly: readonly ?? this.readonly,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    )..labels = labels ?? this.labels;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "note": note,
      "amount": amount,
      "status": status,
      "timestamp": issuedAt,
      "readonly": readonly,
      "accountId": accountId,
      "categoryId": categoryId,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "labelIds": labels?.map((label) => label.id).toList() ?? [],
    };
  }

  factory Entry.writeable({
    required String note,
    required double amount,
    required EntryStatus status,
    required DateTime timestamp,
    required String accountId,
    required String categoryId,
  }) {
    return Entry.create(
      note: note,
      amount: amount,
      status: status,
      timestamp: timestamp,
      readonly: false,
      accountId: accountId,
      categoryId: categoryId,
    );
  }

  factory Entry.readable({
    required String note,
    required double amount,
    required EntryStatus status,
    required DateTime timestamp,
    required String accountId,
    required String categoryId,
  }) {
    return Entry.create(
      note: note,
      amount: amount,
      status: status,
      timestamp: timestamp,
      readonly: true,
      accountId: accountId,
      categoryId: categoryId,
    );
  }

  factory Entry.create({
    required String note,
    required double amount,
    required EntryStatus status,
    required DateTime timestamp,
    required bool readonly,
    required String accountId,
    required String categoryId,
  }) {
    return Entry(
      id: Entity.getId(),
      note: note,
      amount: amount,
      status: status,
      issuedAt: timestamp,
      readonly: readonly,
      accountId: accountId,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Entry.fromRow(Map<dynamic, dynamic> row) {
    return Entry(
      id: row["id"],
      note: row["note"],
      amount: row["amount"],
      status: EntryStatus.values.firstWhere(
        (e) => e.label == row["status"],
        orElse: () => EntryStatus.unknown,
      ),
      issuedAt: DateTime.parse(row["timestamp"]),
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
