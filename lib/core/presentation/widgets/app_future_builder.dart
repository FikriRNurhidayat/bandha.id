import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppFutureBuilder<T> extends StatelessWidget {
  const AppFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.initialData,
    this.onLoading,
    this.onError,
    this.onEmpty,
  });

  final Future<T>? future;
  final AsyncWidgetBuilder<T> builder;
  final T? initialData;

  final WidgetBuilder? onLoading;
  final Widget Function(BuildContext, Object, StackTrace?)? onError;
  final WidgetBuilder? onEmpty;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        final theme = Theme.of(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return onLoading?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          if (kDebugMode) {
            debugPrint('${snapshot.error}');
            debugPrint('${snapshot.stackTrace}');
          }

          return onError?.call(
                context,
                snapshot.error!,
                snapshot.stackTrace,
              ) ??
              ListView(
                children: [
                  ListTile(
                    dense: true,
                    title: Text(
                      snapshot.error.runtimeType.toString(),
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(snapshot.error.toString()),
                  ),
                ],
              );
        }

        final data = snapshot.data;
        if (data == null ||
            (data is Iterable && (data as Iterable).isEmpty)) {
          return onEmpty?.call(context) ??
              ListView(
                children: [
                  ListTile(
                    dense: true,
                    title: Text(
                      "Nihil",
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      "No information is available to display.",
                    ),
                  ),
                ],
              );
        }

        return builder(context, snapshot);
      },
    );
  }
}
