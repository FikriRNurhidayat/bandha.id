import 'package:banda/views/list_saving_screen.dart';
import 'package:banda/views/list_account_screen.dart';
import 'package:banda/views/list_entry_screen.dart';
import 'package:banda/views/list_loan_screen.dart';
import 'package:banda/views/list_transfer_screen.dart';
import 'package:banda/views/tools_screen.dart';
import 'package:flutter/material.dart';

class Entrypoint extends StatefulWidget {
  const Entrypoint({super.key});

  @override
  State<StatefulWidget> createState() => _EntrypointState();
}

class ViewScreen {
  final String title;
  final IconData icon;
  final Widget? child;
  final Widget? fab;
  final List<Widget> Function(BuildContext)? actionsBuilder;
  final Widget Function(BuildContext)? fabBuilder;

  ViewScreen({
    required this.title,
    required this.icon,
    this.fab,
    this.child,
    this.fabBuilder,
    this.actionsBuilder,
  });
}

class _EntrypointState extends State<Entrypoint> {
  int _current = 0;

  final List<ViewScreen> _screens = [
    ViewScreen(
      title: ListEntryScreen.title,
      icon: ListEntryScreen.icon,
      child: ListEntryScreen(),
      fabBuilder: ListEntryScreen.fabBuilder,
      actionsBuilder: ListEntryScreen.actionsBuilder,
    ),
    ViewScreen(
      title: ListSavingScreen.title,
      icon: ListSavingScreen.icon,
      child: ListSavingScreen(),
      fabBuilder: ListSavingScreen.fabBuilder,
      actionsBuilder: ListSavingScreen.actionsBuilder,
    ),
    ViewScreen(
      title: ListLoanScreen.title,
      icon: ListLoanScreen.icon,
      child: ListLoanScreen(),
      fabBuilder: ListLoanScreen.fabBuilder,
      actionsBuilder: ListLoanScreen.actionsBuilder,
    ),
    ViewScreen(
      title: ListTransferScreen.title,
      icon: ListTransferScreen.icon,
      child: ListTransferScreen(),
      fabBuilder: ListTransferScreen.fabBuilder,
    ),
    ViewScreen(
      title: ListAccountScreen.title,
      icon: ListAccountScreen.icon,
      fabBuilder: ListAccountScreen.fabBuilder,
      child: ListAccountScreen(),
    ),
    ViewScreen(
      title: ToolsScreen.title,
      icon: ToolsScreen.icon,
      child: ToolsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = _screens[_current];

    return Scaffold(
      body: screen.child,
      appBar: AppBar(
        title: Text(
          screen.title,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: screen.actionsBuilder?.call(context),
        actionsPadding: EdgeInsets.all(8),
      ),
      drawer: NavigationDrawer(
        header: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Banda.io",
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.start,
          ),
        ),
        tilePadding: EdgeInsets.symmetric(horizontal: 8),
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        onDestinationSelected: (index) {
          setState(() => _current = index);
          Navigator.pop(context);
        },
        children: [
          for (int i = 0; i < _screens.length; i++)
            NavigationDrawerDestination(
              icon: SizedBox.shrink(),
              label: Text(
                _screens[i].title,
                style: TextStyle(
                  color: _current == i
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: _current == i ? FontWeight.bold : FontWeight.w100,
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
      floatingActionButton: screen.fabBuilder?.call(context),
    );
  }
}
