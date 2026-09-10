import 'package:bandha/core/navigation/view_route.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/views/entry_editor_view.dart';
import 'package:bandha/modules/entries/presentation/views/entry_list_view.dart';
import 'package:flutter/material.dart';

class EntryRoutes {
  Route<dynamic>? make(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty || segments.first != 'entries') return null;

    switch (segments.length) {
      case 1: // /entries
        return ViewRoute(
          settings: settings,
          builder: (context) => EntryListView(),
        );
      case 2: // /entries/new
        return ViewRoute<Draft<Entry>>(
          settings: settings,
          builder: (context) => EntryEditorView(),
        );
      case 3 when segments[2] == 'detail': // /entries/:id/detail
        return ViewRoute<Draft<Entry>>(
          settings: settings,
          builder: (context) =>
              EntryEditorView(id: segments[1], readOnly: true),
        );
      case 3 when segments[2] == 'edit': // /entries/:id/detail
        return ViewRoute<Draft<Entry>>(
          settings: settings,
          builder: (context) =>
              EntryEditorView(id: segments[1], readOnly: false),
        );
    }

    return null;
  }
}
