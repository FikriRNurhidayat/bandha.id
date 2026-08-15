import 'package:bandha/core/presentation/formatters/numeric_formatter.dart';
import 'package:bandha/core/presentation/services/platform_keyboard.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/x_form_field.dart';
import 'package:flutter/material.dart';

class XAmountFormField extends XFormField<double> {
  final String labelText;
  final String hintText;
  final String label;

  XAmountFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.enabled,
    super.initialValue,
    super.autovalidateMode,
    super.textInputAction,
    super.onFieldSubmitted,
    super.readOnly,
    super.autofocus,
    required this.labelText,
    required this.hintText,
    this.label = 'Amount',
  }) : super(
         builder: (state) {
           final field = state as _AmountFormFieldState;

           return TextField(
             readOnly: field.widget.readOnly,
             autofocus: field.widget.autofocus,
             textInputAction: field.widget.textInputAction,
             onSubmitted: (v) {
               field.dismissAccessory();
               field.widget.onFieldSubmitted?.call();
             },
             focusNode: field.focusNode,
             controller: field._textEditingController,
             inputFormatters: [field._numericFormatter],
             keyboardType: const TextInputType.numberWithOptions(
               decimal: true,
               signed: false,
             ),
             decoration: XInputStyles.field(
               labelText: field.widget.labelText,
               hintText: field.widget.hintText,
             ).copyWith(errorText: field.errorText),
             onChanged: (val) {
               double? number = double.tryParse(val.replaceAll(',', ''))?.abs();
               field.didChange(number);
             },
           );
         },
       );

  @override
  FormFieldState<double> createState() => _AmountFormFieldState();
}

class _AmountFormFieldState extends XFormFieldState<double, XAmountFormField>
    with PlatformKeyboardObserver<FormField<double>> {
  @override
  XAmountFormField get widget => super.widget as XAmountFormField;

  final _numericFormatter = NumericFormatter(
    allowFraction: true,
    fractionDigits: 2,
    thousandSeparator: ',',
  );

  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      final amountText = widget.initialValue?.abs().toString() ?? '';

      _textEditingController.text = _numericFormatter.format(
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
  showAccessory() {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => Container(
        padding: EdgeInsets.all(16),
        child: TextField(
          readOnly: true,
          controller: _textEditingController,
          decoration: XInputStyles.field(
            labelText: widget.labelText,
            hintText: widget.hintText,
          ),
        ),
      ),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
