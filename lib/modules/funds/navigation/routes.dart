import 'package:bandha/core/navigation/view_route.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/presentation/views/fund_editor_view.dart';
import 'package:bandha/modules/funds/presentation/views/fund_entry_editor_view.dart';
import 'package:bandha/modules/funds/presentation/views/fund_entry_list_view.dart';
import 'package:bandha/modules/funds/presentation/views/fund_list_view.dart';
import 'package:flutter/material.dart';

class FundRoutes {
  Route<dynamic>? make(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty || segments.first != 'funds') return null;

    switch (segments.length) {
      case 1: // /funds
        return ViewRoute(
          settings: settings,
          builder: (context) => FundListView(),
        );
      case 2 when segments[1] == 'new': // /funds/new
        return ViewRoute<Draft<Fund>>(
          settings: settings,
          builder: (context) => FundEditorView(),
        );
      case 3 when segments[2] == 'entries':
        return ViewRoute<Draft<Fund>>(
          settings: settings,
          builder: (context) => FundEntryListView(id: segments[1]),
        );
      case 3 when segments[2] == 'edit':
        return ViewRoute<Draft<Fund>>(
          settings: settings,
          builder: (context) =>
              FundEditorView(id: segments[1], readOnly: false),
        );
      case 3 when segments[2] == 'detail': // /funds/:id/detail
        return ViewRoute<Draft<Fund>>(
          settings: settings,
          builder: (context) => FundEditorView(id: segments[1], readOnly: true),
        );
      case 4
          when segments[2] == 'entries' &&
              segments[3] == 'new': // /funds/:id/entries/new
        return ViewRoute<Draft<Entry>>(
          settings: settings,
          builder: (context) =>
              FundEntryEditorView(controllerId: segments[1], readOnly: false),
        );
      case 5
          when segments[2] == 'entries' &&
              segments[4] == 'edit': // /funds/:fundId/entries/:entryId/edit
        return ViewRoute<Draft<Entry>>(
          settings: settings,
          builder: (context) => FundEntryEditorView(
            controllerId: segments[1],
            entryId: segments[3],
            readOnly: false,
          ),
        );
      case 5
          when segments[2] == 'entries' &&
              segments[4] == 'detail': // /funds/:fundId/entries/:entryId/detail
        return ViewRoute<Draft<Entry>>(
          settings: settings,
          builder: (context) => FundEntryEditorView(
            controllerId: segments[1],
            entryId: segments[3],
            readOnly: true,
          ),
        );
    }

    return null;
  }
}
