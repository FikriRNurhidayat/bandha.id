import 'package:banda/entity/account.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/repository.dart';

class AccountService {
  final AccountRepository accountRepository;

  AccountService({required this.accountRepository});

  create({
    required String name,
    required String holderName,
    required AccountKind kind,
  }) {
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

  update({
    required String id,
    required String name,
    required String holderName,
    required AccountKind kind,
  }) {
    return Repository.work(() async {
      final account = await accountRepository.get(id);
      await accountRepository.save(
        account.copyWith(name: name, holderName: holderName, kind: kind),
      );
    });
  }

  search() {
    return accountRepository.search();
  }

  get(String id) {
    return accountRepository.get(id);
  }

  delete(String id) {
    return accountRepository.delete(id);
  }

  sync(String id) {
    return accountRepository.sync(id);
  }
}
