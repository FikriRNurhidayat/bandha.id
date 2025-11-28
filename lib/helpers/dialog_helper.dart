import 'package:banda/entity/entry.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool?> ask(
  BuildContext context, {
  required String title,
  required String content,
  required Future<void> Function(BuildContext context) onConfirm,
  Future<void> Function(BuildContext context)? onReject,
}) async {
  final theme = Theme.of(context);

  onReject ??= (BuildContext context) async {};

  return showDialog<bool>(
    context: context,
    builder: (context) {
      final navigator = Navigator.of(context);

      return AlertDialog(
        title: Text(title, style: theme.textTheme.titleMedium),
        alignment: Alignment.center,
        content: Text(content, style: theme.textTheme.bodySmall),
        actions: [
          TextButton(
            onPressed: () {
              onReject!(context)
                  .then((_) {
                    navigator.pop(false);
                  })
                  .catchError((_) {
                    navigator.pop(false);
                  });
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              onConfirm(context)
                  .then((_) {
                    navigator.pop(true);
                  })
                  .catchError((_) {
                    navigator.pop(false);
                  });
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

Future<bool?> confirmEntryDeletion(BuildContext context, Entry entry) async {
  return ask(
    context,
    title: "Delete entry",
    content:
        "You're about to delete this entry, this action cannot be reversed. Are you sure?",
    onConfirm: (context) async {
      final messenger = ScaffoldMessenger.of(context);
      final entryProvider = context.read<EntryProvider>();

      await entryProvider.delete(entry.id).catchError((error) {
        messenger.showSnackBar(SnackBar(content: Text("Delete entry failed")));
        throw error;
      });
    },
  );
}
