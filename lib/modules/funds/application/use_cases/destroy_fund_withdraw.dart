import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/entries/domain/ports/entry_reader.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/funds/domain/repositories/fund_repository.dart';

class DestroyFundWithdrawParams {
  final String fundId;
  final String entryId;

  DestroyFundWithdrawParams({required this.fundId, required this.entryId});
}

class DestroyFundWithdraw extends UseCase<DestroyFundWithdrawParams, void> {
  final FundRepository fundRepository;
  final EntryWriter entryWriter;
  final EntryReader entryReader;
  final UnitOfWork unitOfWork;

  DestroyFundWithdraw({
    required this.fundRepository,
    required this.unitOfWork,
    required this.entryWriter,
    required this.entryReader,
  });

  factory DestroyFundWithdraw.fromContainer(DependencyContainer c) {
    return DestroyFundWithdraw(
      fundRepository: c.get<FundRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      entryWriter: c.get<EntryWriter>(),
      entryReader: c.get<EntryReader>(),
    );
  }

  @override
  Future<void> execute(DestroyFundWithdrawParams params) async {
    return unitOfWork.execute(() async {
      final fund = await fundRepository.get(params.fundId);
      final entry = await entryReader.get(params.entryId);

      await fundRepository.save(fund.deposit(entry.amount));
      await entryWriter.destroy(entry);
    });
  }
}
