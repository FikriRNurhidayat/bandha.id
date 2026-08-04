import 'package:bandha/modules/classifiers/data/data_sources/classifier_local_storage.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';

abstract class LabelLocalStorage extends ClassifierLocalStorage<Label> {
  Future<Map<String, Iterable<Label>>> groupByEntryIds(Iterable<String> entryIds);
  Future<Map<String, Iterable<Label>>> groupByFundIds(Iterable<String> fundIds);
}
