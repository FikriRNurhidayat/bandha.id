import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/domain/repository.dart';

class GetEntityParams {
  final String id;

  GetEntityParams(this.id);
}

class GetEntity<E> extends UseCase<GetEntityParams, E> {
  final Repository<E> repository;

  GetEntity(this.repository);

  @override
  Future<E> execute(GetEntityParams params) async {
    return repository.get(params.id);
  }
}
