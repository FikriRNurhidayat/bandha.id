import 'package:banda/entity/entry.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/repositories/repository.dart';

typedef Spec = Map<String, dynamic>;

class EntryService {
  final EntryRepository entryRepository;
  final AccountRepository accountRepository;
  final LabelRepository labelRepository;

  const EntryService({
    required this.entryRepository,
    required this.accountRepository,
    required this.labelRepository,
  });

  Future<void> delete(String id) {
    return Repository.work(() async {
      final entry = await entryRepository.withAccount().get(id);
      final account = entry!.account!.revokeEntry(entry);
      await entryRepository.delete(id);
      await accountRepository.save(account);
    });
  }

  Future<Entry?> get(String id) {
    return entryRepository.withLabels().withAccount().withCategory().get(id);
  }

  Future<List<Entry>> search({Spec? spec}) {
    return entryRepository.withLabels().withAccount().withCategory().search(
      spec: spec,
    );
  }

  Future<void> create({
    required String note,
    required double amount,
    required EntryType type,
    required EntryStatus status,
    required String accountId,
    required String categoryId,
    required DateTime timestamp,
    List<String>? labelIds,
  }) {
    return Repository.work(() async {
      final account = await accountRepository.getById(accountId);

      final entry = Entry.writeable(
        note: note,
        amount: Entry.compute(type, amount),
        status: status,
        timestamp: timestamp,
        categoryId: categoryId,
        accountId: accountId,
      );

      await entryRepository.save(entry);

      if (labelIds != null && labelIds.isNotEmpty) {
        await entryRepository.setLabels(entry.id, labelIds);
      }

      await accountRepository.save(account.applyEntry(type, amount));
    });
  }

  Future<void> update({
    required String id,
    required String note,
    required double amount,
    required EntryType type,
    required EntryStatus status,
    required String accountId,
    required String categoryId,
    required DateTime timestamp,
    List<String>? labelIds,
  }) {
    return Repository.work(() async {
      final account = await accountRepository.getById(accountId);
      final entry = await entryRepository.get(id);
      if (entry == null) throw UnimplementedError();

      final delta = amount - entry.amount;
      final updatedEntry = entry.copyWith(
        note: note,
        amount: Entry.compute(type, amount),
        status: status,
        timestamp: timestamp,
        categoryId: categoryId,
        accountId: accountId,
      );

      await entryRepository.save(updatedEntry);
      await accountRepository.save(account.applyEntry(type, delta));
    });
  }
}
