import 'package:banda/providers/scaffold_provider.dart';
import 'package:banda/views/accounts/list_account_view.dart';
import 'package:banda/views/entries/list_entry_view.dart';
import 'package:banda/views/list_saving_screen.dart';
import 'package:banda/views/loans/list_loan_view.dart';
import 'package:banda/views/report_screen.dart';
import 'package:banda/views/list_transfer_screen.dart';
import 'package:banda/views/tool_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageView {
  final String title;
  final Widget? child;
  final Widget? fab;

  PageView({required this.title, this.fab, this.child});
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int current = 0;

  final List<PageView> pages = [
    PageView(title: "Entries", child: ListEntryView()),
    PageView(title: "Savings", child: ListSavingScreen()),
    PageView(title: "Loans", child: ListLoanView()),
    PageView(title: "Transfers", child: ListTransferScreen()),
    PageView(title: "Accounts", child: ListAccountView()),
    PageView(title: "Reports", child: ReportScreen()),
    PageView(title: "Tools", child: ToolsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final scaffoldProvider = context.watch<ScaffoldProvider>();
    final theme = Theme.of(context);
    final screen = pages[current];

    return Scaffold(
      body: screen.child,
      appBar: AppBar(
        title: Text(
          screen.title,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actionsPadding: EdgeInsets.all(8),
        actions: scaffoldProvider.actions,
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
          scaffoldProvider.reset();
          setState(() => current = index);
          Navigator.pop(context);
        },
        children: [
          for (int i = 0; i < pages.length; i++)
            NavigationDrawerDestination(
              icon: SizedBox.shrink(),
              label: Text(
                pages[i].title,
                style: TextStyle(
                  color: current == i
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: current == i ? FontWeight.bold : FontWeight.w100,
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
      floatingActionButton: scaffoldProvider.fab,
    );
  }
}
