import 'package:banda/entity/account.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/repository.dart';

class AccountService {
  final AccountRepository accountRepository;

  AccountService({required this.accountRepository});

  Future<void> create({
    required String name,
    required String holderName,
    required AccountKind kind,
  }) async {
    return Repository.work(() async {
      final account = Account.create(
        name: name,
        holderName: holderName,
        balance: 0,
        kind: kind,
      );

      await accountRepository.save(account);
    });
  }

  Future<void> update({
    required String id,
    required String name,
    required String holderName,
    required AccountKind kind,
  }) async {
    return Repository.work(() async {
      final account = await accountRepository.get(id);
      await accountRepository.save(
        account!.copyWith(name: name, holderName: holderName, kind: kind),
      );
    });
  }

  Future<List<Account>> search() async {
    return accountRepository.search();
  }

  Future<Account?> get(String id) async {
    return accountRepository.get(id);
  }

  Future<void> delete(String id) async {
    return accountRepository.delete(id);
  }

  Future<void> sync(String id) async {
    return accountRepository.sync(id);
  }
}
