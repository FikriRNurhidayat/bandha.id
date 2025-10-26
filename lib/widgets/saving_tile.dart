import 'package:banda/entity/saving.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/views/edit_saving_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingTile extends StatelessWidget {
  final Saving saving;

  const SavingTile(this.saving, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        final navigator = Navigator.of(context);
        context.read<SavingProvider>().get(saving.id).then((entry) {
          navigator.push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => EditSavingScreen(saving: saving),
            ),
          );
        });
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Please Confirm"),
              content: const Text(
                "Are you sure you want to remove this saving?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    final savingProvider = context.read<SavingProvider>();

                    savingProvider.remove(saving.id);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      title: Text(saving.note),
    );
  }
}
