import 'package:bandha/core/domain/ports/domain_reader.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';

abstract class LabelReader extends DomainReader<Label> {
  Future<Map<String, Iterable<Label>>> groupByEntryIds(Iterable<String> entryIds);
  Future<Map<String, Iterable<Label>>> groupByFundIds(Iterable<String> fundIds);
}
