import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/data/data_sources/label_local_storage.dart';
import 'package:bandha/modules/classifiers/data/repositories/classifier_repository_impl.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/classifiers/domain/repositories/label_repository.dart';

class LabelRepositoryImpl extends ClassifierRepositoryImpl<Label>
    implements LabelRepository, LabelReader {
  LabelRepositoryImpl(LabelLocalStorage super.localStorage);

  LabelLocalStorage get labelStorage => localStorage as LabelLocalStorage;

  factory LabelRepositoryImpl.fromContainer(DependencyContainer c) {
    return LabelRepositoryImpl(c.get<LabelLocalStorage>());
  }

  @override
  Future<Map<String, Iterable<Label>>> groupByEntryIds(
    Iterable<String> entryIds,
  ) {
    return labelStorage.groupByEntryIds(entryIds);
  }

  @override
  Future<Map<String, Iterable<Label>>> groupByFundIds(
    Iterable<String> fundIds,
  ) {
    return labelStorage.groupByFundIds(fundIds);
  }
}
