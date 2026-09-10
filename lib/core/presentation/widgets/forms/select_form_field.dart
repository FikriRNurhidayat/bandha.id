import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/widgets/fields/select_field.dart';
import 'package:flutter/material.dart';

class SelectFormField<T> extends FormField<Iterable<T>> {
  SelectFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.autofocus = false,
    this.decoration = const InputDecoration(),
    this.focusNode,
    this.multiple = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.textInputAction,
    this.options = const [],
  }) : super(
         builder: (field) {
           final state = field as SelectFormFieldState<T>;

           void onChangedHandler(Iterable<T>? value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return SelectField<T>(
             controller: state.controller,
             autofocus: autofocus,
             readOnly: readOnly,
             focusNode: focusNode,
             multiple: multiple,
             decoration: decoration,
             onChanged: onChangedHandler,
             textInputAction: textInputAction,
             options: options,
             onSubmitted: onFieldSubmitted,
           );
         },
       );

  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;
  final bool multiple;
  final InputDecoration decoration;
  final TextInputAction? textInputAction;
  final ValueChanged<Iterable<T>?>? onChanged;
  final ValueChanged<Iterable<T>?>? onFieldSubmitted;
  final Iterable<SelectOption<T>> options;

  @override
  FormFieldState<Iterable<T>> createState() => SelectFormFieldState<T>();
}

class SelectFormFieldState<T> extends FormFieldState<Iterable<T>> {
  @override
  SelectFormField<T> get widget => super.widget as SelectFormField<T>;

  late final controller = SelectController<T>(
    value: {...?widget.initialValue},
    availableValues: widget.options.map((o) => o.value),
    selectOptions: widget.options,
  );

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
}
