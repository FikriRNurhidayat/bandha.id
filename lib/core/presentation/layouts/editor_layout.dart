import 'package:bandha/core/presentation/services/platform_keyboard.dart';
import 'package:bandha/core/presentation/services/platform_keyboard_binding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditorLayout<D> extends StatefulWidget {
  const EditorLayout({
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
  State<EditorLayout<D>> createState() => _EditorLayoutState<D>();
}

class _EditorLayoutState<D> extends State<EditorLayout<D>> {
  @override
  initState() {
    super.initState();
    PlatformKeyboardBinding.instance.attach();
  }

  @override
  dispose() {
    PlatformKeyboardBinding.instance.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PlatformKeyboard(
      notifier: PlatformKeyboardBinding.instance.notifier,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name, style: theme.textTheme.titleMedium),
          automaticallyImplyLeading: false,
          actions: [
            if (!widget.readOnly)
              IconButton(
                onPressed: () async {
                  await widget.onSubmit?.call();
                },
                icon: Icon(Icons.check),
              ),
          ],
        ),
        body: SafeArea(
          child: ValueListenableBuilder<AsyncSnapshot<D?>>(
            valueListenable: widget.notifier,
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

              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: widget.builder(context),
              );
            },
          ),
        ),
      ),
    );
  }
}
