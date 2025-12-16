import 'package:banda/common/services/service.dart';
import 'package:banda/features/accounts/entities/account.dart';
import 'package:banda/features/accounts/repositories/account_repository.dart';

class AccountService extends Service {
  final AccountRepository accountRepository;

  AccountService({required this.accountRepository});

  Future<Account> create({
    required String name,
    required String holderName,
    required AccountKind kind,
  }) {
    return work<Account>(() async {
      final account = Account.create(
        name: name,
        holderName: holderName,
        balance: 0,
        kind: kind,
      );

      await accountRepository.save(account);

      return account;
    });
  }

  update({
    required String id,
    required String name,
    required String holderName,
    required AccountKind kind,
  }) {
    return work(() async {
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
