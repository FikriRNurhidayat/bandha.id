import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class UpdateAssetBalanceOnEntryCreated extends EventHandler<EntryCreated> {
  final AssetRepository assetRepository;

  UpdateAssetBalanceOnEntryCreated(this.assetRepository);

  factory UpdateAssetBalanceOnEntryCreated.build(DependencyContainer c) {
    return UpdateAssetBalanceOnEntryCreated(c.get<AssetRepository>());
  }

  @override
  Future<void> handle(EntryCreated event) async {
    await assetRepository.incrementBalance(
      event.snapshot.assetId,
      event.snapshot.amount,
    );
  }
}
