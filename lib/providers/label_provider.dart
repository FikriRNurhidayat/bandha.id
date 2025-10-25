import 'package:banda/entity/label.dart';
import 'package:banda/providers/itemable_provider.dart';
import 'package:banda/repositories/label_repository.dart';

class LabelProvider extends ItemableProvider<Label> {
  final LabelRepository _repository;

  LabelProvider(this._repository);

  @override
  Future<List<Label>> search() async {
    return _repository.search();
  }

  @override
  Future<void> add({required String name}) async {
    await _repository.create(name: name);
    notifyListeners();
  }

  @override
  Future<void> update({required String id, required String name}) async {
    await _repository.update(id: id, name: name);
    notifyListeners();
  }

  @override
  Future<void> remove(String id) async {
    await _repository.delete(id);
    notifyListeners();
  }
}
