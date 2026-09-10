import 'package:flutter/services.dart';

class FilePicker {
  static final FilePicker instance = FilePicker();

  final channel = MethodChannel("id.bandha.app/plugins/file_picker");

  Future<String?> getFile({Iterable<String>? mimeTypes}) {
    return channel.invokeMethod<String>("pickFile", {
      "mimeTypes": mimeTypes ?? ["*/*"],
    });
  }

  Future<String?> saveFile({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) {
    return channel.invokeMethod<String>("saveFile", {
      "fileName": fileName,
      "filePath": filePath,
      "mimeType": mimeType,
    });
  }
}
