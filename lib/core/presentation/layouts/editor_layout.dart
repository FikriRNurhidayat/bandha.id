import 'package:flutter/material.dart';

class EditorLayout extends StatelessWidget {
  const EditorLayout({
    super.key,
    required this.title,
    required this.child,
    this.readOnly = false,
    this.isLoading = false,
    this.onSubmit,
  });

  final String title;
  final Widget child;
  final bool readOnly;
  final bool isLoading;
  final Future<void> Function(BuildContext context)? onSubmit;

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
                onPressed: () {
                  onSubmit?.call(context);
                },
                icon: Icon(Icons.check),
              ),
            ),
        ],
      ),
      body: !isLoading
          ? Padding(padding: EdgeInsets.all(16), child: child)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
