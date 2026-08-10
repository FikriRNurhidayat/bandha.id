import 'package:bandha/core/navigation/view_route.dart';
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
      // case 2 when segments[1] == 'new': // /funds/new
      //   return ViewRoute<Draft<Fund>>(
      //     settings: settings,
      //     builder: (context) => FundEditorView(),
      //   );
      // case 3 when segments[2] == 'edit':
      //   return ViewRoute<Draft<Fund>>(
      //     settings: settings,
      //     builder: (context) =>
      //         FundEditorView(id: segments[1], readOnly: false),
      //   );
      // case 3 when segments[2] == 'detail': // /funds/:id/detail
      //   return ViewRoute(
      //     settings: settings,
      //     builder: (context) =>
      //         FundEditorView(id: segments[1], readOnly: true),
      //   );
    }

    return null;
  }
}
