import 'package:bandha/core/navigation/view_route.dart';
import 'package:bandha/modules/assets/presentation/views/asset_editor_view.dart';
import 'package:bandha/modules/assets/presentation/views/asset_list_view.dart';
import 'package:flutter/material.dart';

class AssetRoutes {
  Route<dynamic>? make(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null) return null;

    final segments = uri.pathSegments; // e.g. ['assets', '123', 'edit']

    if (segments.isEmpty || segments.first != 'assets') return null;

    switch (segments.length) {
      case 1: // /assets
        return ViewRoute(
          settings: settings,
          builder: (_) => const AssetListView(),
        );

      case 2 when segments[1] == 'new': // /assets/new
        return ViewRoute<bool>(
          settings: settings,
          builder: (_) => const AssetEditorView(),
        );

      case 3 when segments[2] == 'edit': // /assets/:id/edit
        final id = segments[1];
        return ViewRoute(
          settings: settings,
          builder: (_) => AssetEditorView(id: id, readOnly: false),
        );

      case 3 when segments[2] == 'detail': // /assets/:id/detail
        final id = segments[1];
        return ViewRoute(
          settings: settings,
          builder: (_) => AssetEditorView(id: id, readOnly: true),
        );
    }

    return null;
  }
}
