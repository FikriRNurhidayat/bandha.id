import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/managers/notification_manager.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/loan_repository.dart';
import 'package:banda/repositories/party_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/controller.dart';
import 'package:banda/types/controller_type.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/foundation.dart';

@immutable
class LoanService {
  final LoanRepository loanRepository;
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
    required this.partyRepository,
    required this.notificationManager,
  });

  create({
    required LoanKind kind,
    required LoanStatus status,
    required double amount,
    required double? fee,
    required String partyId,
    required String debitAccountId,
    required String creditAccountId,
    required DateTime issuedAt,
    required DateTime settledAt,
  }) {
    return Repository.work(() async {
      final category = await categoryRepository.getByName(kind.label);
      final party = await partyRepository.get(partyId);
      final debitAccount = await accountRepository.get(debitAccountId);
      final creditAccount = await accountRepository.get(creditAccountId);
      final isDebt = kind == LoanKind.debt;

      final debitDraft = Entry.bySystem(
        note: "Received from ${party.name}",
        amount: amount,
        status: isDebt ? EntryStatus.done : status.entryStatus(),
        issuedAt: isDebt ? issuedAt : settledAt,
        accountId: debitAccount.id,
        categoryId: category.id,
      );

      final creditDraft = Entry.bySystem(
        note: isDebt ? "Paid to ${party.name}" : "Lent to ${party.name}",
        amount: (amount + (fee ?? 0)) * -1,
        status: isDebt ? status.entryStatus() : EntryStatus.done,
        issuedAt: isDebt ? settledAt : issuedAt,
        accountId: creditAccount.id,
        categoryId: category.id,
      );

      final loan = Loan.create(
        amount: amount,
        fee: fee,
        kind: kind,
        status: status,
        partyId: party.id,
        debitId: debitDraft.id,
        creditId: creditDraft.id,
        debitAccountId: debitAccount.id,
        creditAccountId: creditAccount.id,
        issuedAt: issuedAt,
        settledAt: settledAt,
      );

      final debit = debitDraft.copyWith(
        controllerId: loan.id,
        controllerType: ControllerType.loan,
      );

      final credit = creditDraft.copyWith(
        controllerId: loan.id,
        controllerType: ControllerType.loan,
      );

      await entryRepository.save(debit);
      await entryRepository.save(credit);

      if (debit.isDone()) {
        await accountRepository.save(debitAccount.applyAmount(debit.amount));
      }

      if (credit.isDone()) {
        await accountRepository.save(creditAccount.applyAmount(credit.amount));
      }

      await loanRepository.save(loan);

      if (!loan.status.isSettled()) {
        await notificationManager.setReminder(
          title: loan.party.name,
          body: "Outstanding ${loan.kind.label}",
          sentAt: loan.settledAt,
          controller: Controller.loan(loan.id),
        );
      }
    });
  }

  update({
    required String id,
    required LoanKind kind,
    required LoanStatus status,
    required double amount,
    required double? fee,
    required String partyId,
    required String debitAccountId,
    required String creditAccountId,
    required DateTime issuedAt,
    required DateTime settledAt,
  }) {
    return Repository.work(() async {
      final isDebt = kind == LoanKind.debt;
      final party = await partyRepository.get(partyId);
      final loan = await loanRepository
          .withEntries()
          .withAccounts()
          .withParty()
          .get(id);

      if (!loan.status.isSettled()) {
        await notificationManager.cancelReminder(Controller.loan(loan.id));
      }

      if (loan.debit.isDone()) {
        final refDebitAccount = loan.debitAccount.revokeEntry(loan.debit);
        await accountRepository.save(refDebitAccount);
      }

      if (loan.credit.isDone()) {
        final refCreditAccount = loan.creditAccount.revokeEntry(loan.credit);
        await accountRepository.save(refCreditAccount);
      }

      final debitAccount = await accountRepository.get(debitAccountId);
      final creditAccount = await accountRepository.get(creditAccountId);

      final debit = loan.debit.copyWith(
        note: "Received from ${party.name}",
        amount: amount,
        status: isDebt ? EntryStatus.done : status.entryStatus(),
        issuedAt: isDebt ? issuedAt : settledAt,
        readonly: true,
        accountId: debitAccount.id,
      );

      final credit = loan.credit.copyWith(
        note: isDebt ? "Paid to ${party.name}" : "Lent to ${party.name}",
        amount: (amount + (fee ?? 0)) * -1,
        status: isDebt ? status.entryStatus() : EntryStatus.done,
        issuedAt: isDebt ? settledAt : issuedAt,
        readonly: true,
        accountId: creditAccount.id,
      );

      await entryRepository.save(debit);
      await entryRepository.save(credit);

      if (debit.isDone()) {
        await accountRepository.save(debitAccount.applyEntry(debit));
      }

      if (credit.isDone()) {
        await accountRepository.save(debitAccount.applyEntry(credit));
      }

      final newLoan = loan.copyWith(
        amount: amount,
        fee: fee,
        kind: kind,
        status: status,
        partyId: party.id,
        debitId: debit.id,
        creditId: credit.id,
        debitAccountId: debitAccount.id,
        creditAccountId: creditAccount.id,
        issuedAt: issuedAt,
        settledAt: settledAt,
      );

      await loanRepository.save(newLoan);

      if (!newLoan.status.isSettled()) {
        await notificationManager.setReminder(
          title: newLoan.party.name,
          body: "Outstanding ${newLoan.kind.label}",
          sentAt: newLoan.settledAt,
          controller: Controller.loan(newLoan.id),
        );
      }
    });
  }

  get(String id) {
    return loanRepository.withParty().withEntries().withAccounts().get(id);
  }

  search(Specification? spec) {
    return loanRepository.withParty().withEntries().withAccounts().search(spec);
  }

  debugReminder(String id) async {
    final loan = await loanRepository.withParty().get(id);
    await notificationManager.setReminder(
      title: loan.party.name,
      body: "Outstanding ${loan.kind.label}",
      sentAt: DateTime.now().add(Duration(seconds: 3)),
      controller: Controller.loan(loan.id),
    );
  }

  delete(String id) {
    return Repository.work(() async {
      final loan = await loanRepository.get(id);

      await loanRepository.delete(loan.id);
      await entryRepository.delete(loan.debit.id);
      await entryRepository.delete(loan.credit.id);

      if (loan.debit.isDone()) {
        await accountRepository.save(loan.debitAccount.revokeEntry(loan.debit));
      }

      if (loan.credit.isDone()) {
        await accountRepository.save(
          loan.creditAccount.revokeEntry(loan.credit),
        );
      }
    });
  }
}
