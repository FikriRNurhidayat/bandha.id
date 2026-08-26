import 'package:bandha/core/data/data_sources/local_storage.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';

abstract class JournalLocalStorage extends LocalStorage<Journal> {
  Future<void> balance(String id);
  Future<void> incrementBalance(String id, double delta);
}
