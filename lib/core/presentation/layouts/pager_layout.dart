import 'package:bandha/core/presentation/types/pager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PagerLayout<I> extends StatelessWidget {
  final String title;
  final ValueListenable<AsyncSnapshot<Pager<I>>> valueListenable;
  final WidgetBuilder builder;
  final Widget? floatingActionButton;
  final PreferredSizeWidget Function(BuildContext) appBarBuilder;

  const PagerLayout({
    super.key,
    required this.title,
    required this.valueListenable,
    required this.builder,
    required this.appBarBuilder,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: valueListenable,
      builder: (context, snapshot, child) {
        Widget body;

        if (snapshot.connectionState == ConnectionState.waiting) {
          body = SizedBox.shrink();
        } else if (snapshot.hasError) {
          body = ListView(
            children: [
              ListTile(
                dense: true,
                title: Text(
                  snapshot.error.runtimeType.toString(),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  snapshot.stackTrace?.toString() ??
                      "Stack trace is not available.",
                ),
              ),
            ],
          );
        } else if (!snapshot.hasData || snapshot.requireData.isEmpty) {
          body = ListView(
            children: [
              ListTile(
                dense: true,
                title: Text("Nihil", style: theme.textTheme.titleSmall),
                subtitle: Text("No data available."),
              ),
            ],
          );
        } else {
          body = builder(context);
        }

        return Scaffold(
          appBar: appBarBuilder(context),
          floatingActionButton: floatingActionButton,
          body: body,
        );
      },
    );
  }
}
