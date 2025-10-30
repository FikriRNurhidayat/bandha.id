import 'package:banda/views/list_saving_view.dart';
import 'package:banda/views/list_account_view.dart';
import 'package:banda/views/list_entry_view.dart';
import 'package:banda/views/list_loan_view.dart';
import 'package:banda/views/list_transfer_view.dart';
import 'package:banda/views/tools_view.dart';
import 'package:flutter/material.dart';

class MainMenuView extends StatefulWidget {
  const MainMenuView({super.key});

  @override
  State<StatefulWidget> createState() => _MainMenuViewState();
}

class ViewView {
  final String title;
  final IconData icon;
  final Widget? child;
  final Widget? fab;
  final List<Widget> Function(BuildContext)? actionsBuilder;
  final Widget Function(BuildContext)? fabBuilder;

  ViewView({
    required this.title,
    required this.icon,
    this.fab,
    this.child,
    this.fabBuilder,
    this.actionsBuilder,
  });
}

class _MainMenuViewState extends State<MainMenuView> {
  int _current = 0;

  final List<ViewView> _screens = [
    ViewView(
      title: ListEntryView.title,
      icon: ListEntryView.icon,
      child: ListEntryView(),
      fabBuilder: ListEntryView.fabBuilder,
      actionsBuilder: ListEntryView.actionsBuilder,
    ),
    ViewView(
      title: ListSavingView.title,
      icon: ListSavingView.icon,
      child: ListSavingView(),
      fabBuilder: ListSavingView.fabBuilder,
      actionsBuilder: ListSavingView.actionsBuilder,
    ),
    ViewView(
      title: ListLoanView.title,
      icon: ListLoanView.icon,
      child: ListLoanView(),
      fabBuilder: ListLoanView.fabBuilder,
      actionsBuilder: ListLoanView.actionsBuilder,
    ),
    ViewView(
      title: ListTransferView.title,
      icon: ListTransferView.icon,
      child: ListTransferView(),
      fabBuilder: ListTransferView.fabBuilder,
    ),
    ViewView(
      title: ListAccountView.title,
      icon: ListAccountView.icon,
      fabBuilder: ListAccountView.fabBuilder,
      child: ListAccountView(),
    ),
    ViewView(
      title: ToolsView.title,
      icon: ToolsView.icon,
      child: ToolsView(),
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
