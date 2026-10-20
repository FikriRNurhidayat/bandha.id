import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/infra/data/database_managers/sqlite_database_manager.dart';
import 'package:bandha/infra/platform/file_picker.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/ports/asset_reader.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

import 'fakes.dart';
import 'fixtures.dart';

/// In-memory asset repository whose [incrementBalance] mutates the store.
class FakeAssetRepository extends InMemoryRepository<Asset>
    implements AssetRepository, AssetReader {
  final List<(String, double)> increments = [];
  final List<String> balanced = [];

  FakeAssetRepository({super.seed});

  @override
  Future<void> balance(String id) async => balanced.add(id);

  @override
  Future<void> incrementBalance(String id, double delta) async {
    increments.add((id, delta));
    final asset = store[id];
    if (asset != null) {
      store[id] = asset.copyWith(balance: asset.balance + delta);
    }
  }
}

class FakeClassifierRepository<T extends Classifier<T>>
    extends InMemoryRepository<T>
    implements ClassifierRepository<T> {
  FakeClassifierRepository({super.seed});
}

/// Overrides only the methods the tools use cases call; never touches disk.
class FakeSqliteDatabaseManager extends SqliteDatabaseManager {
  final List<String> backups = [];
  final List<String> restores = [];
  int resets = 0;
  String backupDir = "/tmp/backups";
  Object? error;

  @override
  Future<String> backup(String snapshot) async {
    if (error != null) throw error!;
    backups.add(snapshot);
    return "$backupDir/$snapshot";
  }

  @override
  Future<void> reset() async {
    if (error != null) throw error!;
    resets++;
  }

  @override
  Future<void> restore(String sourcePath) async {
    if (error != null) throw error!;
    restores.add(sourcePath);
  }
}

/// Returns canned paths instead of invoking the platform channel.
class FakeFilePicker extends FilePicker {
  String? pickedFile;
  String? savedPath;
  final List<Map<String, dynamic>> saveCalls = [];
  int getFileCalls = 0;

  FakeFilePicker({this.pickedFile, this.savedPath});

  @override
  Future<String?> getFile({Iterable<String>? mimeTypes}) async {
    getFileCalls++;
    return pickedFile;
  }

  @override
  Future<String?> saveFile({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    saveCalls.add({
      "filePath": filePath,
      "fileName": fileName,
      "mimeType": mimeType,
    });
    return savedPath;
  }
}

Party makeParty({String? id, String name = "Alice"}) {
  return Party(
    id: id ?? Entity.getId(),
    name: name,
    readOnly: false,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  );
}
