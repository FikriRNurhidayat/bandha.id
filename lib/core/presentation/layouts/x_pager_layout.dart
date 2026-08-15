import 'package:bandha/core/presentation/types/pager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XPagerLayout<I> extends StatelessWidget {
  final String title;
  final ValueListenable<AsyncSnapshot<Pager<I>>> valueListenable;
  final WidgetBuilder builder;
  final Widget? floatingActionButton;

  const XPagerLayout({
    super.key,
    required this.title,
    required this.valueListenable,
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
      body: ValueListenableBuilder<AsyncSnapshot<Pager<I>>>(
        valueListenable: valueListenable,
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

          if (!snapshot.hasData || snapshot.requireData.isEmpty) {
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
