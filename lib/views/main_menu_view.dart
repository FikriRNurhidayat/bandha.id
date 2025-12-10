import 'package:flutter/material.dart';

class MainMenuView extends StatelessWidget {
  MainMenuView({super.key});

  final Map<String, String> menu = {
    "Entries": "/entries",
    "Accounts": "/accounts",
    "Transfers": "/transfers",
    "Loans": "/loans",
    "Bills": "/bills",
    "Funds": "/funds",
    "Budgets": "/budgets",
    "Tools": "/tools",
    "Info": "/info",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: menu.length,
          itemBuilder: (context, index) {
            final item = menu.entries.elementAt(index);
            return ListTile(
              title: Text(item.key, textAlign: TextAlign.center),
              onTap: () {
                Navigator.pushNamed(context, item.value);
              },
            );
          },
        ),
      ),
    );
  }
}
