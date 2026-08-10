import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:flutter/material.dart';

class XTextFormField extends TextFormField {
  XTextFormField({
    super.key,
    super.readOnly,
    required String labelText,
    required String hintText,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.inputFormatters,
    super.textCapitalization,
    super.autofocus,
    super.textInputAction,
    super.onFieldSubmitted,
  }) : super(
         keyboardType: TextInputType.text,
         decoration: XInputStyles.field(
           labelText: labelText,
           hintText: hintText,
         ),
       );
}
