import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String content;
  final Future<void> Function(BuildContext context) onConfirm;
  final Future<void> Function(BuildContext context) onDeny;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxWidth = 768.0;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: (width * 0.5).clamp(0, maxWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(
                content,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.justify,
              ),
              Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await onDeny(context);
                      if (context.mounted) {
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: Text("No", style: theme.textTheme.bodySmall),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await onConfirm(context);

                      if (context.mounted) {
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: Text(
                      "Yes",
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> showAppDialog(
  BuildContext context, {
  required String title,
  required String content,
  required Future<void> Function(BuildContext context) onConfirm,
  Future<void> Function(BuildContext context)? onDeny,
}) async {
  final navigator = Navigator.of(context);
  onDeny ??= (BuildContext context) async {};

  final reply = await navigator.push<bool>(
    PageRouteBuilder(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (dialogContext, animation, secondaryAnimation) =>
          AppDialog(
            title: title,
            content: content,
            onConfirm: onConfirm,
            onDeny: onDeny!,
          ),
      fullscreenDialog: true,
    ),
  );

  if (reply is bool) {
    return reply;
  }

  return false;
}
