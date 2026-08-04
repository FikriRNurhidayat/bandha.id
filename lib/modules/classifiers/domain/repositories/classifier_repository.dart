import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';

abstract class ClassifierRepository<T extends Classifier<T>> extends Repository<T> {}
