import 'package:bandha/core/presentation/controllers/date_time_controller.dart';
import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/widgets/fields/timestamp_field.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:flutter/material.dart';

class TimestampFormField extends FormField<Timestamp> {
  TimestampFormField({
    super.key,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.decoration = const InputDecoration(),
    this.dateTimeDecoration = const InputDecoration(),
    super.onSaved,
    super.validator,
    super.initialValue,
    this.readOnly = false,
  }) : super(
         builder: (FormFieldState<Timestamp> field) {
           final state = field as _TimestampFormFieldState;
           void onChangedHandler(Timestamp? value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return TimestampField(
             readOnly: readOnly,
             selectController: state.selectController,
             dateTimeController: state.dateTimeController,
             textInputAction: textInputAction,
             decoration: decoration.copyWith(errorText: field.errorText),
             dateTimeDecoration: dateTimeDecoration,
             onChanged: onChangedHandler,
             onSubmitted: onFieldSubmitted,
           );
         },
       );

  final ValueChanged<Timestamp?>? onChanged;
  final ValueChanged<Timestamp?>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final InputDecoration decoration;
  final InputDecoration dateTimeDecoration;
  final bool readOnly;

  @override
  FormFieldState<Timestamp> createState() => _TimestampFormFieldState();
}

class _TimestampFormFieldState extends FormFieldState<Timestamp> {
  late final selectController = SelectController(
    value: widget.initialValue != null ? {widget.initialValue!.option} : null,
    availableValues: TimestampOption.values,
    selectOptions: TimestampOption.values.map(
      (option) => SelectOption(text: option.toString(), value: option),
    ),
  );

  late final dateTimeController = DateTimeController(
    widget.initialValue?.dateTime,
  );

  @override
  dispose() {
    selectController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }
}
