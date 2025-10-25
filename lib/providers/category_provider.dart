import 'package:banda/entity/category.dart';
import 'package:banda/providers/itemable_provider.dart';
import 'package:banda/repositories/category_repository.dart';

class CategoryProvider extends ItemableProvider<Category> {
  final CategoryRepository _repository;

  CategoryProvider(this._repository);

  @override
  Future<List<Category>> search() async {
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
