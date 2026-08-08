import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppEditorLayout<UIModel> extends StatelessWidget {
  const AppEditorLayout({
    super.key,
    required this.title,
    required this.builder,
    required this.valueListenable,
    this.readOnly = false,
    this.onSubmit,
  });

  final String title;
  final WidgetBuilder builder;
  final bool readOnly;
  final AsyncCallback? onSubmit;
  final ValueListenable<AsyncSnapshot<UIModel?>> valueListenable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: theme.textTheme.titleMedium),
        automaticallyImplyLeading: false,
        actions: [
          if (!readOnly)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () async {
                  await onSubmit?.call();
                },
                icon: Icon(Icons.check),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<AsyncSnapshot<UIModel?>>(
          valueListenable: valueListenable,
          builder: (context, snapshot, child) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
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

            return builder(context);
          },
        ),
      ),
    );
  }
}
