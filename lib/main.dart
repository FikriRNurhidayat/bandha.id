import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/navigation/routes.dart';
import 'package:bandha/module.dart';
import 'package:flutter/material.dart' hide Router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final c = await bootstrap();
  runApp(DependencyInjector(c: c, child: const Main()));
}

class Main extends StatelessWidget {
  const Main({super.key});

  ThemeData adjustTheme(ThemeData theme) {
    return theme.copyWith(
      dialogTheme: theme.dialogTheme.copyWith(
        barrierColor: theme.colorScheme.surface,
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w300,
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w300,
        ),
      ),
      datePickerTheme: theme.datePickerTheme.copyWith(
        backgroundColor: theme.colorScheme.surface,
        dividerColor: theme.colorScheme.surface,
        toggleButtonTextStyle: theme.datePickerTheme.toggleButtonTextStyle
            ?.copyWith(color: theme.colorScheme.onSurface),
        headerHeadlineStyle: theme.datePickerTheme.headerHeadlineStyle
            ?.copyWith(color: theme.colorScheme.onSurface),
        headerHelpStyle: theme.datePickerTheme.headerHelpStyle?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        weekdayStyle: theme.datePickerTheme.weekdayStyle?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        dayStyle: theme.datePickerTheme.dayStyle?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        yearStyle: theme.datePickerTheme.yearStyle?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        rangePickerHeaderHeadlineStyle: theme
            .datePickerTheme
            .rangePickerHeaderHeadlineStyle
            ?.copyWith(color: theme.colorScheme.onSurface),
        rangePickerHeaderHelpStyle: theme
            .datePickerTheme
            .rangePickerHeaderHelpStyle
            ?.copyWith(color: theme.colorScheme.onSurface),
        shape: RoundedRectangleBorder(),
      ),
      timePickerTheme: theme.timePickerTheme.copyWith(
        backgroundColor: theme.colorScheme.surface,
        dialBackgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(),
      ),
      colorScheme: theme.colorScheme.copyWith(
        surfaceTint: theme.colorScheme.surface,
        primary: theme.colorScheme.onSurface,
        primaryFixed: theme.colorScheme.onSurface,
        primaryFixedDim: theme.colorScheme.onSurface,
        primaryContainer: theme.colorScheme.onSurface,
        onPrimaryContainer: theme.colorScheme.surface,
        onPrimary: theme.colorScheme.surface,
        onPrimaryFixed: theme.colorScheme.surface,
        onPrimaryFixedVariant: theme.colorScheme.surface,
        secondary: theme.colorScheme.onSurface,
        secondaryFixed: theme.colorScheme.onSurface,
        secondaryFixedDim: theme.colorScheme.onSurface,
        secondaryContainer: theme.colorScheme.onSurface,
        onSecondaryContainer: theme.colorScheme.surface,
        onSecondary: theme.colorScheme.surface,
        onSecondaryFixed: theme.colorScheme.surface,
        onSecondaryFixedVariant: theme.colorScheme.surface,
        tertiary: theme.colorScheme.onSurface,
        tertiaryFixed: theme.colorScheme.onSurface,
        tertiaryFixedDim: theme.colorScheme.onSurface,
        tertiaryContainer: theme.colorScheme.onSurface,
        onTertiaryContainer: theme.colorScheme.surface,
        onTertiary: theme.colorScheme.surface,
        onTertiaryFixed: theme.colorScheme.surface,
        onTertiaryFixedVariant: theme.colorScheme.surface,
        inversePrimary: theme.colorScheme.surface,
      ),
      textTheme: theme.textTheme.apply(fontFamily: 'Eczar'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData.light(useMaterial3: true);
    final dark = ThemeData.dark(useMaterial3: true);
    final routes = Routes();

    return MaterialApp(
      title: 'Bandha.id',
      debugShowCheckedModeBanner: false,
      theme: adjustTheme(light),
      darkTheme: adjustTheme(dark),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: routes.make,
    );
  }
}
