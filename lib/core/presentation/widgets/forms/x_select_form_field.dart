import 'package:bandha/core/presentation/services/platform_keyboard.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/x_form_field.dart';
import 'package:flutter/material.dart';

class XSelectItem<T> {
  final T value;
  final String label;
  final WidgetStateProperty<Color?>? color;
  final Color? backgroundColor;

  bool isSelected(T value) {
    return this.value == value;
  }

  XSelectItem({
    required this.value,
    required this.label,
    this.backgroundColor,
    this.color,
  });
}

typedef XSelectFormFieldActionsBuilder<T> =
    List<Widget> Function(BuildContext context);

class XSelectFormField<T> extends XFormField<List<T>> {
  final String labelText;
  final String hintText;
  final List<XSelectItem<T>> options;
  final bool multi;

  XSelectFormField({
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
    required this.options,
    this.multi = false,
  }) : super(
         builder: (state) {
           state as XSelectFormFieldState<T>;
           return Builder(
             builder: (context) {
               final selectField = state.widget as XSelectFormField<T>;
               final selected = state.value ?? <T>[];
               final selectedItems = selected
                   .map((v) => options.firstWhere((o) => o.value == v))
                   .toList();

               if (selectField.readOnly && selectedItems.isEmpty) {
                 return InputDecorator(
                   decoration: XInputStyles.field(
                     hintText: selectField.hintText,
                     labelText: selectField.labelText,
                   ),
                   child: const SizedBox.shrink(),
                 );
               }

               return Column(
                 children: [
                   Opacity(
                     opacity: 0.0,
                     child: SizedBox(
                       height: 0,
                       width: 0,
                       child: TextField(
                         focusNode: state.focusNode,
                         controller: state.filter,
                         textInputAction: textInputAction,
                       ),
                     ),
                   ),
                   InputDecorator(
                     decoration: XInputStyles.field(
                       hintText: selectField.hintText,
                       labelText: selectField.labelText,
                     ),
                     child: state.formChipView(context),
                   ),
                 ],
               );
             },
           );
         },
       );

  @override
  FormFieldState<List<T>> createState() => XSelectFormFieldState<T>();
}

class XSelectFormFieldState<T>
    extends XFormFieldState<List<T>, XSelectFormField<T>>
    with PlatformKeyboardObserver<FormField<List<T>>> {
  final filter = TextEditingController();

  @override
  XSelectFormField<T> get view => widget as XSelectFormField<T>;

  bool get auto {
    final action = view.textInputAction;
    if (action != null) return action == TextInputAction.next;
    if (view.onFieldSubmitted != null) return false;
    return true;
  }

  Widget formChipView(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chipsBuilder(
        context,
        withFilter: false,
        requestFocusOnSelected: true,
      ),
    );
  }

  @override
  void showAccessory() {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => Container(
        padding: EdgeInsets.all(16),
        child: InputDecorator(
          decoration: XInputStyles.field(
            hintText: view.hintText,
            labelText: view.labelText,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: accessoryChipsView(context),
          ),
        ),
      ),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(),
      sheetAnimationStyle: AnimationStyle.noAnimation,
    );
  }

  List<Widget> chipsBuilder(
    BuildContext context, {
    bool withFilter = false,
    bool requestFocusOnSelected = false,
  }) {
    return view.options
        .where(
          (option) =>
              !withFilter || option.label.toLowerCase().startsWith(filter.text),
        )
        .map(
          (option) => ExcludeFocus(
            child: ChoiceChip(
              color: option.color,
              backgroundColor: option.backgroundColor,
              selected: value?.contains(option.value) ?? false,
              onSelected: (v) {
                if (v) {
                  selectItem(option);
                } else {
                  deselectItem(option);
                }

                if (requestFocusOnSelected) focusNode.requestFocus();
              },
              label: Text(option.label),
            ),
          ),
        )
        .toList();
  }

  Widget accessoryChipsView(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: filter,
      builder: (context, value, child) {
        return Row(
          spacing: 8,
          children: chipsBuilder(
            context,
            withFilter: true,
            requestFocusOnSelected: false,
          ),
        );
      }
    );
  }

  void selectItem(XSelectItem<T> option) {
    final values = List<T>.from(value ?? <T>[]);
    if (view.multi) {
      if (!values.contains(option.value)) {
        values.add(option.value);
      }
      didChange(values);
    } else {
      didChange([option.value]);
    }

    if (!view.multi && auto) {
      focusNode.nextFocus();
    }

    filter.clear();
  }

  void deselectItem(XSelectItem<T> option) {
    final values = List<T>.from(value ?? <T>[]);
    values.remove(option.value);
    didChange(values.isEmpty ? <T>[] : values);
  }

  @override
  dispose() {
    filter.dispose();
    super.dispose();
  }
}
