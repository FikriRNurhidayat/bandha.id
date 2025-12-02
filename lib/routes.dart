import 'package:banda/views/account_edit_view.dart';
import 'package:banda/views/account_list_view.dart';
import 'package:banda/views/bill_edit_view.dart';
import 'package:banda/views/bill_filter_view.dart';
import 'package:banda/views/bill_list_view.dart';
import 'package:banda/views/bill_menu_view.dart';
import 'package:banda/views/budget_edit_view.dart';
import 'package:banda/views/budget_filter_view.dart';
import 'package:banda/views/budget_list_view.dart';
import 'package:banda/views/budget_menu_view.dart';
import 'package:banda/views/category_edit_view.dart';
import 'package:banda/views/entry_menu_view.dart';
import 'package:banda/views/info_view.dart';
import 'package:banda/views/label_edit_view.dart';
import 'package:banda/views/loan_menu_view.dart';
import 'package:banda/views/savings_detail_view.dart';
import 'package:banda/views/entry_edit_view.dart';
import 'package:banda/views/entry_filter_view.dart';
import 'package:banda/views/entry_list_view.dart';
import 'package:banda/views/loan_edit_view.dart';
import 'package:banda/views/loan_filter_view.dart';
import 'package:banda/views/loan_list_view.dart';
import 'package:banda/views/main_menu_view.dart';
import 'package:banda/views/savings_edit_view.dart';
import 'package:banda/views/savings_entry_edit_view.dart';
import 'package:banda/views/savings_filter_view.dart';
import 'package:banda/views/savings_list_view.dart';
import 'package:banda/views/tools_view.dart';
import 'package:banda/views/transfer_edit_view.dart';
import 'package:banda/views/transfer_list_view.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic>? makeRoutes(RouteSettings settings) {
    switch (settings.name!) {
      case '/':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MainMenuView(),
        );
      case '/entries':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => EntryListView(),
        );
      case '/entries/new':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => EntryEditView(),
        );
      case '/entries/filter':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => EntryFilterView(),
        );
      case '/loans':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => LoanListView(),
        );
      case '/loans/new':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => LoanEditView(),
        );
      case '/loans/filter':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => LoanFilterView(),
        );
      case '/budgets':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BudgetListView(),
        );
      case '/budgets/new':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BudgetEditView(),
        );
      case '/budgets/filter':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BudgetFilterView(),
        );
      case '/savings':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SavingsListView(),
        );
      case '/savings/new':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SavingsEditView(),
        );
      case '/savings/filter':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SavingsFilterView(),
        );
      case '/accounts':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => AccountListView(),
        );
      case '/accounts/new':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => AccountEditView(),
        );
      case '/transfers':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => TransferListView(),
        );
      case '/transfers/new':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => TransferEditView(),
        );
      case '/bills':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BillListView(),
        );
      case '/bills/new':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BillEditView(),
        );
      case '/bills/filter':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BillFilterView(),
        );
      case '/categories/edit':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => CategoryEditView(),
        );
      case '/labels/edit':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => LabelEditView(),
        );
      case '/tools':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ToolsView(),
        );
      case '/info':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => InfoView(),
        );
    }

    final uri = Uri.parse(settings.name!);
    if (uri.pathSegments.length == 3 && uri.pathSegments.last == "edit") {
      final id = uri.pathSegments[1];

      switch (uri.pathSegments.first) {
        case 'entries':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => EntryEditView(id: id),
          );
        case 'bills':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => BillEditView(id: id),
          );
        case 'loans':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => LoanEditView(id: id),
          );
        case 'budgets':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => BudgetEditView(id: id),
          );
        case 'accounts':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => AccountEditView(id: id),
          );
        case 'transfers':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => TransferEditView(id: id),
          );
        case 'savings':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => SavingsEditView(id: id),
          );
      }
    }

    if (uri.pathSegments.length == 3 && uri.pathSegments.last == "menu") {
      final id = uri.pathSegments[1];

      switch (uri.pathSegments.first) {
        case 'entries':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => EntryMenuView(id: id),
          );
        case 'bills':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => BillMenuView(id: id),
          );
        case 'budgets':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => BudgetMenuView(id: id),
          );
        case 'loans':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => LoanMenuView(id: id),
          );
      }
    }

    if (uri.pathSegments.length == 3 && uri.pathSegments.last == "detail") {
      final id = uri.pathSegments[1];

      switch (uri.pathSegments.first) {
        case 'entries':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => EntryEditView(id: id, readOnly: true),
          );
        case 'bills':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => BillEditView(id: id, readOnly: true),
          );
        case 'loans':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => LoanEditView(id: id, readOnly: true),
          );
        case 'budgets':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => BudgetEditView(id: id, readOnly: true),
          );
        case 'accounts':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => AccountEditView(id: id, readOnly: true),
          );
        case 'transfers':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => TransferEditView(id: id, readOnly: true),
          );
        case 'savings':
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => SavingsDetailView(id: id),
          );
      }
    }

    if (uri.pathSegments.length == 4) {
      if (uri.pathSegments.first == "savings" &&
          uri.pathSegments[2] == "entries" &&
          uri.pathSegments[3] == "new") {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) =>
              SavingEntryEditView(savingsId: uri.pathSegments[1]),
        );
      }
    }

    if (uri.pathSegments.length == 5) {
      if (uri.pathSegments.first == "savings" &&
          uri.pathSegments[2] == "entries" &&
          uri.pathSegments.last == "edit") {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SavingEntryEditView(
            savingsId: uri.pathSegments[1],
            entryId: uri.pathSegments[3],
          ),
        );
      }

      if (uri.pathSegments.first == "savings" &&
          uri.pathSegments[2] == "entries" &&
          uri.pathSegments.last == "detail") {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SavingEntryEditView(
            savingsId: uri.pathSegments[1],
            entryId: uri.pathSegments[3],
            readOnly: true,
          ),
        );
      }
    }

    return null;
  }
}
