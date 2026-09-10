import 'package:flutter/widgets.dart';

class ToolMenu {
  bool isLoading = false;
  bool isEnabled = false;
  String title;
  String subtitle;
  Future<void> Function(BuildContext context) use;

  ToolMenu({required this.title, required this.subtitle, required this.use});
}
