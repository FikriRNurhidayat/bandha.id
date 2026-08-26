import 'package:bandha/core/presentation/widgets/fields/date_time_field.dart';
import 'package:flutter/material.dart';

class DateTimeFormField extends FormField<DateTime> {
  DateTimeFormField({
    super.key,
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  }) : super(
         builder: (FormFieldState<DateTime> field) {
           void onChangedHandler(DateTime? value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return DateTimeField(
             decoration: decoration.copyWith(errorText: field.errorText),
             onChanged: onChangedHandler,
             readOnly: readOnly,
             initialDate: initialDate,
             firstDate: firstDate,
             lastDate: lastDate,
             textInputAction: textInputAction,
             onSubmitted: onFieldSubmitted,
           );
         },
       );

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool readOnly;
  final InputDecoration decoration;
  final TextInputAction? textInputAction;
  final ValueChanged<DateTime?>? onChanged;
  final ValueChanged<DateTime?>? onFieldSubmitted;
}
