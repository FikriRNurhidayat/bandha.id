import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class DestroyTransferParams {
  final String id;

  DestroyTransferParams(this.id);
}

class DestroyTransfer extends UseCase<DestroyTransferParams, void> {
  final TransferRepository transferRepository;
  final EntryWriter entryWriter;
  final UnitOfWork unitOfWork;

  DestroyTransfer({
    required this.entryWriter,
    required this.transferRepository,
    required this.unitOfWork,
  });

  factory DestroyTransfer.fromContainer(DependencyContainer c) {
    return DestroyTransfer(
      transferRepository: c.get<TransferRepository>(),
      entryWriter: c.get<EntryWriter>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  @override
  Future<void> execute(DestroyTransferParams params) async {
    return unitOfWork.execute(() async {
      final transfer = await transferRepository.get(params.id);
      await transferRepository.destroy(transfer);
      await entryWriter.destroyAll(transfer.entries);
    });
  }
}
