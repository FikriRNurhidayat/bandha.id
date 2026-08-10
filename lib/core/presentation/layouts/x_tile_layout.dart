import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/layouts/async_layout.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XTileLayout<E extends Entity> extends StatelessWidget {
  final String title;
  final ValueListenable<AsyncSnapshot<Item<E>>> notifier;
  final WidgetBuilder builder;

  const XTileLayout({
    super.key,
    required this.title,
    required this.notifier,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncLayout(title: title, notifier: notifier, builder: builder);
  }
}
