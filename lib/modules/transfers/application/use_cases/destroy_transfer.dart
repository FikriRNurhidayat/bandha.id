import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class DestroyTransfer extends DestroyEntity<Transfer> {
  final EntryWriter entryWriter;
  final UnitOfWork unitOfWork;

  DestroyTransfer(
    super.repository, {
    required this.entryWriter,
    required this.unitOfWork,
  });

  factory DestroyTransfer.build(DependencyContainer c) {
    return DestroyTransfer(
      c.get<TransferRepository>(),
      entryWriter: c.get<EntryWriter>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  @override
  Future<void> execute(String id) async {
    return unitOfWork.execute(() async {
      final transfer = await repository.get(id);
      await repository.destroy(transfer);
      await entryWriter.destroyAll(transfer.entries);
    });
  }
}
