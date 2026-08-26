import 'package:bandha/core/navigation/view_route.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:bandha/modules/classifiers/presentation/views/classifier_select_view.dart';
import 'package:flutter/material.dart';

class ClassifierRoutes {
  Route<dynamic>? make(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    switch (segments.length) {
      case 2
          when segments[0] == "category" &&
              segments[1] == "select": // /category/select
        return ViewRoute<Iterable<Item<Category>>>(
          settings: settings,
          builder: (context) => ClassifierSelectView<Category>.builder(context),
        );
      case 2
          when segments[0] == "label" &&
              segments[1] == "select": // /label/select
        return ViewRoute<Iterable<Item<Label>>>(
          settings: settings,
          builder: (context) => ClassifierSelectView<Label>.builder(context),
        );
      case 2
          when segments[0] == "party" &&
              segments[1] == "select": // /party/select
        return ViewRoute<Iterable<Item<Party>>>(
          settings: settings,
          builder: (context) => ClassifierSelectView<Party>.builder(context),
        );
    }

    return null;
  }
}
