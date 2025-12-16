import 'package:banda/features/loans/providers/loan_tab_provider.dart';
import 'package:banda/features/loans/services/loan_service.dart';
import 'package:banda/features/transfers/providers/transfer_provider.dart';
import 'package:banda/features/transfers/repositories/transfer_repository.dart';
import 'package:banda/features/transfers/services/transfer_service.dart';
import 'package:banda/features/loans/repositories/loan_payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:banda/handlers/notification_handler.dart';
import 'package:banda/managers/notification_manager.dart';
import 'package:banda/notification.dart';
import 'package:banda/features/accounts/providers/account_provider.dart';
import 'package:banda/providers/bill_filter_provider.dart';
import 'package:banda/providers/bill_provider.dart';
import 'package:banda/providers/budget_filter_provider.dart';
import 'package:banda/providers/budget_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/features/entries/providers/entry_provider.dart';
import 'package:banda/features/entries/providers/entry_filter_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/features/loans/providers/loan_filter_provider.dart';
import 'package:banda/features/loans/providers/loan_provider.dart';
import 'package:banda/providers/party_provider.dart';
import 'package:banda/providers/fund_filter_provider.dart';
import 'package:banda/features/funds/providers/fund_provider.dart';
import 'package:banda/features/accounts/repositories/account_repository.dart';
import 'package:banda/repositories/bill_repository.dart';
import 'package:banda/repositories/budget_repository.dart';
import "package:banda/repositories/category_repository.dart";
import 'package:banda/features/entries/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/features/loans/repositories/loan_repository.dart';
import 'package:banda/repositories/notification_repository.dart';
import 'package:banda/repositories/party_repository.dart';
import 'package:banda/features/funds/repositories/fund_repository.dart';
import 'package:banda/features/accounts/services/account_service.dart';
import 'package:banda/services/bill_service.dart';
import 'package:banda/services/budget_service.dart';
import 'package:banda/features/entries/services/entry_service.dart';
import 'package:banda/features/funds/services/fund_service.dart';

makeProvider({
  required Widget child,
  required NotificationHandler notificationHandler,
}) async {
  final notificationRepository = await NotificationRepository.build();
  final categoryRepository = await CategoryRepository.build();
  final entryRepository = await EntryRepository.build();
  final accountRepository = await AccountRepository.build();
  final transferRepository = await TransferRepository.build();
  final loanRepository = await LoanRepository.build();
  final loanPaymentRepository = await LoanPaymentRepository.build();
  final labelRepository = await LabelRepository.build();
  final partyRepository = await PartyRepository.build();
  final fundRepository = await FundRepository.build();
  final billRepository = await BillRepository.build();
  final budgetRepository = await BudgetRepository.build();

  final notificationManager = NotificationManager(
    notificationRepository: notificationRepository,
  );

  final entryService = EntryService(
    entryRepository: entryRepository,
    accountRepository: accountRepository,
    labelRepository: labelRepository,
    budgetRepository: budgetRepository,
    categoryRepository: categoryRepository,
    notificationManager: notificationManager,
  );

  final accountService = AccountService(accountRepository: accountRepository);
  final transferService = TransferService(
    categoryRepository: categoryRepository,
    transferRepository: transferRepository,
    entryRepository: entryRepository,
    accountRepository: accountRepository,
  );
  final loanService = LoanService(
    accountRepository: accountRepository,
    categoryRepository: categoryRepository,
    entryRepository: entryRepository,
    loanRepository: loanRepository,
    paymentRepository: loanPaymentRepository,
    partyRepository: partyRepository,
    notificationManager: notificationManager,
  );
  final fundService = FundService(
    accountRepository: accountRepository,
    categoryRepository: categoryRepository,
    entryRepository: entryRepository,
    fundRepository: fundRepository,
    labelRepository: labelRepository,
  );
  final billService = BillService(
    accountRepository: accountRepository,
    categoryRepository: categoryRepository,
    entryRepository: entryRepository,
    billRepository: billRepository,
    notificationManager: notificationManager,
  );
  final budgetService = BudgetService(
    budgetRepository: budgetRepository,
    notificationManager: notificationManager,
  );

  await notificationManager.init(
    notificationHandler,
    didReceiveBackgroundNotificationResponseCallback,
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => CategoryProvider(categoryRepository),
      ),
      ChangeNotifierProvider(
        create: (context) => AccountProvider(accountService: accountService),
      ),
      ChangeNotifierProvider(create: (context) => EntryProvider(entryService)),
      ChangeNotifierProvider(
        create: (context) => TransferProvider(transferService: transferService),
      ),
      ChangeNotifierProvider(
        create: (context) => FundProvider(fundService: fundService),
      ),
      ChangeNotifierProvider(
        create: (context) => LoanProvider(loanService: loanService),
      ),
      ChangeNotifierProvider(
        create: (context) => BillProvider(billService: billService),
      ),
      ChangeNotifierProvider(
        create: (context) => BudgetProvider(budgetService: budgetService),
      ),
      ChangeNotifierProvider(
        create: (context) => LabelProvider(labelRepository),
      ),
      ChangeNotifierProvider(
        create: (context) => PartyProvider(partyRepository),
      ),
      ChangeNotifierProvider(create: (context) => EntryFilterProvider()),
      ChangeNotifierProvider(create: (context) => LoanFilterProvider()),
      ChangeNotifierProvider(create: (context) => LoanTabProvider()),
      ChangeNotifierProvider(create: (context) => BillFilterProvider()),
      ChangeNotifierProvider(create: (context) => BudgetFilterProvider()),
      ChangeNotifierProvider(create: (context) => FundFilterProvider()),
    ],
    child: child,
  );
}
