import 'package:bandha/core/presentation/services/platform_keyboard.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/x_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class XTextFormField extends XFormField<String> {
  final String labelText;
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  XTextFormField({
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
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  }) : super(
         builder: (state) {
           final s = state as _XTextFormFieldState;
           return TextField(
             readOnly: s.view.readOnly,
             controller: s.textEditingController,
             autofocus: s.view.autofocus,
             textInputAction: s.view.textInputAction,
             onSubmitted: (v) {
               s.dismissAccessory();
               s.view.onSubmitted?.call(v);
             },
             inputFormatters: s.view.inputFormatters,
             textCapitalization: s.view.textCapitalization,
             keyboardType: TextInputType.text,
             focusNode: s.focusNode,
             onChanged: (val) => s.didChange(val),
             decoration: XInputStyles.field(
               labelText: s.view.labelText,
               hintText: s.view.hintText,
             ).copyWith(errorText: s.errorText),
           );
         },
       );

  @override
  FormFieldState<String> createState() => _XTextFormFieldState();
}

class _XTextFormFieldState extends XFormFieldState<String, XTextFormField>
    with PlatformKeyboardObserver<FormField<String>> {
  @override
  XTextFormField get view => widget as XTextFormField;
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      textEditingController.text = widget.initialValue!;
    }
  }

  @override
  void showAccessory() {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => Container(
        padding: EdgeInsets.all(16),
        child: TextField(
          readOnly: true,
          controller: textEditingController,
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
    textEditingController.dispose();
    super.dispose();
  }
}
