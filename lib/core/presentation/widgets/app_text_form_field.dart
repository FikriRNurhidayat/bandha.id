import 'package:bandha/core/presentation/widgets/decorations/app_input_styles.dart';
import 'package:flutter/material.dart';

class AppTextFormField extends TextFormField {
  AppTextFormField({
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
         decoration: AppInputStyles.field(
           labelText: labelText,
           hintText: hintText,
         ),
       );
}
