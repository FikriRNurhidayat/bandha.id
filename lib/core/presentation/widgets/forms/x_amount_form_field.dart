import 'package:bandha/core/presentation/formatters/numeric_formatter.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/x_form_field_accessory.dart';
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
              // focusNode: state.focusNode,
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
  // final focusNode = FocusNode();
  PersistentBottomSheetController? sheetController;

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

    // focusNode.addListener(focusListener);
  }

  // void focusListener() {
  //   if (!mounted) return;

  //   if (focusNode.hasFocus) {
  //     sheetController = Scaffold.of(context).showBottomSheet(
  //       (context) => XFormFieldAccessory(focusNode: focusNode),
  //       constraints: const BoxConstraints(maxWidth: double.infinity),
  //       shape: const RoundedRectangleBorder(),
  //       sheetAnimationStyle: AnimationStyle.noAnimation,
  //     );
  //   } else {
  //     sheetController?.close();
  //     sheetController = null;
  //   }
  // }

  @override
  void dispose() {
    // focusNode.removeListener(focusListener);
    // focusNode.dispose();
    controller.dispose();
    super.dispose();
  }
}
