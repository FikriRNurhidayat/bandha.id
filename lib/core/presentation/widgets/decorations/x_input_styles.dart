import 'package:flutter/material.dart';

class XInputStyles {
  static InputDecoration field({
    String? hintText,
    String? labelText,
    String? helperText,
    Widget? label,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      labelText: labelText,
      label: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }
}
