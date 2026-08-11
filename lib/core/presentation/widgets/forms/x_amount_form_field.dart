import 'package:bandha/core/presentation/formatters/numeric_formatter.dart';
import 'package:bandha/core/presentation/services/platform_keyboard.dart';
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
             focusNode: state._focusNode,
             controller: state._textEditingController,
             inputFormatters: [state._numericFormatter],
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

class _AmountFormFieldState extends FormFieldState<double>
    with PlatformKeyboardObserver {
  final _numericFormatter = NumericFormatter(
    allowFraction: true,
    fractionDigits: 2,
    thousandSeparator: ',',
  );

  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  PersistentBottomSheetController? _persistentBottomSheetController;

  @override
  void didChangeKeyboard() {
    if (!PlatformKeyboard.of(context).visible && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

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

    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;

    if (_focusNode.hasFocus) {
      _persistentBottomSheetController = Scaffold.of(context).showBottomSheet(
        (context) => XFormFieldAccessory(focusNode: _focusNode),
        constraints: const BoxConstraints(maxWidth: double.infinity),
        shape: const RoundedRectangleBorder(),
        sheetAnimationStyle: AnimationStyle.noAnimation,
      );
    } else {
      _persistentBottomSheetController?.close();
      _persistentBottomSheetController = null;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}
