import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AsyncLayout<T> extends StatelessWidget {
  final String title;
  final ValueListenable<AsyncSnapshot<T>> notifier;
  final WidgetBuilder builder;
  final Widget? Function(BuildContext)? fabBuilder;
  final Widget? fab;

  const AsyncLayout({
    super.key,
    required this.title,
    required this.notifier,
    required this.builder,
    this.fab,
    this.fabBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<AsyncSnapshot<T>>(
      valueListenable: notifier,
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
        } else if (!snapshot.hasData) {
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
          appBar: AppBar(
            title: Text(title, style: theme.textTheme.titleMedium),
            automaticallyImplyLeading: false,
          ),
          floatingActionButton: fabBuilder?.call(context) ?? fab,
          body: body,
        );
      },
    );
  }
}
