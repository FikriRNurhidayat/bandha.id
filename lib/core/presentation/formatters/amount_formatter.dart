import 'package:flutter/services.dart';

class AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    String formatted = _addCommas(digits);

    // Avoid unnecessary rebuilds
    if (formatted == newValue.text) return newValue;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String digits) {
    final buffer = StringBuffer();
    int len = digits.length;
    for (int i = 0; i < len; i++) {
      buffer.write(digits[i]);
      int posFromEnd = len - i - 1;
      if (posFromEnd % 3 == 0 && i != len - 1) buffer.write(',');
    }
    return buffer.toString();
  }
}
