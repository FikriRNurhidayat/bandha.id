import 'package:flutter/material.dart';

class MultiSelectItem<T> {
  final T value;
  final String label;
  final bool enabled;

  MultiSelectItem({
    required this.value,
    required this.label,
    this.enabled = true,
  });
}

class MultiSelectFormField<T> extends FormField<List<T>> {
  MultiSelectFormField({
    super.key,
    required List<MultiSelectItem<T>> options,
    super.initialValue,
    InputDecoration? decoration,
    List<Widget>? actions,
    super.autovalidateMode,
    super.enabled,
    super.onSaved,
    super.validator,
  }) : super(
         builder: (state) {
           List<Widget> chips = options.map((option) {
             final selected = state.value!.contains(option.value);
             return FilterChip(
                   label: Text(option.label),
                   selected: option.enabled ? selected : true,
                   onSelected: option.enabled
                       ? (bool value) {
                           final newValue = List<T>.from(state.value!);
                           if (value) {
                             newValue.add(option.value);
                           } else {
                             newValue.remove(option.value);
                           }
                           state.didChange(newValue);
                         }
                       : null,
                 )
                 as Widget;
           }).toList();

           if (actions != null) {
             chips.addAll(actions);
           }

           return InputDecorator(
             decoration:
                 decoration ??
                 InputDecoration(
                   errorText: state.errorText,
                   border: OutlineInputBorder(),
                   enabled: enabled,
                 ),
             child: Wrap(
               alignment: WrapAlignment.start,
               runAlignment: WrapAlignment.center,
               spacing: 8,
               runSpacing: 8,
               children: chips,
             ),
           );
         },
       );
}
