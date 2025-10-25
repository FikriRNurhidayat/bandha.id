import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/providers/filter_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/providers/metric_provider.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/repositories/account_repository.dart';
import "package:banda/repositories/category_repository.dart";
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
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
  final labelRepository = await LabelRepository.build();

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
        ChangeNotifierProvider(create: (_) => LabelProvider(labelRepository)),
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
    final light = ThemeData.light();
    final dark = ThemeData.dark();

    return MaterialApp(
      title: 'Banda.io',
      debugShowCheckedModeBanner: false,
      theme: light.copyWith(
        textTheme: light.textTheme.apply(fontFamily: 'Eczar'),
      ),
      darkTheme: dark.copyWith(
        textTheme: dark.textTheme.apply(fontFamily: 'Eczar'),
      ),
      themeMode: ThemeMode.system,
      home: const Entrypoint(),
    );
  }
}
