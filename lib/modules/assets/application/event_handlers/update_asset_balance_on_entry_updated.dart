import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class UpdateAssetBalanceOnEntryUpdated extends EventHandler<EntryUpdated> {
  final AssetRepository assetRepository;

  UpdateAssetBalanceOnEntryUpdated(this.assetRepository);

  factory UpdateAssetBalanceOnEntryUpdated.fromContainer(
    DependencyContainer c,
  ) {
    return UpdateAssetBalanceOnEntryUpdated(c.get<AssetRepository>());
  }

  @override
  Future<void> handle(EntryUpdated event) async {
    if (!event.hasBalanceImpact) {
      return;
    }

    await assetRepository.incrementBalance(
      event.before.assetId,
      -event.before.amount,
    );

    await assetRepository.incrementBalance(
      event.after.assetId,
      event.after.amount,
    );
  }
}
