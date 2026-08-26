import 'package:bandha/core/presentation/formatters/numeric_formatter.dart';
import 'package:bandha/core/presentation/widgets/fields/number_field.dart';
import 'package:flutter/material.dart';

class NumberFormField extends FormField<double> {
  NumberFormField({
    super.key,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.onChanged,
    this.numericFormatter,
    super.onSaved,
    super.validator,
    super.initialValue,
    this.onFieldSubmitted,
  }) : super(
         builder: (FormFieldState<double> field) {
           final state = field as _NumberFormFieldState;

           void onChangedHandler(double? value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return NumberField(
             controller: state.controller,
             numericFormatter: state.numericFormatter,
             focusNode: focusNode,
             readOnly: readOnly,
             autofocus: autofocus,
             decoration: decoration.copyWith(errorText: field.errorText),
             textInputAction: textInputAction,
             onChanged: onChangedHandler,
             onSubmitted: onFieldSubmitted,
           );
         },
       );

  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;
  final InputDecoration decoration;
  final TextInputAction? textInputAction;
  final ValueChanged<double?>? onChanged;
  final ValueChanged<double?>? onFieldSubmitted;
  final NumericFormatter? numericFormatter;

  @override
  FormFieldState<double> createState() => _NumberFormFieldState();
}

class _NumberFormFieldState extends FormFieldState<double> {
  NumericFormatter? numericFormatter;
  FocusNode? focusNode;

  final TextEditingController controller = TextEditingController();

  @override
  NumberFormField get widget => super.widget as NumberFormField;

  late final effectiveNumericFormatter =
      widget.numericFormatter ??
      (numericFormatter ??= NumericFormatter(
        allowFraction: true,
        fractionDigits: 2,
        thousandSeparator: ',',
      ));

  @override
  initState() {
    super.initState();

    if (widget.initialValue != null) {
      final valueString = widget.initialValue!.abs().toString();
      controller.text = effectiveNumericFormatter.format(
        TextEditingValue.empty,
        TextEditingValue(
          text: valueString.endsWith(".0")
              ? valueString.substring(0, valueString.length - 2)
              : valueString,
        ),
      );
    }
  }

  @override
  dispose() {
    controller.dispose();
    focusNode?.dispose();
    super.dispose();
  }
}
