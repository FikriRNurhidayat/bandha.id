import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/assets/domain/ports/asset_reader.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';

class UpdateAssetBalanceOnEntryDestroyed extends EventHandler<EntryDestroyed> {
  final AssetRepository assetRepository;
  final AssetReader assetReader;

  UpdateAssetBalanceOnEntryDestroyed({
    required this.assetRepository,
    required this.assetReader,
  });

  factory UpdateAssetBalanceOnEntryDestroyed.fromContainer(
    DependencyContainer c,
  ) {
    return UpdateAssetBalanceOnEntryDestroyed(
      assetRepository: c.get<AssetRepository>(),
      assetReader: c.get<AssetReader>(),
    );
  }

  @override
  Future<void> handle(EntryDestroyed event) async {
    await assetRepository.incrementBalance(
      event.snapshot.assetId,
      -event.snapshot.amount,
    );
  }

  @override
  Future<void> handleAll(Iterable<EntryDestroyed> events) async {
    final Set<String> assetIds = {};
    final Map<String, List<EntryDestroyed>> assetEvents = {};

    for (final event in events) {
      assetIds.add(event.snapshot.assetId);
      assetEvents
          .putIfAbsent(event.snapshot.assetId, () => <EntryDestroyed>[event])
          .add(event);
    }

    final assets = await assetReader.getAll(assetIds);
    await assetRepository.saveAll(
      assets.map((asset) {
        final events = assetEvents[asset.id];
        if (events == null) return asset;

        double delta = 0;
        for (final event in events) {
          delta += event.snapshot.amount;
        }

        if (delta == 0) return asset;

        return asset.copyWith(balance: asset.balance - delta);
      }),
    );
  }
}
