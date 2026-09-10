import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/ports/domain_reader.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';

abstract class EntryReader extends DomainReader<Entry> {
  Future<Entry?> whereLastControlledBy(
    Controllable controllable, {
    DataFilter? filter,
  });
}
