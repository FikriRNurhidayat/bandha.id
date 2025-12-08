import 'dart:io';

void main() {
  final dir = Directory('assets/sql');
  final files =
      dir
          .listSync()
          .whereType<File>()
          .map((f) => f.path.replaceAll(r'\', '/'))
          .toList()
        ..sort();

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED FILE - DO NOT EDIT');
  buffer.writeln('const dbMigrationFiles = <String>[');
  for (final f in files) {
    buffer.writeln("  '$f',");
  }
  buffer.writeln('];');

  File(
    'lib/infra/db_migration_files.dart',
  ).writeAsStringSync(buffer.toString());
}
