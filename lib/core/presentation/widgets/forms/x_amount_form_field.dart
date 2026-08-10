import 'package:bandha/core/presentation/formatters/numeric_formatter.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:flutter/material.dart';

class XAmountFormField extends FormField<double> {
  XAmountFormField({
    super.key,
    required String labelText,
    required String hintText,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    this.label = 'Amount',
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction,
    this.onFieldSubmitted,
  }) : super(
         builder: (field) {
           final state = field as _AmountFormFieldState;

           return TextField(
             readOnly: readOnly,
             autofocus: autofocus,
             textInputAction: textInputAction,
             onSubmitted: onFieldSubmitted,
             controller: state.controller,
             inputFormatters: [state.numericFormatter],
             keyboardType: const TextInputType.numberWithOptions(
               decimal: true,
               signed: false,
             ),
             decoration: XInputStyles.field(
               labelText: labelText,
               hintText: hintText,
             ),
             onChanged: (val) {
               double? number = double.tryParse(val.replaceAll(',', ''))?.abs();
               state.didChange(number);
             },
           );
         },
       );

  final String label;
  final bool readOnly;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  FormFieldState<double> createState() {
    return _AmountFormFieldState();
  }
}

class _AmountFormFieldState extends FormFieldState<double> {
  final numericFormatter = NumericFormatter(
    allowFraction: true,
    fractionDigits: 2,
    thousandSeparator: ',',
  );

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      final amountText = widget.initialValue?.abs().toString() ?? '';

      controller.text = numericFormatter.format(
        TextEditingValue.empty,
        TextEditingValue(
          text: amountText.endsWith(".0")
              ? amountText.substring(0, amountText.length - 2)
              : amountText,
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
