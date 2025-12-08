import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/loan_payment.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/managers/notification_manager.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/loan_payment_repository.dart';
import 'package:banda/repositories/loan_repository.dart';
import 'package:banda/repositories/party_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/controller.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/foundation.dart';

@immutable
class LoanService {
  final LoanRepository loanRepository;
  final LoanPaymentRepository loanPaymentRepository;
  final CategoryRepository categoryRepository;
  final EntryRepository entryRepository;
  final AccountRepository accountRepository;
  final PartyRepository partyRepository;
  final NotificationManager notificationManager;

  const LoanService({
    required this.accountRepository,
    required this.entryRepository,
    required this.categoryRepository,
    required this.loanRepository,
    required this.loanPaymentRepository,
    required this.partyRepository,
    required this.notificationManager,
  });

  Future<Loan> create({
    required LoanType type,
    required LoanStatus status,
    required double amount,
    double fee = 0,
    required String partyId,
    required String accountId,
    required DateTime issuedAt,
    DateTime? settledAt,
  }) {
    return Repository.work<Loan>(() async {
      final category = await categoryRepository.getByName(type.label);
      final party = await partyRepository.get(partyId);
      final account = await accountRepository.get(accountId);
      final entryAmount = type.isDebt()
          ? (amount - fee)
          : ((amount + fee) * -1);

      final entry = Entry.readOnly(
        note: "${type.label} from ${party.name}",
        amount: entryAmount,
        status: status.entryStatus,
        issuedAt: issuedAt,
        accountId: accountId,
        categoryId: category.id,
      );

      final loan = Loan.create(
        amount: amount,
        remainder: status.isSettled() ? 0 : amount,
        fee: fee,
        type: type,
        status: status,
        partyId: party.id,
        accountId: account.id,
        entryId: entry.id,
        issuedAt: issuedAt,
        settledAt: settledAt,
      );

      await entryRepository.save(entry.controlledBy(loan));
      await accountRepository.save(account.applyEntry(entry));
      await loanRepository.save(loan);

      return get(loan.id);
    });
  }

  update(
    String id, {
    required LoanType type,
    required LoanStatus status,
    required double amount,
    double? fee,
    required String partyId,
    required String accountId,
    required DateTime issuedAt,
    DateTime? settledAt,
  }) {
    return Repository.work<Loan>(() async {
      final category = await categoryRepository.getByName(type.label);
      final loan = await loanRepository
          .withEntry()
          .withParty()
          .withAccount()
          .get(id);

      await accountRepository.save(loan.account.revokeEntry(loan.entry));

      final entryAmount = type.isDebt()
          ? (amount - (fee ?? 0))
          : ((amount + (fee ?? 0)) * -1);

      final newParty = await partyRepository.get(partyId);
      final newAccount = await accountRepository.get(accountId);
      final newEntry = loan.entry.copyWith(
        note: "${type.label} from ${newParty.name}",
        amount: entryAmount,
        status: status.entryStatus,
        issuedAt: issuedAt,
        accountId: accountId,
        categoryId: category.id,
      );

      final newLoan = loan.copyWith(
        amount: amount,
        fee: fee,
        remainder: status.isSettled() ? 0 : amount,
        type: type,
        status: status,
        partyId: newParty.id,
        accountId: newAccount.id,
        entryId: newEntry.id,
        issuedAt: issuedAt,
        settledAt: settledAt,
      );

      await entryRepository.save(newEntry);
      await accountRepository.save(newAccount.applyEntry(newEntry));
      await loanRepository.save(newLoan);

      return get(id);
    });
  }

  searchPayments({Specification? specification}) {
    return loanPaymentRepository
        .withAccount()
        .withEntry()
        .withCategory()
        .search(specification: specification);
  }

  deletePayment(String loanId, String entryId) {
    return Repository.work(() async {
      final payment = await loanPaymentRepository
          .withLoan()
          .withAccount()
          .withEntry()
          .get(loanId, entryId);

      final newAccount = payment.entry.account.revokeEntry(payment.entry);
      final newLoan = payment.loan.revokePayment(payment);

      await accountRepository.save(newAccount);
      await loanRepository.save(newLoan);
      await loanPaymentRepository.delete(payment.loan.id, payment.entry.id);
      await entryRepository.delete(payment.entry.id);
    });
  }

  getPayment(String loanId, String entryId) {
    return loanPaymentRepository.withAccount().withCategory().withEntry().get(
      loanId,
      entryId,
    );
  }

  updatePayment(
    String loanId,
    String entryId, {
    required double amount,
    double fee = 0,
    required String accountId,
    required DateTime issuedAt,
  }) {
    return Repository.work<LoanPayment>(() async {
      final payment = await loanPaymentRepository
          .withLoan()
          .withEntry()
          .withAccount()
          .get(loanId, entryId);

      final newLoan = payment.loan.revokePayment(payment);

      await loanRepository.save(newLoan);
      await accountRepository.save(
        payment.entry.account.revokeEntry(payment.entry),
      );

      final entryAmount = (amount + fee) * (newLoan.type.isDebt() ? -1 : 1);
      final newAccount = await accountRepository.get(accountId);
      final newPayment = payment.copyWith(
        amount: amount,
        fee: fee,
        issuedAt: issuedAt,
      );
      final newEntry = payment.entry.copyWith(
        amount: entryAmount,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        accountId: newAccount.id,
      );

      await entryRepository.save(newEntry);
      await accountRepository.save(newAccount.applyEntry(newEntry));
      await loanPaymentRepository.save(newPayment);
      await loanRepository.save(newLoan.applyPayment(newPayment));

      return getPayment(loanId, entryId);
    });
  }

  createPayment(
    String loanId, {
    required double amount,
    double fee = 0,
    required String accountId,
    required DateTime issuedAt,
  }) {
    return Repository.work<LoanPayment>(() async {
      final loan = await loanRepository.withParty().withAccount().get(loanId);
      final category = await categoryRepository.getByName(loan.type.label);

      final remainder = loan.remainder - amount;
      final status = remainder <= 0 ? LoanStatus.settled : loan.status;
      final entryAmount = (amount + fee) * (loan.type.isDebt() ? -1 : 1);

      final newAccount = await accountRepository.get(accountId);
      final newLoan = loan.copyWith(remainder: remainder, status: status);
      final newEntry = Entry.readOnly(
        note: entryNote(party: loan.party, type: loan.type),
        amount: entryAmount,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        accountId: newAccount.id,
        categoryId: category.id,
      );
      final newLoanPayment = LoanPayment.create(
        amount: amount,
        fee: fee,
        loanId: newLoan.id,
        entryId: newEntry.id,
        issuedAt: issuedAt,
      );

      await loanRepository.save(newLoan);
      await accountRepository.save(newAccount.applyEntry(newEntry));
      await entryRepository.save(newEntry);
      await loanPaymentRepository.save(newLoanPayment);

      return getPayment(newLoan.id, newEntry.id);
    });
  }

  get(String id) {
    return loanRepository.withParty().withEntry().withAccount().get(id);
  }

  search(Specification? spec) {
    return loanRepository.withParty().withEntry().withAccount().search(spec);
  }

  debugReminder(String id) async {
    final loan = await loanRepository.withParty().get(id);
    await notificationManager.setReminder(
      title: loan.party.name,
      body: "Outstanding ${loan.type.label}",
      sentAt: DateTime.now().add(Duration(seconds: 3)),
      controller: Controller.loan(loan.id),
    );
  }

  delete(String id) {
    return Repository.work(() async {
      await revokePayments(id);

      final loan = await loanRepository
          .withEntry()
          .withParty()
          .withAccount()
          .get(id);

      final newAccount = loan.account.revokeEntry(loan.entry);

      await accountRepository.save(newAccount);
      await loanRepository.delete(loan.id);
      await entryRepository.delete(loan.entry.id);
    });
  }

  String entryNote({
    required Party party,
    required LoanType type,
    bool settled = false,
  }) {
    if (type.isDebt()) {
      return settled
          ? "Debt settlement to ${party.name}"
          : "Debt payment to ${party.name}";
    }

    return settled
        ? "Receivable settlement from ${party.name}"
        : "Receivable payment from ${party.name}";
  }

  revokePayments(String id) async {
    final payments = await loanPaymentRepository
        .withAccount()
        .withEntry()
        .search(
          specification: {
            "loan_in": [id],
          },
        );

    final newAccounts = payments
        .map((payment) => payment.account as Account)
        .toSet();

    for (var payment in payments) {
      final paymentAccount = newAccounts.firstWhere(
        (i) => i.id == payment.accountId,
      );
      final newAccount = paymentAccount.revokeEntry(payment.entry);
      newAccounts.remove(paymentAccount);
      newAccounts.add(newAccount);

      await accountRepository.save(newAccount);
      await entryRepository.delete(payment.entryId);
      await loanPaymentRepository.delete(payment.loanId, payment.entryId);
    }
  }
}
