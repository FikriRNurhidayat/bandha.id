import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XEditorLayout<D> extends StatelessWidget {
  const XEditorLayout({
    super.key,
    required this.name,
    required this.builder,
    required this.notifier,
    this.readOnly = false,
    this.onSubmit,
  });

  final String name;
  final WidgetBuilder builder;
  final bool readOnly;
  final AsyncCallback? onSubmit;
  final ValueListenable<AsyncSnapshot<D?>> notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: theme.textTheme.titleMedium),
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
      resizeToAvoidBottomInset: true,
      body: ValueListenableBuilder<AsyncSnapshot<D?>>(
        valueListenable: notifier,
        builder: (context, snapshot, child) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint("snapshot.error: ${snapshot.error}");
            debugPrint("snapshot.stackTrace: ${snapshot.stackTrace}");

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

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: builder(context),
          );
        },
      ),
    );
  }
}
