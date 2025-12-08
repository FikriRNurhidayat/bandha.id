import 'dart:io';

import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/infra/db.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  Future<void> import(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
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
    messenger.showSnackBar(SnackBar(content: const Text("Ledger imported")));
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

  Future<void> doImport(BuildContext context) async {
    ask(
      context,
      title: "Import ledger",
      content:
          "This will replace existing data with the new ledger. This action is destructive, please make sure to export ledger first before doing this action.",
      onConfirm: (BuildContext context) async {
        import(context);
      },
    );
  }

  Future<void> doExport(BuildContext context) async {
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
        "title": "Export ledger",
        "subtitle": "Ledger will be exported as sqlite3 database.",
        "onTap": () {
          doExport(context);
        },
      },
      {
        "title": "Import ledger",
        "subtitle": "Use sqlite3 database as ledger.",
        "onTap": () {
          doImport(context);
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
