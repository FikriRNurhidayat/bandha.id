import 'package:flutter/widgets.dart';

class ToolUiModel {
  bool isLoading = false;
  bool isEnabled = false;
  String title;
  String subtitle;
  VoidCallback use;

  ToolUiModel({
    required this.title,
    required this.subtitle,
    required this.use,
  });
}
