import 'package:flutter/widgets.dart';

class ToolUiModel {
  bool isLoading = false;
  bool isEnabled = false;
  String title;
  String subtitle;
  void Function(BuildContext context) use;

  ToolUiModel({required this.title, required this.subtitle, required this.use});
}
