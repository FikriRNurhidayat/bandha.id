import 'package:app_links/app_links.dart';
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
import 'package:banda/views/budget_edit_view.dart';
import 'package:banda/views/budget_filter_view.dart';
import 'package:banda/views/budget_list_view.dart';
import 'package:banda/views/info_view.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  final entryService = EntryService(
    entryRepository: entryRepository,
    accountRepository: accountRepository,
    labelRepository: labelRepository,
    budgetRepository: budgetRepository,
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
  );

  final budgetService = BudgetService(budgetRepository: budgetRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(categoryRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(accountService: accountService),
        ),
        ChangeNotifierProvider(create: (_) => EntryProvider(entryService)),
        ChangeNotifierProvider(
          create: (_) => TransferProvider(transferService: transferService),
        ),
        ChangeNotifierProvider(
          create: (_) => SavingsProvider(savingsService: savingsService),
        ),
        ChangeNotifierProvider(
          create: (_) => LoanProvider(loanService: loanService),
        ),
        ChangeNotifierProvider(
          create: (_) => BillProvider(billService: billService),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(budgetService: budgetService),
        ),
        ChangeNotifierProvider(create: (_) => LabelProvider(labelRepository)),
        ChangeNotifierProvider(create: (_) => PartyProvider(partyRepository)),
        ChangeNotifierProvider(create: (_) => EntryFilterProvider()),
        ChangeNotifierProvider(create: (_) => LoanFilterProvider()),
        ChangeNotifierProvider(create: (_) => BillFilterProvider()),
        ChangeNotifierProvider(create: (_) => BudgetFilterProvider()),
        ChangeNotifierProvider(create: (_) => SavingsFilterProvider()),
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
  late final AppLinks appLinks;

  @override
  void initState() {
    super.initState();

    appLinks = AppLinks();

    initLink();

    appLinks.uriLinkStream.listen((uri) {
      navigate(uri);
    });
  }

  Future<void> initLink() async {
    final uri = await appLinks.getInitialLink();
    if (uri != null) navigate(uri);
  }

  void navigate(Uri uri) {
    if (uri.scheme == 'app' && uri.host == 'banda.io') {
      final path = '/${uri.pathSegments.join('/')}';
      Navigator.of(context).pushNamed(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData.light(useMaterial3: true);
    final dark = ThemeData.dark(useMaterial3: true);

    return MaterialApp(
      title: 'Banda.io',
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
            return MaterialPageRoute(builder: (_) => MainMenuView());
          case '/entries':
            return MaterialPageRoute(builder: (_) => EntryListView());
          case '/entries/new':
            return MaterialPageRoute(builder: (_) => EntryEditView());
          case '/entries/filter':
            return MaterialPageRoute(builder: (_) => EntryFilterView());
          case '/loans':
            return MaterialPageRoute(builder: (_) => LoanListView());
          case '/loans/new':
            return MaterialPageRoute(builder: (_) => LoanEditView());
          case '/loans/filter':
            return MaterialPageRoute(builder: (_) => LoanFilterView());
          case '/budgets':
            return MaterialPageRoute(builder: (_) => BudgetListView());
          case '/budgets/new':
            return MaterialPageRoute(builder: (_) => BudgetEditView());
          case '/budgets/filter':
            return MaterialPageRoute(builder: (_) => BudgetFilterView());
          case '/savings':
            return MaterialPageRoute(builder: (_) => SavingsListView());
          case '/savings/new':
            return MaterialPageRoute(builder: (_) => SavingsEditView());
          case '/savings/filter':
            return MaterialPageRoute(builder: (_) => SavingsFilterView());
          case '/accounts':
            return MaterialPageRoute(builder: (_) => AccountListView());
          case '/accounts/new':
            return MaterialPageRoute(builder: (_) => AccountEditView());
          case '/transfers':
            return MaterialPageRoute(builder: (_) => TransferListView());
          case '/transfers/new':
            return MaterialPageRoute(builder: (_) => TransferEditView());
          case '/bills':
            return MaterialPageRoute(builder: (_) => BillListView());
          case '/bills/new':
            return MaterialPageRoute(builder: (_) => BillEditView());
          case '/bills/filter':
            return MaterialPageRoute(builder: (_) => BillFilterView());
          case '/tools':
            return MaterialPageRoute(builder: (_) => ToolsView());
          case '/info':
            return MaterialPageRoute(builder: (_) => InfoView());
        }

        final uri = Uri.parse(settings.name!);
        if (uri.pathSegments.length == 3 && uri.pathSegments.last == "edit") {
          final id = uri.pathSegments[1];

          switch (uri.pathSegments.first) {
            case 'entries':
              return MaterialPageRoute(builder: (_) => EntryEditView(id: id));
            case 'bills':
              return MaterialPageRoute(builder: (_) => BillEditView(id: id));
            case 'loans':
              return MaterialPageRoute(builder: (_) => LoanEditView(id: id));
            case 'budgets':
              return MaterialPageRoute(builder: (_) => BudgetEditView(id: id));
            case 'accounts':
              return MaterialPageRoute(builder: (_) => AccountEditView(id: id));
            case 'transfers':
              return MaterialPageRoute(
                builder: (_) => TransferEditView(id: id),
              );
            case 'savings':
              return MaterialPageRoute(builder: (_) => SavingsEditView(id: id));
          }
        }

        if (uri.pathSegments.length == 3 && uri.pathSegments.last == "detail") {
          final id = uri.pathSegments[1];

          switch (uri.pathSegments.first) {
            case 'savings':
              return MaterialPageRoute(
                builder: (_) => SavingsDetailView(id: id),
              );
            case 'bills':
              return MaterialPageRoute(
                builder: (_) => BillEditView(id: id, readOnly: true),
              );
          }
        }

        if (uri.pathSegments.length == 4) {
          if (uri.pathSegments.first == "savings" &&
              uri.pathSegments[2] == "entries" &&
              uri.pathSegments[3] == "new") {
            return MaterialPageRoute(
              builder: (_) =>
                  SavingEntryEditView(savingsId: uri.pathSegments[1]),
            );
          }
        }

        if (uri.pathSegments.length == 5) {
          if (uri.pathSegments.first == "savings" &&
              uri.pathSegments[2] == "entries" &&
              uri.pathSegments.last == "edit") {
            return MaterialPageRoute(
              builder: (_) => SavingEntryEditView(
                savingsId: uri.pathSegments[1],
                entryId: uri.pathSegments[3],
              ),
            );
          }

          if (uri.pathSegments.first == "savings" &&
              uri.pathSegments[2] == "entries" &&
              uri.pathSegments.last == "detail") {
            return MaterialPageRoute(
              builder: (_) => SavingEntryEditView(
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
