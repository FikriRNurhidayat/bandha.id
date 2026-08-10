import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/navigation/routes.dart';
import 'package:bandha/core/presentation/widgets/observers/keyboard_observer.dart';
import 'package:bandha/module.dart';
import 'package:flutter/material.dart' hide Router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KeyboardObserver.instance;

  final c = await bootstrap();
  runApp(DependencyInjector(c: c, child: const Main()));
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    final light = ThemeData.light(useMaterial3: true);
    final dark = ThemeData.dark(useMaterial3: true);
    final routes = Routes();

    return MaterialApp(
      title: 'Bandha.id',
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
      onGenerateRoute: routes.make,
    );
  }
}
