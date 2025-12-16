import 'dart:io';

import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/infra/db.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToolsView extends StatefulWidget {
  const ToolsView({super.key});

  @override
  State<ToolsView> createState() => _ToolsViewState();
}

class _ToolsViewState extends State<ToolsView> {
  final timestampFormat = DateFormat("yyyy-MM-dd-HH-mm-ss");

  Future<void> reset(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await DB.reset();
    messenger.showSnackBar(SnackBar(content: const Text("Ledger reset")));
  }

  Future<void> restore(BuildContext context) async {
    final navigator = Navigator.of(context);
    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["bandha.db"],
    );
    if (pickResult == null) {
      return;
    }

    final dbSourceFile = File(pickResult.files.single.path!);
    final dbTargetPath = await DB.getPath();
    final dbTargetFile = File(dbTargetPath);

    await dbSourceFile.copy(dbTargetFile.path);

    await navigateFlash(
      navigator,
      title: "Restart Required",
      content:
          "Because the entire ledger has been replaced, this application requires hard restart.",
      onTap: (context) async {
        exit(0);
      },
    );
  }

  Future<void> doReset(BuildContext context) async {
    ask(
      context,
      title: "Reset ledger",
      content:
          "This will replace existing data with the new ledger. This action is destructive, please make sure to export ledger first before doing this action.",
      onConfirm: (BuildContext context) async {
        reset(context);
      },
    );
  }

  Future<void> doRestore(BuildContext context) async {
    ask(
      context,
      title: "Restore ledger",
      content:
          "This will replace existing data with the new ledger. This action is destructive, please make sure to export ledger first before doing this action.",
      onConfirm: (BuildContext context) async {
        restore(context);
      },
    );
  }

  Future<void> doBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final now = timestampFormat.format(DateTime.now());
    final dbSourcePath = await DB.getPath();
    final dbSourceFile = File(dbSourcePath);
    final dbTargetDir = await FilePicker.platform.getDirectoryPath();

    if (dbTargetDir == null) {
      return;
    }

    final dbTargetFile = File('$dbTargetDir/$now.bandha.db');
    await dbSourceFile.copy(dbTargetFile.path);

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(SnackBar(content: const Text("Ledger exported")));
  }

  List<Map<String, dynamic>> menuBuilder(BuildContext context) {
    return [
      {
        "title": "Backup ledger",
        "subtitle": "Ledger will be backed-up as sqlite3 database.",
        "onTap": () {
          doBackup(context);
        },
      },
      {
        "title": "Restore ledger",
        "subtitle": "Restore sqlite3 database as ledger.",
        "onTap": () {
          doRestore(context);
        },
      },
      if (kDebugMode) ...[
        {
          "title": "Reset ledger",
          "subtitle": "Remove existing ledger.",
          "onTap": () {
            doReset(context);
          },
        },
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menus = menuBuilder(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tools",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (context, i) {
          final menu = menus[i];
          return ListTile(
            title: Text(menu["title"], style: theme.textTheme.titleSmall),
            subtitle: Text(menu["subtitle"], style: theme.textTheme.bodySmall),
            onTap: menu["onTap"],
          );
        },
      ),
    );
  }
}
