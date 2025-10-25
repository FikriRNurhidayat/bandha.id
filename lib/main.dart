import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/providers/filter_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/providers/metric_provider.dart';
import 'package:banda/providers/party_provider.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/repositories/account_repository.dart';
import "package:banda/repositories/category_repository.dart";
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/repositories/loan_repository.dart';
import 'package:banda/repositories/party_repository.dart';
import 'package:banda/repositories/transfer_repository.dart';
import 'package:banda/views/entrypoint.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(categoryRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(accountRepository),
        ),
        ChangeNotifierProvider(create: (_) => EntryProvider(entryRepository)),
        ChangeNotifierProvider(
          create: (_) => TransferProvider(transferRepository),
        ),
        ChangeNotifierProvider(create: (_) => LoanProvider(loanRepository)),
        ChangeNotifierProvider(create: (_) => LabelProvider(labelRepository)),
        ChangeNotifierProvider(create: (_) => PartyProvider(partyRepository)),
        ChangeNotifierProvider(
          create: (_) => MetricProvider(
            accountRepository: accountRepository,
            categoryRepository: categoryRepository,
            entryRepository: entryRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: const BandaApp(),
    ),
  );
}

class BandaApp extends StatelessWidget {
  const BandaApp({super.key});

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
      home: const Entrypoint(),
    );
  }
}
