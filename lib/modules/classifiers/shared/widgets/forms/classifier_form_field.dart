import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/shared/widgets/fields/classifier_field.dart';
import 'package:flutter/material.dart';

class ClassifierFormField<T extends Classifier<T>>
    extends FormField<Iterable<T>> {
  ClassifierFormField({
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
         builder: (FormFieldState<Iterable<T>> field) {
           final state = field as _ClassifierFormFieldState<T>;

           void onChangedHandler(Iterable<T>? value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return Builder(
             builder: (context) => ClassifierField<T>.builder(
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
  final ValueChanged<Iterable<T>?>? onChanged;
  final ValueChanged<Iterable<T>?>? onFieldSubmitted;

  @override
  FormFieldState<Iterable<T>> createState() => _ClassifierFormFieldState<T>();
}

class _ClassifierFormFieldState<T extends Classifier<T>>
    extends FormFieldState<Iterable<T>> {
  late final controller = SelectController<T>(value: {...?widget.initialValue});

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
}
