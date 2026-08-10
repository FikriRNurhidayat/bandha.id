import 'package:bandha/core/domain/repository.dart';

class GetEntity<E> {
  final Repository<E> repository;

  GetEntity(this.repository);

  Future<E> execute(String id) async {
    return repository.get(id);
  }
}
