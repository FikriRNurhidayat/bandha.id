import 'package:bandha/infra/data/data_sources/sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/classifier_local_storage.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';

abstract class ClassifierSqliteStorage<T extends Classifier>
    extends SqliteStorage<T>
    implements ClassifierLocalStorage<T> {}
