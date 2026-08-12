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
           final s = state as _AmountFormFieldState;
           return TextField(
             readOnly: s.view.readOnly,
             autofocus: s.view.autofocus,
             textInputAction: s.view.textInputAction,
             onSubmitted: (v) {
               s.dismissAccessory();
               s.view.onFieldSubmitted?.call();
             },
             focusNode: s.focusNode,
             controller: s._textEditingController,
             inputFormatters: [s._numericFormatter],
             keyboardType: const TextInputType.numberWithOptions(
               decimal: true,
               signed: false,
             ),
             decoration: XInputStyles.field(
               labelText: s.view.labelText,
               hintText: s.view.hintText,
             ).copyWith(errorText: s.errorText),
             onChanged: (val) {
               double? number = double.tryParse(val.replaceAll(',', ''))?.abs();
               s.didChange(number);
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
  XAmountFormField get view => widget as XAmountFormField;

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
            labelText: view.labelText,
            hintText: view.hintText,
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
