import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/shared/widgets/fields/journal_field.dart';
import 'package:flutter/material.dart';

class JournalFormField extends FormField<Iterable<Journal>> {
  JournalFormField({
    super.key,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.multiple = false,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.onChanged,
    super.onSaved,
    super.validator,
    super.initialValue,
    this.onFieldSubmitted,
  }) : super(
         builder: (FormFieldState<Iterable<Journal>> field) {
           final state = field as _JournalFormFieldState;

           void onChangedHandler(Iterable<Journal>? value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return Builder(
             builder: (context) => JournalField.builder(
               context,
               controller: state.controller,
               autofocus: autofocus,
               readOnly: readOnly,
               multiple: multiple,
               onChanged: onChangedHandler,
               decoration: decoration.copyWith(errorText: field.errorText),
               textInputAction: textInputAction,
               onSubmitted: (v) {
                 if (v.isNotEmpty) {
                   onFieldSubmitted?.call(v);
                 }
               },
             ),
           );
         },
       );

  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;
  final bool multiple;
  final InputDecoration decoration;
  final TextInputAction? textInputAction;
  final ValueChanged<Iterable<Journal>?>? onChanged;
  final ValueChanged<Iterable<Journal>?>? onFieldSubmitted;

  @override
  FormFieldState<Iterable<Journal>> createState() => _JournalFormFieldState();
}

class _JournalFormFieldState extends FormFieldState<Iterable<Journal>> {
  late final controller = SelectController<Journal>(
    value: {...?widget.initialValue},
  );

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
}
