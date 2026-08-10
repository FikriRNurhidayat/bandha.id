import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/data/data_sources/party_local_storage.dart';
import 'package:bandha/modules/classifiers/data/repositories/classifier_repository_impl.dart';
import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:bandha/modules/classifiers/domain/ports/party_reader.dart';
import 'package:bandha/modules/classifiers/domain/repositories/party_repository.dart';

class PartyRepositoryImpl extends ClassifierRepositoryImpl<Party>
    implements PartyRepository, PartyReader {
  PartyRepositoryImpl(super.localStorage);

  factory PartyRepositoryImpl.build(DependencyContainer c) {
    return PartyRepositoryImpl(c.get<PartyLocalStorage>());
  }
}
