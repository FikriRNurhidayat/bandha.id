import 'package:app_links/app_links.dart';
import 'package:banda/handlers/notification_handler.dart';
import 'package:banda/managers/notification_manager.dart';
import 'package:banda/notification.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/bill_filter_provider.dart';
import 'package:banda/providers/bill_provider.dart';
import 'package:banda/providers/budget_filter_provider.dart';
import 'package:banda/providers/budget_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/providers/entry_filter_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/providers/loan_filter_provider.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/providers/party_provider.dart';
import 'package:banda/providers/savings_filter_provider.dart';
import 'package:banda/providers/savings_provider.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/bill_repository.dart';
import 'package:banda/repositories/budget_repository.dart';
import "package:banda/repositories/category_repository.dart";
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/repositories/loan_repository.dart';
import 'package:banda/repositories/notification_repository.dart';
import 'package:banda/repositories/party_repository.dart';
import 'package:banda/repositories/savings_repository.dart';
import 'package:banda/repositories/transfer_repository.dart';
import 'package:banda/services/account_service.dart';
import 'package:banda/services/bill_service.dart';
import 'package:banda/services/budget_service.dart';
import 'package:banda/services/entry_service.dart';
import 'package:banda/services/loan_service.dart';
import 'package:banda/services/savings_service.dart';
import 'package:banda/services/transfer_service.dart';
import 'package:banda/views/account_edit_view.dart';
import 'package:banda/views/account_list_view.dart';
import 'package:banda/views/bill_edit_view.dart';
import 'package:banda/views/bill_filter_view.dart';
import 'package:banda/views/bill_list_view.dart';
import 'package:banda/views/bill_menu_view.dart';
import 'package:banda/views/budget_edit_view.dart';
import 'package:banda/views/budget_filter_view.dart';
import 'package:banda/views/budget_list_view.dart';
import 'package:banda/views/budget_menu_view.dart';
import 'package:banda/views/category_edit_view.dart';
import 'package:banda/views/entry_menu_view.dart';
import 'package:banda/views/info_view.dart';
import 'package:banda/views/label_edit_view.dart';
import 'package:banda/views/loan_menu_view.dart';
import 'package:banda/views/savings_detail_view.dart';
import 'package:banda/views/entry_edit_view.dart';
import 'package:banda/views/entry_filter_view.dart';
import 'package:banda/views/entry_list_view.dart';
import 'package:banda/views/loan_edit_view.dart';
import 'package:banda/views/loan_filter_view.dart';
import 'package:banda/views/loan_list_view.dart';
import 'package:banda/views/main_menu_view.dart';
import 'package:banda/views/savings_edit_view.dart';
import 'package:banda/views/savings_entry_edit_view.dart';
import 'package:banda/views/savings_filter_view.dart';
import 'package:banda/views/savings_list_view.dart';
import 'package:banda/views/tools_view.dart';
import 'package:banda/views/transfer_edit_view.dart';
import 'package:banda/views/transfer_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final navigator = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationRepository = await NotificationRepository.build();
  final categoryRepository = await CategoryRepository.build();
  final entryRepository = await EntryRepository.build();
  final accountRepository = await AccountRepository.build();
  final transferRepository = await TransferRepository.build();
  final loanRepository = await LoanRepository.build();
  final labelRepository = await LabelRepository.build();
  final partyRepository = await PartyRepository.build();
  final savingsRepository = await SavingsRepository.build();
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
    partyRepository: partyRepository,
    notificationManager: notificationManager,
  );
  final savingsService = SavingsService(
    accountRepository: accountRepository,
    categoryRepository: categoryRepository,
    entryRepository: entryRepository,
    savingsRepository: savingsRepository,
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

  final notificationHandler = NotificationHandler(navigator);

  await notificationManager.init(
    notificationHandler,
    didReceiveBackgroundNotificationResponseCallback,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(categoryRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => AccountProvider(accountService: accountService),
        ),
        ChangeNotifierProvider(
          create: (context) => EntryProvider(entryService),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              TransferProvider(transferService: transferService),
        ),
        ChangeNotifierProvider(
          create: (context) => SavingsProvider(savingsService: savingsService),
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
        ChangeNotifierProvider(create: (context) => BillFilterProvider()),
        ChangeNotifierProvider(create: (context) => BudgetFilterProvider()),
        ChangeNotifierProvider(create: (context) => SavingsFilterProvider()),
      ],
      child: const BandaApp(),
    ),
  );
}

class BandaApp extends StatefulWidget {
  const BandaApp({super.key});

  @override
  State<BandaApp> createState() => _BandaAppState();
}

class _BandaAppState extends State<BandaApp> {
  @override
  void initState() {
    super.initState();

    initLink();
  }

  Future<void> initLink() async {
    final appLinks = AppLinks();
    final uri = await appLinks.getInitialLink();
    if (uri != null) navigate(uri);
    appLinks.uriLinkStream.listen((uri) {
      navigate(uri);
    });
  }

  void navigate(Uri uri) {
    if (uri.scheme == 'app' && uri.host == 'bandha.id') {
      final path = '/${uri.pathSegments.join('/')}';
      Navigator.of(context).pushNamed(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData.light(useMaterial3: true);
    final dark = ThemeData.dark(useMaterial3: true);

    return MaterialApp(
      navigatorKey: navigator,
      title: 'Bandha.io',
      debugShowCheckedModeBanner: false,
      theme: light.copyWith(
        colorScheme: light.colorScheme.copyWith(
          surfaceTint: light.colorScheme.surface,
          primary: light.colorScheme.onSurface,
          primaryFixed: light.colorScheme.onSurface,
          primaryFixedDim: light.colorScheme.onSurface,
          primaryContainer: light.colorScheme.onSurface,
          onPrimaryContainer: light.colorScheme.surface,
          onPrimary: light.colorScheme.surface,
          onPrimaryFixed: light.colorScheme.surface,
          onPrimaryFixedVariant: light.colorScheme.surface,
          secondary: light.colorScheme.onSurface,
          secondaryFixed: light.colorScheme.onSurface,
          secondaryFixedDim: light.colorScheme.onSurface,
          secondaryContainer: light.colorScheme.onSurface,
          onSecondaryContainer: light.colorScheme.surface,
          onSecondary: light.colorScheme.surface,
          onSecondaryFixed: light.colorScheme.surface,
          onSecondaryFixedVariant: light.colorScheme.surface,
          tertiary: light.colorScheme.onSurface,
          tertiaryFixed: light.colorScheme.onSurface,
          tertiaryFixedDim: light.colorScheme.onSurface,
          tertiaryContainer: light.colorScheme.onSurface,
          onTertiaryContainer: light.colorScheme.surface,
          onTertiary: light.colorScheme.surface,
          onTertiaryFixed: light.colorScheme.surface,
          onTertiaryFixedVariant: light.colorScheme.surface,
          inversePrimary: light.colorScheme.surface,
        ),
        textTheme: light.textTheme.apply(fontFamily: 'Eczar'),
      ),
      darkTheme: dark.copyWith(
        colorScheme: dark.colorScheme.copyWith(
          surfaceTint: dark.colorScheme.surface,
          primary: dark.colorScheme.onSurface,
          primaryFixed: dark.colorScheme.onSurface,
          primaryFixedDim: dark.colorScheme.onSurface,
          primaryContainer: dark.colorScheme.onSurface,
          onPrimaryContainer: dark.colorScheme.surface,
          onPrimary: dark.colorScheme.surface,
          onPrimaryFixed: dark.colorScheme.surface,
          onPrimaryFixedVariant: dark.colorScheme.surface,
          secondary: dark.colorScheme.onSurface,
          secondaryFixed: dark.colorScheme.onSurface,
          secondaryFixedDim: dark.colorScheme.onSurface,
          secondaryContainer: dark.colorScheme.onSurface,
          onSecondaryContainer: dark.colorScheme.surface,
          onSecondary: dark.colorScheme.surface,
          onSecondaryFixed: dark.colorScheme.surface,
          onSecondaryFixedVariant: dark.colorScheme.surface,
          tertiary: dark.colorScheme.onSurface,
          tertiaryFixed: dark.colorScheme.onSurface,
          tertiaryFixedDim: dark.colorScheme.onSurface,
          tertiaryContainer: dark.colorScheme.onSurface,
          onTertiaryContainer: dark.colorScheme.surface,
          onTertiary: dark.colorScheme.surface,
          onTertiaryFixed: dark.colorScheme.surface,
          onTertiaryFixedVariant: dark.colorScheme.surface,
          inversePrimary: dark.colorScheme.surface,
        ),
        textTheme: dark.textTheme.apply(fontFamily: 'Eczar'),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name!) {
          case '/':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => MainMenuView(),
            );
          case '/entries':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => EntryListView(),
            );
          case '/entries/new':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => EntryEditView(),
            );
          case '/entries/filter':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => EntryFilterView(),
            );
          case '/loans':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => LoanListView(),
            );
          case '/loans/new':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => LoanEditView(),
            );
          case '/loans/filter':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => LoanFilterView(),
            );
          case '/budgets':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => BudgetListView(),
            );
          case '/budgets/new':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => BudgetEditView(),
            );
          case '/budgets/filter':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => BudgetFilterView(),
            );
          case '/savings':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => SavingsListView(),
            );
          case '/savings/new':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => SavingsEditView(),
            );
          case '/savings/filter':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => SavingsFilterView(),
            );
          case '/accounts':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => AccountListView(),
            );
          case '/accounts/new':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => AccountEditView(),
            );
          case '/transfers':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => TransferListView(),
            );
          case '/transfers/new':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => TransferEditView(),
            );
          case '/bills':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => BillListView(),
            );
          case '/bills/new':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => BillEditView(),
            );
          case '/bills/filter':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => BillFilterView(),
            );
          case '/categories/edit':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => CategoryEditView(),
            );
          case '/labels/edit':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => LabelEditView(),
            );
          case '/tools':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ToolsView(),
            );
          case '/info':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => InfoView(),
            );
        }

        final uri = Uri.parse(settings.name!);
        if (uri.pathSegments.length == 3 && uri.pathSegments.last == "edit") {
          final id = uri.pathSegments[1];

          switch (uri.pathSegments.first) {
            case 'entries':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => EntryEditView(id: id),
              );
            case 'bills':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => BillEditView(id: id),
              );
            case 'loans':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => LoanEditView(id: id),
              );
            case 'budgets':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => BudgetEditView(id: id),
              );
            case 'accounts':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => AccountEditView(id: id),
              );
            case 'transfers':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => TransferEditView(id: id),
              );
            case 'savings':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => SavingsEditView(id: id),
              );
          }
        }

        if (uri.pathSegments.length == 3 && uri.pathSegments.last == "menu") {
          final id = uri.pathSegments[1];

          switch (uri.pathSegments.first) {
            case 'entries':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => EntryMenuView(id: id),
              );
            case 'bills':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => BillMenuView(id: id),
              );
            case 'budgets':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => BudgetMenuView(id: id),
              );
            case 'loans':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => LoanMenuView(id: id),
              );
          }
        }

        if (uri.pathSegments.length == 3 && uri.pathSegments.last == "detail") {
          final id = uri.pathSegments[1];

          switch (uri.pathSegments.first) {
            case 'entries':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => EntryEditView(id: id, readOnly: true),
              );
            case 'bills':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => BillEditView(id: id, readOnly: true),
              );
            case 'loans':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => LoanEditView(id: id, readOnly: true),
              );
            case 'budgets':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => BudgetEditView(id: id, readOnly: true),
              );
            case 'accounts':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => AccountEditView(id: id, readOnly: true),
              );
            case 'transfers':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => TransferEditView(id: id, readOnly: true),
              );
            case 'savings':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => SavingsDetailView(id: id),
              );
          }
        }

        if (uri.pathSegments.length == 4) {
          if (uri.pathSegments.first == "savings" &&
              uri.pathSegments[2] == "entries" &&
              uri.pathSegments[3] == "new") {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) =>
                  SavingEntryEditView(savingsId: uri.pathSegments[1]),
            );
          }
        }

        if (uri.pathSegments.length == 5) {
          if (uri.pathSegments.first == "savings" &&
              uri.pathSegments[2] == "entries" &&
              uri.pathSegments.last == "edit") {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => SavingEntryEditView(
                savingsId: uri.pathSegments[1],
                entryId: uri.pathSegments[3],
              ),
            );
          }

          if (uri.pathSegments.first == "savings" &&
              uri.pathSegments[2] == "entries" &&
              uri.pathSegments.last == "detail") {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => SavingEntryEditView(
                savingsId: uri.pathSegments[1],
                entryId: uri.pathSegments[3],
                readOnly: true,
              ),
            );
          }
        }

        return null;
      },
    );
  }
}
