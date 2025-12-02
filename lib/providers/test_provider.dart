import 'package:banda/entity/account.dart';
import 'package:banda/entity/bill.dart';
import 'package:banda/entity/budget.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/repositories/party_repository.dart';
import 'package:banda/services/account_service.dart';
import 'package:banda/services/bill_service.dart';
import 'package:banda/services/budget_service.dart';
import 'package:banda/services/entry_service.dart';
import 'package:banda/services/loan_service.dart';
import 'package:banda/services/savings_service.dart';
import 'package:banda/services/transfer_service.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:flutter/material.dart';

class TestProvider extends ChangeNotifier {
  final EntryService entryService;
  final AccountService accountService;
  final BudgetService budgetService;
  final BillService billService;
  final LoanService loanService;
  final TransferService transferService;
  final SavingsService savingsService;
  final CategoryRepository categoryRepository;
  final LabelRepository labelRepository;
  final PartyRepository partyRepository;

  TestProvider({
    required this.entryService,
    required this.accountService,
    required this.budgetService,
    required this.billService,
    required this.loanService,
    required this.transferService,
    required this.savingsService,
    required this.categoryRepository,
    required this.labelRepository,
    required this.partyRepository,
  });

  settleLoan(Loan loan) async {
    await loanService.update(
      id: loan.id,
      kind: LoanKind.debt,
      status: LoanStatus.settled,
      amount: loan.amount,
      fee: loan.fee,
      partyId: loan.partyId,
      debitAccountId: loan.debitAccountId,
      creditAccountId: loan.creditAccountId,
      issuedAt: loan.issuedAt,
      settledAt: loan.settledAt,
    );
  }

  Future<List<Category>> createCategories() async {
    final categories = <Category>[];

    for (var name in [
      "F&B",
      "Transportation",
      "Pet Care",
      "Personal Care",
      "Housing",
      "Charity",
      "Entertainment",
      "Adjustment",
      "Maintenance",
      "Utility",
    ]) {
      final category = await categoryRepository.create(name: name);
      categories.add(category);
    }

    return categories;
  }

  Future<List<Label>> createLabels() async {
    final labels = <Label>[];

    for (var name in [
      "Gas",
      "Water",
      "Electricity",
      "Data",
      "Car",
      "Motorbike",
      "Coffee",
      "Netflix",
    ]) {
      final label = await labelRepository.create(name: name);
      labels.add(label);
    }

    return labels;
  }

  Future<List<Account>> createAccounts() async {
    final accounts = <Account>[];

    for (var i in [
      ["Bank Central Asia", "John Marston", AccountKind.bankAccount],
      ["Bank SMBC", "John Marston", AccountKind.bankAccount],
      ["Bank OCBC", "John Marston", AccountKind.bankAccount],
      ["Bank Rakyat Indonesia", "Abigail Robert", AccountKind.bankAccount],
      ["LinkAja", "John Marston", AccountKind.ewallet],
      ["Go-pay", "John Marston", AccountKind.ewallet],
      ["Go-pay", "Abigail Robert", AccountKind.ewallet],
    ]) {
      final account = await accountService.create(
        name: i[0] as String,
        holderName: i[1] as String,
        kind: i[2] as AccountKind,
      );

      accounts.add(account);
    }

    return accounts;
  }

  Future<List<Party>> createParties() async {
    final parties = <Party>[];
    for (var name in [
      "Arthur Morgan",
      "Dutch Van Der Linde",
      "Bill Williamson",
      "Micah Bell",
      "Charles Smith",
    ]) {
      final party = await partyRepository.create(name: name);
      parties.add(party);
    }

    return parties;
  }

  Future<List<Budget>> createBudgets(DateTime issuedAt) async {
    final budgets = <Budget>[];

    final food = await categoryRepository.getByName("F&B");
    final entertainment = await categoryRepository.getByName("Entertainment");
    final transportation = await categoryRepository.getByName("Transportation");
    final maintenance = await categoryRepository.getByName("Maintenance");

    final coffee = await labelRepository.getByName("Coffee");

    for (var item in [
      {
        "note": "Coffee Budget",
        "category": food.id,
        "labels": <String>[coffee.id],
        "threshold": 25000.0,
        "cycle": BudgetCycle.daily,
      },
      {
        "note": "Food Budget",
        "category": food.id,
        "labels": <String>[],
        "threshold": 150000.0,
        "cycle": BudgetCycle.daily,
      },
      {
        "note": "Entertainment Budget",
        "category": entertainment.id,
        "labels": <String>[],
        "threshold": 1000000.0,
        "cycle": BudgetCycle.monthly,
      },
      {
        "note": "Transportation Budget",
        "category": transportation.id,
        "labels": <String>[],
        "threshold": 300000.0,
        "cycle": BudgetCycle.weekly,
      },
      {
        "note": "Maintenance Budget",
        "category": maintenance.id,
        "labels": <String>[],
        "threshold": 2000000.0,
        "cycle": BudgetCycle.monthly,
      },
    ]) {
      final budget = await budgetService.create(
        note: item["note"] as String,
        threshold: item["threshold"] as double,
        cycle: item["cycle"] as BudgetCycle,
        categoryId: item["category"] as String,
        labelIds: item["labels"] as List<String>,
        issuedAt: DateTime(issuedAt.year, issuedAt.month, issuedAt.day, 21, 0),
      );

      budgets.add(budget);
    }

    return budgets;
  }

  Future<void> bootstrap({
    required List<Account> accounts,
    required double balance,
    required Category adjustment,
  }) async {
    for (var account in accounts) {
      await entryService.create(
        note: "Bootstrap",
        amount: balance,
        type: EntryType.income,
        status: EntryStatus.done,
        accountId: account.id,
        categoryId: adjustment.id,
        timestamp: DateTime.now(),
      );
    }
  }

  Future<void> populate() async {
    final now = DateTime.now();
    var current = now.subtract(Duration(days: 7));

    current = DateTime(current.year, current.month, current.day, 7, 0);

    final [
      food,
      transportation,
      petCare,
      personalCare,
      housing,
      charity,
      entertainment,
      adjustment,
      maintenance,
      utility,
    ] = await createCategories();

    final [gas, water, electricity, data, car, motorbike, coffee, netflix] =
        await createLabels();

    final [
      bca,
      smbc,
      ocbc,
      bri,
      linkAja,
      gopayJohnMarston,
      gopayAbigailRobert,
    ] = await createAccounts();

    final ewallets = [gopayJohnMarston, gopayAbigailRobert];
    final bankAccounts = [bca, smbc, ocbc, bri, linkAja];

    final [
      arthurMorgan,
      dutchVanDerLinde,
      billWilliamson,
      micahBell,
      charlesSmith,
    ] = await createParties();

    final budgets = await createBudgets(current);
    final dailyBudgets = budgets.where((budget) => budget.cycle.isDaily());

    await bootstrap(accounts: [bca], balance: 25000000, adjustment: adjustment);

    // Day 1

    final japanTrip = await savingsService.create(
      note: "Japan Trip",
      goal: 50000000,
      accountId: bca.id,
    );

    for (var ewallet in ewallets) {
      await transferService.create(
        amount: 500000,
        fee: 5000,
        issuedAt: current,
        debitAccountId: ewallet.id,
        creditAccountId: bca.id,
      );
    }

    for (var bankAccount in bankAccounts) {
      if (bankAccount.id == bca.id) continue;

      await transferService.create(
        amount: 1000000,
        fee: 5000,
        issuedAt: current,
        debitAccountId: bankAccount.id,
        creditAccountId: bca.id,
      );
    }

    await entryService.create(
      note: "Purchase Kopi Java at Couvee",
      amount: 23000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: gopayJohnMarston.id,
      categoryId: food.id,
      labelIds: [coffee.id],
      timestamp: current.add(Duration(hours: 1)),
    );

    await entryService.create(
      note: "Breakfast at Soto Gading I",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    final dutchDebt = await loanService.create(
      kind: LoanKind.debt,
      status: LoanStatus.active,
      amount: 5000000,
      fee: 5000,
      partyId: dutchVanDerLinde.id,
      debitAccountId: bca.id,
      creditAccountId: bca.id,
      issuedAt: current.add(Duration(hours: 3)),
      settledAt: current.add(Duration(days: 1, hours: 3)),
    );

    await billService.create(
      note: "johnmarston@vanderlinde.com",
      amount: 125000,
      cycle: BillCycle.monthly,
      status: BillStatus.paid,
      categoryId: entertainment.id,
      accountId: smbc.id,
      labelIds: [netflix.id],
      billedAt: current.add(Duration(hours: 4)),
    );

    await savingsService.createEntry(
      savingsId: japanTrip.id,
      type: TransactionType.deposit,
      amount: 250000,
      issuedAt: current.add(Duration(hours: 5)),
    );

    await entryService.create(
      note: "Dinner at McDonalds",
      amount: 100000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    for (var dailyBudget in dailyBudgets) {
      await budgetService.repeat(dailyBudget.id);
    }

    // Day 2
    current = current.add(Duration(days: 1));

    await entryService.create(
      note: "Purchase Kopi Java at Couvee",
      amount: 23000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: gopayJohnMarston.id,
      categoryId: food.id,
      labelIds: [coffee.id],
      timestamp: current.add(Duration(hours: 1)),
    );

    await entryService.create(
      note: "Breakfast at Soto Gading I",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    await settleLoan(dutchDebt);

    await savingsService.createEntry(
      savingsId: japanTrip.id,
      type: TransactionType.deposit,
      amount: 250000,
      issuedAt: current.add(Duration(hours: 5)),
    );

    await entryService.create(
      note: "Dinner at McDonalds",
      amount: 100000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    for (var dailyBudget in dailyBudgets) {
      await budgetService.repeat(dailyBudget.id);
    }

    // Day 3
    current = current.add(Duration(days: 1));

    await entryService.create(
      note: "Couvee",
      amount: 23000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: gopayJohnMarston.id,
      categoryId: food.id,
      labelIds: [coffee.id],
      timestamp: current.add(Duration(hours: 1)),
    );

    await entryService.create(
      note: "Soto Gading I",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    await savingsService.createEntry(
      savingsId: japanTrip.id,
      type: TransactionType.deposit,
      amount: 250000,
      issuedAt: current.add(Duration(hours: 5)),
    );

    await entryService.create(
      note: "McDonalds",
      amount: 100000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    await billService.create(
      note: "PDA-0890-0001",
      amount: 100000,
      cycle: BillCycle.monthly,
      status: BillStatus.paid,
      categoryId: housing.id,
      accountId: bca.id,
      labelIds: [water.id],
      billedAt: current.add(Duration(hours: 4)),
    );

    await billService.create(
      note: "PLN-0890-0001",
      amount: 100000,
      cycle: BillCycle.monthly,
      status: BillStatus.paid,
      categoryId: housing.id,
      accountId: bca.id,
      labelIds: [electricity.id],
      billedAt: current.add(Duration(hours: 5)),
    );

    await billService.create(
      note: "TELK-0890-0001",
      amount: 100000,
      cycle: BillCycle.monthly,
      status: BillStatus.paid,
      categoryId: utility.id,
      accountId: linkAja.id,
      labelIds: [data.id],
      billedAt: current.add(Duration(hours: 6)),
    );

    await entryService.create(
      note: "Pertalite",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: transportation.id,
      labelIds: [gas.id, motorbike.id],
      timestamp: current.add(Duration(hours: 7)),
    );

    final billReceiveable = await loanService.create(
      kind: LoanKind.receiveable,
      status: LoanStatus.active,
      amount: 5000000,
      fee: 5000,
      partyId: billWilliamson.id,
      debitAccountId: bca.id,
      creditAccountId: bca.id,
      issuedAt: current.add(Duration(hours: 8)),
      settledAt: current.add(Duration(days: 1, hours: 8)),
    );

    for (var dailyBudget in dailyBudgets) {
      await budgetService.repeat(dailyBudget.id);
    }

    // Day 4
    current = current.add(Duration(days: 1));

    await settleLoan(billReceiveable);

    await entryService.create(
      note: "Couvee",
      amount: 23000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: gopayJohnMarston.id,
      categoryId: food.id,
      labelIds: [coffee.id],
      timestamp: current.add(Duration(hours: 1)),
    );

    await entryService.create(
      note: "Soto Gading I",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    await savingsService.createEntry(
      savingsId: japanTrip.id,
      type: TransactionType.deposit,
      amount: 250000,
      issuedAt: current.add(Duration(hours: 5)),
    );

    await entryService.create(
      note: "McDonalds",
      amount: 100000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    await entryService.create(
      note: "Pertalite",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: transportation.id,
      labelIds: [gas.id, car.id],
      timestamp: current.add(Duration(hours: 7)),
    );

    for (var dailyBudget in dailyBudgets) {
      await budgetService.repeat(dailyBudget.id);
    }

    // Day 5
    current = current.add(Duration(days: 1));

    await entryService.create(
      note: "Couvee",
      amount: 23000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: gopayJohnMarston.id,
      categoryId: food.id,
      labelIds: [coffee.id],
      timestamp: current.add(Duration(hours: 1)),
    );

    await entryService.create(
      note: "Soto Gading I",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    await savingsService.createEntry(
      savingsId: japanTrip.id,
      type: TransactionType.deposit,
      amount: 250000,
      issuedAt: current.add(Duration(hours: 5)),
    );

    await entryService.create(
      note: "McDonalds",
      amount: 100000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    for (var dailyBudget in dailyBudgets) {
      await budgetService.repeat(dailyBudget.id);
    }

    // Day 6
    current = current.add(Duration(days: 1));

    await entryService.create(
      note: "Couvee",
      amount: 23000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: gopayJohnMarston.id,
      categoryId: food.id,
      labelIds: [coffee.id],
      timestamp: current.add(Duration(hours: 1)),
    );

    await entryService.create(
      note: "Soto Gading I",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    await savingsService.createEntry(
      savingsId: japanTrip.id,
      type: TransactionType.deposit,
      amount: 250000,
      issuedAt: current.add(Duration(hours: 5)),
    );

    await entryService.create(
      note: "McDonalds",
      amount: 100000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    for (var dailyBudget in dailyBudgets) {
      await budgetService.repeat(dailyBudget.id);
    }

    // Day 7
    current = now;

    await entryService.create(
      note: "Couvee",
      amount: 23000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: gopayJohnMarston.id,
      categoryId: food.id,
      labelIds: [coffee.id],
      timestamp: current.add(Duration(hours: 1)),
    );

    await entryService.create(
      note: "Soto Gading I",
      amount: 50000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );

    await savingsService.createEntry(
      savingsId: japanTrip.id,
      type: TransactionType.deposit,
      amount: 250000,
      issuedAt: current.add(Duration(hours: 5)),
    );

    await entryService.create(
      note: "McDonalds",
      amount: 100000,
      type: EntryType.expense,
      status: EntryStatus.done,
      accountId: bca.id,
      categoryId: food.id,
      labelIds: [],
      timestamp: current.add(Duration(hours: 2)),
    );
  }
}
