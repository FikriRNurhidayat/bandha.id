import 'package:bandha/core/domain/ports/domain_reader.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';

abstract class ClassifierReader<T extends Classifier<T>> extends DomainReader<T> {}
