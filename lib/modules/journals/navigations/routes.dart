import 'package:bandha/core/navigation/view_route.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/presentation/views/journal_editor_view.dart';
import 'package:bandha/modules/journals/presentation/views/journal_entry_list_view.dart';
import 'package:bandha/modules/journals/presentation/views/journal_list_view.dart';
import 'package:flutter/material.dart';

class JournalRoutes {
  Route<dynamic>? make(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty || segments.first != 'journals') return null;

    switch (segments.length) {
      case 1: // /journals
        return ViewRoute(
          settings: settings,
          builder: (context) => JournalListView(),
        );
      case 2 when segments[1] == 'new': // /journals/new
        return ViewRoute<Draft<Journal>>(
          settings: settings,
          builder: (context) => JournalEditorView(),
        );
      case 3 when segments[2] == 'edit':
        return ViewRoute<Draft<Journal>>(
          settings: settings,
          builder: (context) =>
              JournalEditorView(id: segments[1], readOnly: false),
        );
      case 3 when segments[2] == 'detail': // /journals/:id/detail
        return ViewRoute<Draft<Journal>>(
          settings: settings,
          builder: (context) =>
              JournalEditorView(id: segments[1], readOnly: true),
        );
      case 3 when segments[2] == 'entries': // /journals/:id/entries
        return ViewRoute<bool>(
          settings: settings,
          builder: (context) => JournalEntryListView(id: segments[1]),
        );
    }

    return null;
  }
}
