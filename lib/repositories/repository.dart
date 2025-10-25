import 'package:banda/infra/store.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class Repository {
  final Database db;
  Repository(this.db);
  static Future<Database> connect() => Store().connection;

  static String getId() {
    return Uuid().v4();
  }

  static String getTime() {
    return DateTime.now().toIso8601String();
  }
}
