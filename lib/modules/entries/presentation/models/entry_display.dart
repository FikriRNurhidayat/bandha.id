import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';

class EntryDisplay {
  final Entry entry;

  EntryDisplay(this.entry);

  factory EntryDisplay.of(Entry entry) {
    return EntryDisplay(entry);
  }

  bool get hasReadOnlyLabels => entry.labels.any((label) => label.readOnly);
  Iterable<Label> get readOnlyLabels =>
      entry.labels.where((label) => label.readOnly);

  bool get hasMutableLabels => entry.labels.any((label) => !label.readOnly);
  Iterable<Label> get mutableLabels =>
      entry.labels.where((label) => label.readOnly);
}
