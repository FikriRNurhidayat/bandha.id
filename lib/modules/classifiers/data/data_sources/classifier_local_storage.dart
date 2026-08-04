import 'package:bandha/core/data/data_sources/local_storage.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';

abstract class ClassifierLocalStorage<T extends Classifier>
    extends LocalStorage<T> {}
