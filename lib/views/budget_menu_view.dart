import 'package:banda/entity/budget.dart';
import 'package:banda/providers/budget_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class BudgetMenuView extends StatelessWidget {
  final String id;

  const BudgetMenuView({super.key, required this.id});

  Map<String, GestureTapCallback> menuBuilder(
    BuildContext context,
    Budget budget,
  ) {
    final navigator = Navigator.of(context);
    final budgetProvider = context.read<BudgetProvider>();

    final Map<String, VoidCallback> menu = {
      "Share": () {
        SharePlus.instance.share(
          ShareParams(
            uri: Uri(
              scheme: "app",
              host: "bandha.id",
              pathSegments: ["budgets", budget.id, "detail"],
            ),
          ),
        );
      },
    };

    if (budget.isOver() || budget.isUnder()) {
      menu["Carry over"] = () async {
        await budgetProvider.carryOver(budget.id);
        navigator.pop();
      };
    }

    menu["Repeat"] = () async {
      await budgetProvider.repeat(budget.id);
      navigator.pop();
    };

    if (budget.isModified()) {
      menu["Reset"] = () async {
        await budgetProvider.reset(budget.id);
        navigator.pop();
      };
    }

    if (kDebugMode) {
      menu["Debug reminder"] = () {
        budgetProvider.debugReminder(id);
      };
    }

    menu["Back"] = () {
      navigator.pop();
    };

    return menu;
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.read<BudgetProvider>();

    return Scaffold(
      body: FutureBuilder(
        future: budgetProvider.get(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("..."));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final budget = snapshot.data!;
          final menu = menuBuilder(context, budget);

          return Center(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: menu.length,
              itemBuilder: (context, index) {
                final callback = menu.entries.elementAt(index);
                return ListTile(
                  title: Text(callback.key, textAlign: TextAlign.center),
                  onTap: callback.value,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
