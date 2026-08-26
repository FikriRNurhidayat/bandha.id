import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/services/input_accessory.dart';
import 'package:bandha/core/presentation/services/platform_keyboard.dart';
import 'package:flutter/material.dart';

class SelectField<T> extends StatefulWidget {
  const SelectField({
    super.key,
    required this.options,
    this.autofocus = false,
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.onChanged,
    this.multiple = false,
    this.focusNode,
    this.controller,
    this.actions,
    this.onSubmitted,
  });

  final SelectController<T>? controller;
  final FocusNode? focusNode;
  final Iterable<SelectOption<T>> options;
  final bool autofocus;
  final bool readOnly;
  final bool multiple;
  final InputDecoration decoration;
  final TextInputAction? textInputAction;
  final ValueChanged<Iterable<T>>? onChanged;
  final Iterable<ActionChip>? actions;
  final ValueChanged<Iterable<T>>? onSubmitted;

  @override
  State<SelectField<T>> createState() => SelectFieldState<T>();
}

class SelectFieldState<T> extends State<SelectField<T>>
    with PlatformKeyboardObserver, InputAccessory {
  @override
  late final effectiveFocusNode =
      widget.focusNode ?? FocusNode(debugLabel: widget.decoration.labelText);
  late final effectiveController =
      widget.controller ??
      SelectController<T>(
        availableValues: widget.options.map((option) => option.value),
        selectOptions: widget.options,
      );

  final TextEditingController filter = TextEditingController();
  Iterable<SelectOption<T>> get selected => effectiveController.selectOptions
      .where((option) => effectiveController.value.contains(option.value));

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly) {
      return ListenableBuilder(
        listenable: effectiveController,
        builder: (context, state) => InputDecorator(
          isEmpty: effectiveController.value.isEmpty,
          decoration: widget.decoration,
          child: widget.multiple
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: effectiveController.selected
                        .map((option) => Chip(label: Text(option.text)))
                        .toList(),
                  ),
                )
              : effectiveController.selected.isNotEmpty
              ? Text(effectiveController.selected.first.text)
              : null,
        ),
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
              focusNode: effectiveFocusNode,
              controller: filter,
              textInputAction: widget.textInputAction,
              onSubmitted: (v) {
                if (effectiveController.value.isNotEmpty) {
                  dismissAccessory();
                  widget.onSubmitted?.call(effectiveController.value);
                }
              },
            ),
          ),
        ),
        ListenableBuilder(
          listenable: effectiveController,
          builder: (context, state) {
            return InputDecorator(
              isEmpty:
                  effectiveController.isLoading ||
                  (effectiveController.selectOptions.isEmpty &&
                      widget.actions != null &&
                      widget.actions!.isEmpty),
              isFocused:
                  !effectiveController.isLoading && effectiveFocusNode.hasFocus,
              decoration: widget.decoration.copyWith(
                hintText: !effectiveController.isLoading
                    ? widget.decoration.hintText
                    : "Loading...",
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ValueListenableBuilder(
                  valueListenable: filter,
                  builder: (context, value, child) {
                    return Row(
                      spacing: 8,
                      children: effectiveController.selectOptions
                          .map(
                            (option) => ExcludeFocus(
                              child: ChoiceChip(
                                onSelected: (v) {
                                  _handleSelect(v, option);
                                  effectiveFocusNode.requestFocus();
                                },
                                label: Text(option.text),
                                selected: effectiveController.value.contains(
                                  option.value,
                                ),
                              ),
                            ),
                          )
                          .followedBy([
                            if (!effectiveController.isLoading)
                              ...?widget.actions?.map(
                                (action) => ExcludeFocus(child: action),
                              ),
                          ])
                          .toList(),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleSelect(bool isSelected, SelectOption<T> option) {
    if (isSelected) {
      if (widget.multiple) {
        effectiveController.select(option.value);
      } else {
        effectiveController.override({option.value});
      }

      widget.onChanged?.call(effectiveController.value);
    }
  }

  Widget _chipLabelBuilder(BuildContext context, SelectOption option) {
    if (filter.text.isEmpty) return Text(option.text);
    final filtered = option.text.substring(0, filter.text.length);
    final rest = option.text.substring(filter.text.length);
    if (rest.isEmpty) return Text(filtered);
    return Text.rich(
      TextSpan(
        text: filtered,
        children: [TextSpan(text: rest)],
      ),
    );
  }

  @override
  WidgetBuilder? get accessoryBuilder =>
      (context) => Container(
        padding: EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: effectiveController,
          builder: (context, state) => ValueListenableBuilder(
            valueListenable: filter,
            builder: (context, value, child) => InputDecorator(
              isEmpty: false,
              isFocused: effectiveFocusNode.hasFocus,
              decoration: widget.decoration.copyWith(
                helperText: filter.text.isEmpty ? null : filter.text,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ValueListenableBuilder(
                  valueListenable: filter,
                  builder: (context, value, child) {
                    return Row(
                      spacing: 8,
                      children: effectiveController.selectOptions
                          .where(
                            (option) => option.text.toLowerCase().startsWith(
                              filter.text.toLowerCase(),
                            ),
                          )
                          .map(
                            (option) => ExcludeFocus(
                              child: ChoiceChip(
                                onSelected: (v) => _handleSelect(v, option),
                                label: _chipLabelBuilder(context, option),
                                selected: effectiveController.value.contains(
                                  option.value,
                                ),
                              ),
                            ),
                          )
                          .followedBy([
                            ...?widget.actions?.map(
                              (action) => ExcludeFocus(child: action),
                            ),
                          ])
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
}
