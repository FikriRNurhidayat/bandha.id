import 'package:bandha/core/navigation/view_route.dart';
import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:bandha/modules/assets/presentation/views/asset_editor_view.dart';
import 'package:bandha/modules/assets/presentation/views/asset_entry_list_view.dart';
import 'package:bandha/modules/assets/presentation/views/asset_list_view.dart';
import 'package:flutter/material.dart';

class AssetRoutes {
  Route<dynamic>? make(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty || segments.first != 'assets') return null;

    switch (segments.length) {
      case 1: // /assets
        return ViewRoute(
          settings: settings,
          builder: (context) => AssetListView(),
        );
      case 2 when segments[1] == 'new': // /assets/new
        return ViewRoute<AssetDisplay>(
          settings: settings,
          builder: (context) => AssetEditorView(),
        );
      case 3 when segments[2] == 'edit':
        return ViewRoute<AssetDisplay>(
          settings: settings,
          builder: (context) =>
              AssetEditorView(id: segments[1], readOnly: false),
        );
      case 3 when segments[2] == 'detail': // /assets/:id/detail
        return ViewRoute(
          settings: settings,
          builder: (context) =>
              AssetEditorView(id: segments[1], readOnly: true),
        );
      case 3 when segments[2] == 'entries': // /assets/:id/entries
        return ViewRoute(
          settings: settings,
          builder: (context) => AssetEntryListView(id: segments[1]),
        );
    }

    return null;
  }
}
