import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ListLayout<I> extends StatelessWidget {
  final String title;
  final ValueListenable<List<I>> valueListenable;
  final WidgetBuilder builder;

  const ListLayout({
    super.key,
    required this.title,
    required this.valueListenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: theme.textTheme.titleMedium),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder<List<I>>(
        valueListenable: valueListenable,
        builder: (context, list, child) {
          if (list.isEmpty) {
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
