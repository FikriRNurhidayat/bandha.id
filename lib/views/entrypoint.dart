import 'package:banda/views/analytic_screen.dart';
import 'package:banda/views/list_account_screen.dart';
import 'package:banda/views/list_entry_screen.dart';
import 'package:banda/views/list_transfer_screen.dart';
import 'package:banda/views/tool_screen.dart';
import 'package:flutter/material.dart';

class Entrypoint extends StatefulWidget {
  const Entrypoint({super.key});

  @override
  State<StatefulWidget> createState() => _EntrypointState();
}

class TabScreen {
  final String name;
  final IconData icon;
  final Widget child;
  final Widget Function(BuildContext)? fabBuilder;

  TabScreen({
    required this.name,
    required this.icon,
    required this.child,
    this.fabBuilder,
  });
}

class ViewScreen {
  final String title;
  final IconData icon;
  final Widget? child;
  final Widget? fab;
  final List<Widget> Function(BuildContext)? actionsBuilder;
  final Widget Function(BuildContext)? fabBuilder;
  final List<TabScreen>? tabs;

  ViewScreen({
    required this.title,
    required this.icon,
    this.fab,
    this.child,
    this.tabs,
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
      title: AnalyticScreen.title,
      icon: AnalyticScreen.icon,
      actionsBuilder: AnalyticScreen.actionsBuilder,
      child: AnalyticScreen(),
    ),
    ViewScreen(
      title: ToolScreen.title,
      icon: ToolScreen.icon,
      child: ToolScreen(),
    ),
  ];

  List<Widget> _menu() {
    return _screens
        .map(
          (screen) => NavigationDestination(
            icon: Icon(screen.icon),
            label: screen.title,
          ),
        )
        .toList();
  }

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
        centerTitle: false,
        actions: screen.actionsBuilder?.call(context),
        actionsPadding: EdgeInsets.all(8),
      ),
      bottomNavigationBar: NavigationBar(
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontFamily: theme.textTheme.headlineSmall!.fontFamily),
        ),
        selectedIndex: _current,
        destinations: _menu(),
        onDestinationSelected: (value) {
          setState(() {
            _current = value;
          });
        },
      ),
      floatingActionButton: screen.fabBuilder?.call(context),
    );
  }
}
