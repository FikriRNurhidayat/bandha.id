import 'dart:io';

import 'package:banda/infra/db.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToolsView extends StatefulWidget {
  const ToolsView({super.key});

  @override
  State<ToolsView> createState() => _ToolsViewState();

  static String title = "Tools";
  static IconData icon = Icons.construction;
}

class _ToolsViewState extends State<ToolsView> {
  final timestampFormat = DateFormat("yyyy-MM-dd-HH-mm-ss");

  Future<void> _reset(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await DB.reset();
    messenger.showSnackBar(SnackBar(content: const Text("Ledger reset")));
    navigator.pop();
  }

  Future<void> _import(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["bandaio.db"],
    );
    if (pickResult == null) {
      return;
    }

    final dbSourceFile = File(pickResult.files.single.path!);
    final dbTargetPath = await DB.getPath();
    final dbTargetFile = File(dbTargetPath);

    await dbSourceFile.copy(dbTargetFile.path);
    messenger.showSnackBar(SnackBar(content: const Text("Ledger imported")));
    navigator.pop();
  }

  Future<void> _doReset(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text("Reset ledger"),
          content: Text(
            "This will replace existing data with the new ledger. This action is destructive, please make sure to export ledger first before doing this action.",
            style: theme.textTheme.bodySmall,
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
                _reset(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _doImport(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text("Import ledger"),
          content: Text(
            "This will replace existing data with the new ledger. This action is destructive, please make sure to export ledger first before doing this action.",
            style: theme.textTheme.bodySmall,
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
                _import(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _doExport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final now = timestampFormat.format(DateTime.now());
    final dbSourcePath = await DB.getPath();
    final dbSourceFile = File(dbSourcePath);
    final dbTargetDir = await FilePicker.platform.getDirectoryPath();

    if (dbTargetDir == null) {
      return;
    }

    final dbTargetFile = File('$dbTargetDir/$now.bandaio.db');
    await dbSourceFile.copy(dbTargetFile.path);

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(SnackBar(content: const Text("Ledger exported")));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<ListTile> tiles = [
      ListTile(
        title: Text("Export ledger", style: theme.textTheme.titleSmall),
        subtitle: Text(
          "Ledger will be exported as sqlite3 database.",
          style: theme.textTheme.bodySmall,
        ),
        onTap: () {
          _doExport(context);
        },
      ),
      ListTile(
        title: Text("Import ledger", style: theme.textTheme.titleSmall),
        subtitle: Text(
          "Use sqlite3 database as ledger.",
          style: theme.textTheme.bodySmall,
        ),
        onTap: () {
          _doImport(context);
        },
      ),
      ListTile(
        title: Text("Reset ledger", style: theme.textTheme.titleSmall),
        subtitle: Text(
          "Remove existing ledger.",
          style: theme.textTheme.bodySmall,
        ),
        onTap: () {
          _doReset(context);
        },
      ),
    ];

    return ListView.builder(
      itemCount: tiles.length,
      itemBuilder: (context, i) {
        final tile = tiles[i];
        return tile;
      },
    );
  }
}
