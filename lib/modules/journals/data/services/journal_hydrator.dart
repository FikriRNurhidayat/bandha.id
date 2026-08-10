import 'package:bandha/core/data/services/hydrator.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/assets/domain/ports/asset_reader.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';

class JournalHydrator implements Hydrator<Journal> {
  final AssetReader assetProvider;

  JournalHydrator({required this.assetProvider});

  factory JournalHydrator.build(DependencyContainer c) {
    return JournalHydrator(assetProvider: c.get<AssetReader>());
  }

  @override
  Future<Journal> hydrate(Journal journal) async {
    final journals = await hydrateAll([journal]);
    return journals.first;
  }

  @override
  Future<Iterable<Journal>> hydrateAll(Iterable<Journal> journals) async {
    final assetIds = journals.map((journal) => journal.assetId);
    final assets = await assetProvider.getAll(assetIds);
    final assetMapping = {for (final a in assets) a.id: a};

    return journals.map((journal) {
      final asset = assetMapping[journal.assetId]!;
      return journal.withAsset(asset);
    });
  }
}
