import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/types/widget_list_builder.dart';
import 'package:flutter/material.dart';

class XSelectItem<T> {
  final T value;
  final String label;
  final String? sublabel;
  final WidgetStateProperty<Color?>? color;
  final Color? backgroundColor;

  XSelectItem({
    required this.value,
    required this.label,
    this.sublabel,
    this.backgroundColor,
    this.color,
  });
}

class XSelectFormField<T> extends FormField<T> {
  final String labelText;
  final String hintText;
  final List<XSelectItem<T>> options;

  XSelectFormField({
    FormFieldSetter<T>? onChanged,
    List<Widget>? actions,
    WidgetListBuilder? actionsBuilder,
    bool readOnly = false,
    required this.hintText,
    required this.labelText,
    required this.options,
    super.autovalidateMode,
    super.enabled,
    super.initialValue,
    super.key,
    super.onSaved,
    super.validator,
  }) : super(
         builder: (state) {
           return Builder(
             builder: (context) {
               List<Widget> chips = !readOnly
                   ? options.map((option) {
                       final selected = state.value == option.value;
                       final hasSub = option.sublabel != null;

                       return ChoiceChip(
                             color: option.color,
                             backgroundColor: option.backgroundColor,
                             label: hasSub
                                 ? Row(
                                     mainAxisSize: MainAxisSize.min,
                                     spacing: 8,
                                     children: [
                                       Text(option.label),
                                       Text(option.sublabel!),
                                     ],
                                   )
                                 : Text(option.label),
                             selected: selected,
                             onSelected: (!readOnly && enabled)
                                 ? (_) {
                                     state.didChange(option.value);
                                     onChanged?.call(option.value);
                                   }
                                 : null,
                           )
                           as Widget;
                     }).toList()
                   : options.where((option) => state.value == option.value).map(
                       (option) {
                         return Text(option.label) as Widget;
                       },
                     ).toList();

               if (actions != null) {
                 chips.addAll(actions);
               }

               if (actionsBuilder != null) {
                 final actions = actionsBuilder(state.context);
                 chips.addAll(actions);
               }

               return InputDecorator(
                 decoration: XInputStyles.field(
                   hintText: hintText,
                   labelText: labelText,
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
         },
       );
}
