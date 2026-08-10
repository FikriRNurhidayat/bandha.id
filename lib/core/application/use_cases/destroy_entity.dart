import 'package:bandha/core/domain/repository.dart';

class DestroyEntity<E> {
  final Repository<E> repository;

  DestroyEntity(this.repository);

  Future<void> execute(String id) async {
    final e = await repository.get(id);
    return repository.destroy(e);
  }
}
