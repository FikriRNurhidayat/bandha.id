import 'package:banda/decorations/input_styles.dart';
import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  final String labelText;
  final Alignment labelAlignment;
  final TextAlign valueAlignment;
  final String valueText;

  const Field({
    super.key,
    required this.labelText,
    required this.valueText,
    this.labelAlignment = Alignment.centerLeft,
    this.valueAlignment = TextAlign.start,
  });

  factory Field.start({required String labelText, required valueText}) {
    return Field(
      labelText: labelText,
      labelAlignment: Alignment.centerLeft,
      valueText: valueText,
      valueAlignment: TextAlign.start,
    );
  }

  factory Field.center({required String labelText, required valueText}) {
    return Field(
      labelText: labelText,
      labelAlignment: Alignment.center,
      valueText: valueText,
      valueAlignment: TextAlign.center,
    );
  }

  factory Field.end({required String labelText, required valueText}) {
    return Field(
      labelText: labelText,
      labelAlignment: Alignment.centerRight,
      valueText: valueText,
      valueAlignment: TextAlign.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputStyles.field(
        label: Align(alignment: labelAlignment, child: Text(labelText)),
      ),
      child: Text(valueText, textAlign: valueAlignment),
    );
  }
}
