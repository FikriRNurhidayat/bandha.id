import 'dart:io';

import 'package:banda/infra/store.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToolScreen extends StatefulWidget {
  const ToolScreen({super.key});

  @override
  State<ToolScreen> createState() => _ToolScreenState();

  static String title = "Tools";
  static IconData icon = Icons.construction;
}

class _ToolScreenState extends State<ToolScreen> {
  final timestampFormat = DateFormat("yyyy-MM-dd-HH-mm-ss");

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
    final dbTargetPath = await Store.getPath();
    final dbTargetFile = File(dbTargetPath);

    await dbSourceFile.copy(dbTargetFile.path);
    messenger.showSnackBar(SnackBar(content: const Text("Ledger imported")));
    navigator.pop();
  }

  Future<void> _doImport(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Import ledger"),
          content: const Text(
            "Are you sure you want to import ledger? This will replace existing data with the new ledger. This action is destructive, please make sure to export ledger first before doing this action.",
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
    final dbSourcePath = await Store.getPath();
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
    final List<ListTile> tiles = [
      ListTile(
        title: Text("Export ledger"),
        subtitle: Text("Ledger will be exported as sqlite3 database."),
        onTap: () {
          _doExport(context);
        },
      ),
      ListTile(
        title: Text("Import ledger"),
        subtitle: Text("Use sqlite3 database as ledger."),
        onTap: () {
          _doImport(context);
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
