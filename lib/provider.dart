import 'package:banda/features/loans/providers/loan_tab_provider.dart';
import 'package:banda/features/loans/services/loan_service.dart';
import 'package:banda/features/transfers/providers/transfer_provider.dart';
import 'package:banda/features/transfers/repositories/transfer_repository.dart';
import 'package:banda/features/transfers/services/transfer_service.dart';
import 'package:banda/features/loans/repositories/loan_payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "package:banda/features/tags/repositories/category_repository.dart";
import 'package:banda/features/accounts/providers/account_provider.dart';
import 'package:banda/features/accounts/repositories/account_repository.dart';
import 'package:banda/features/accounts/services/account_service.dart';
import 'package:banda/features/entries/providers/entry_filter_provider.dart';
import 'package:banda/features/entries/providers/entry_provider.dart';
import 'package:banda/features/entries/repositories/entry_repository.dart';
import 'package:banda/features/entries/services/entry_service.dart';
import 'package:banda/features/funds/providers/fund_provider.dart';
import 'package:banda/features/funds/repositories/fund_repository.dart';
import 'package:banda/features/funds/services/fund_service.dart';
import 'package:banda/features/loans/providers/loan_filter_provider.dart';
import 'package:banda/features/loans/providers/loan_provider.dart';
import 'package:banda/features/loans/repositories/loan_repository.dart';
import 'package:banda/features/tags/providers/category_provider.dart';
import 'package:banda/features/tags/providers/label_provider.dart';
import 'package:banda/features/tags/providers/party_provider.dart';
import 'package:banda/features/tags/repositories/label_repository.dart';
import 'package:banda/features/tags/repositories/party_repository.dart';
import 'package:banda/features/main/handlers/notification_handler.dart';
import 'package:banda/features/notifications/managers/notification_manager.dart';
import 'package:banda/notification.dart';
import 'package:banda/features/funds/providers/fund_filter_provider.dart';
import 'package:banda/features/notifications/repositories/notification_repository.dart';

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

  final notificationManager = NotificationManager(
    notificationRepository: notificationRepository,
  );

  final entryService = EntryService(
    entryRepository: entryRepository,
    accountRepository: accountRepository,
    labelRepository: labelRepository,
    categoryRepository: categoryRepository,
    notificationManager: notificationManager,
  );
  final accountService = AccountService(
    accountRepository: accountRepository,
    entryRepository: entryRepository,
    categoryRepository: categoryRepository,
  );
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
        create: (context) => LabelProvider(labelRepository),
      ),
      ChangeNotifierProvider(
        create: (context) => PartyProvider(partyRepository),
      ),
      ChangeNotifierProvider(create: (context) => EntryFilterProvider()),
      ChangeNotifierProvider(create: (context) => LoanFilterProvider()),
      ChangeNotifierProvider(create: (context) => LoanTabProvider()),
      ChangeNotifierProvider(create: (context) => FundFilterProvider()),
    ],
    child: child,
  );
}
