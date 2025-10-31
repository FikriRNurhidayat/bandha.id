import 'package:banda/views/account_list_view.dart';
import 'package:banda/views/bill_list_view.dart';
import 'package:banda/views/entry_list_view.dart';
import 'package:banda/views/loan_list_view.dart';
import 'package:banda/views/savings_list_view.dart';
import 'package:banda/views/transfer_list_view.dart';
import 'package:banda/views/tools_view.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<StatefulWidget> createState() => _MainMenuState();
}

class MenuItem {
  final String title;
  final IconData icon;
  final Widget? child;
  final Widget? fab;
  final List<Widget> Function(BuildContext)? actionsBuilder;
  final Widget Function(BuildContext)? fabBuilder;

  MenuItem({
    required this.title,
    required this.icon,
    this.fab,
    this.child,
    this.fabBuilder,
    this.actionsBuilder,
  });
}

class _MainMenuState extends State<MainMenu> {
  int _current = 0;

  final List<MenuItem> _screens = [
    MenuItem(
      title: EntryListView.title,
      icon: EntryListView.icon,
      child: EntryListView(),
      fabBuilder: EntryListView.fabBuilder,
      actionsBuilder: EntryListView.actionsBuilder,
    ),
    MenuItem(
      title: SavingsListView.title,
      icon: SavingsListView.icon,
      child: SavingsListView(),
      fabBuilder: SavingsListView.fabBuilder,
      actionsBuilder: SavingsListView.actionsBuilder,
    ),
    MenuItem(
      title: LoanListView.title,
      icon: LoanListView.icon,
      child: LoanListView(),
      fabBuilder: LoanListView.fabBuilder,
      actionsBuilder: LoanListView.actionsBuilder,
    ),
    MenuItem(
      title: BillListView.title,
      icon: BillListView.icon,
      child: BillListView(),
      fabBuilder: BillListView.fabBuilder,
      actionsBuilder: BillListView.actionsBuilder,
    ),
    MenuItem(
      title: TransferListView.title,
      icon: TransferListView.icon,
      child: TransferListView(),
      fabBuilder: TransferListView.fabBuilder,
    ),
    MenuItem(
      title: AccountListView.title,
      icon: AccountListView.icon,
      fabBuilder: AccountListView.fabBuilder,
      child: AccountListView(),
    ),
    MenuItem(title: ToolsView.title, icon: ToolsView.icon, child: ToolsView()),
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
      drawer: SizedBox.expand(
        child: NavigationDrawer(
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _current == i
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: _current == i
                        ? FontWeight.bold
                        : FontWeight.w100,
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),
          ],
        ),
      ),
      floatingActionButton: screen.fabBuilder?.call(context),
    );
  }
}
