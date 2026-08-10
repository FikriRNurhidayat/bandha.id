import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';

class GetEntry extends GetEntity<Entry> {
  final EntryRepository entryRepository;

  GetEntry({required this.entryRepository}) : super(entryRepository);

  factory GetEntry.build(DependencyContainer c) {
    return GetEntry(entryRepository: c.get<EntryRepository>());
  }

  @override
  Repository<Entry> get repository => entryRepository;
}
