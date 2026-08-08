import 'package:bandha/core/navigation/view_route.dart';
import 'package:bandha/modules/assets/navigation/routes.dart';
import 'package:bandha/modules/journals/navigations/routes.dart';
import 'package:bandha/modules/root/presentation/views/menu_view.dart';
import 'package:bandha/modules/tools/presentation/views/tool_list_view.dart';
import 'package:flutter/material.dart';

class Routes {
  final assetRoutes = AssetRoutes();
  final journalRoutes = JournalRoutes();

  Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name!) {
      case '/':
        return ViewRoute(
          settings: settings,
          builder: (context) => const MenuView(),
        );
      case '/tools':
        return ViewRoute(
          settings: settings,
          builder: (context) => const ToolListView(),
        );
    }

    if (settings.name!.startsWith(RegExp("/assets"))) {
      return assetRoutes.make(settings);
    }

    if (settings.name!.startsWith(RegExp("/journals"))) {
      return journalRoutes.make(settings);
    }

    return null;
  }

  Route<dynamic> make(RouteSettings settings) {
    final route = getRoute(settings);
    if (route != null) {
      return route;
    }

    return ViewRoute(
      settings: settings,
      builder: (context) =>
          Scaffold(body: Center(child: Text("You're not supposed to be here"))),
    );
  }
}
