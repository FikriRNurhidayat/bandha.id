import 'package:bandha/core/navigation/view_route.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/presentation/views/transfer_editor_view.dart';
import 'package:bandha/modules/transfers/presentation/views/transfer_entry_list_view.dart';
import 'package:bandha/modules/transfers/presentation/views/transfer_list_view.dart';
import 'package:flutter/material.dart';

class TransferRoutes {
  Route<dynamic>? make(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty || segments.first != 'transfers') return null;

    switch (segments.length) {
      case 1: // /transfers
        return ViewRoute(
          settings: settings,
          builder: (context) => TransferListView(),
        );
      case 2 when segments[1] == 'new': // /transfers/new
        return ViewRoute<Draft<Transfer>>(
          settings: settings,
          builder: (context) => TransferEditorView(),
        );
      case 3 when segments[2] == 'edit':
        return ViewRoute<Draft<Transfer>>(
          settings: settings,
          builder: (context) =>
              TransferEditorView(id: segments[1], readOnly: false),
        );
      case 3 when segments[2] == 'detail': // /transfers/:id/detail
        return ViewRoute<Draft<Transfer>>(
          settings: settings,
          builder: (context) =>
              TransferEditorView(id: segments[1], readOnly: true),
        );
      case 3 when segments[2] == 'entries': // /transfers/:id/entries
        return ViewRoute<Draft<Transfer>>(
          settings: settings,
          builder: (context) => TransferEntryListView(id: segments[1]),
        );
    }

    return null;
  }
}
