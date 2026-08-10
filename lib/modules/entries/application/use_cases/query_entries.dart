import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';

class QueryEntries extends QueryEntities<Entry> {
  final EntryRepository entryRepository;

  QueryEntries({required this.entryRepository}) : super(entryRepository);

  factory QueryEntries.build(DependencyContainer c) {
    return QueryEntries(entryRepository: c.get<EntryRepository>());
  }

  @override
  Repository<Entry> get repository => entryRepository;
}
