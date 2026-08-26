import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/shared/widgets/fields/asset_field.dart';
import 'package:flutter/material.dart';

class AssetFormField extends FormField<Iterable<Asset>> {
  AssetFormField({
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
         builder: (FormFieldState<Iterable<Asset>> field) {
           final state = field as _AssetFormFieldState;

           void onChangedHandler(Iterable<Asset>? value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return Builder(
             builder: (context) => AssetField.builder(
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
  final ValueChanged<Iterable<Asset>?>? onChanged;
  final ValueChanged<Iterable<Asset>?>? onFieldSubmitted;

  @override
  FormFieldState<Iterable<Asset>> createState() => _AssetFormFieldState();
}

class _AssetFormFieldState extends FormFieldState<Iterable<Asset>> {
  late final controller = SelectController<Asset>(
    value: {...?widget.initialValue},
  );

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
}
