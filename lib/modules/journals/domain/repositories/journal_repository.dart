import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

abstract class JournalRepository extends Repository<Journal>
    implements JournalReader {
  Future<void> balance(String id);
  Future<void> incrementBalance(String id, double delta);
}
