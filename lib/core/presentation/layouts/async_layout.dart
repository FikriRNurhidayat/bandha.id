import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AsyncLayout<T> extends StatelessWidget {
  final String title;
  final ValueListenable<AsyncSnapshot<T>> notifier;
  final WidgetBuilder builder;
  final Widget? floatingActionButton;

  const AsyncLayout({
    super.key,
    required this.title,
    required this.notifier,
    required this.builder,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: theme.textTheme.titleMedium),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: floatingActionButton,
      body: ValueListenableBuilder<AsyncSnapshot<T>>(
        valueListenable: notifier,
        builder: (context, snapshot, child) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          }

          if (snapshot.hasError) {
            return ListView(
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
          }

          if (!snapshot.hasData) {
            return ListView(
              children: [
                ListTile(
                  dense: true,
                  title: Text("Nihil", style: theme.textTheme.titleSmall),
                  subtitle: Text("No data available."),
                ),
              ],
            );
          }

          return builder(context);
        },
      ),
    );
  }
}
