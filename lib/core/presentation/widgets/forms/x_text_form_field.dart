import 'package:bandha/core/presentation/services/platform_keyboard.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/x_form_field_accessory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class XTextFormField extends StatefulWidget {
  final bool readOnly;
  final String labelText;
  final String hintText;
  final String? initialValue;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const XTextFormField({
    super.key,
    this.readOnly = false,
    required this.labelText,
    required this.hintText,
    this.initialValue,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<XTextFormField> createState() => _XTextFormFieldState();
}

class _XTextFormFieldState extends State<XTextFormField>
    with PlatformKeyboardObserver {
  final _focusNode = FocusNode();
  PersistentBottomSheetController? _persistentBottomSheetController;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didChangeKeyboard() {
    if (!PlatformKeyboard.of(context).visible && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.readOnly,
      initialValue: widget.initialValue,
      onSaved: widget.onSaved,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      keyboardType: TextInputType.text,
      focusNode: _focusNode,
      decoration: XInputStyles.field(
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
    );
  }
}
