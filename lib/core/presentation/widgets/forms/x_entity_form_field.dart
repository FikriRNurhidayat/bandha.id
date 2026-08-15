import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_selector_provider.dart';
import 'package:bandha/core/presentation/widgets/forms/x_select_form_field.dart';
import 'package:flutter/material.dart';

typedef XEntityFormFieldProviderBuilder<E extends Entity> =
    AsyncSelectorProvider<E> Function();

typedef XEntityFormFieldActionBuilder<E extends Entity> =
    List<Widget> Function(BuildContext context, XEntityFormFieldState<E> state);

typedef XEntityFormFieldLabelBuilder<E extends Entity> =
    Widget Function(BuildContext context, Item<E> i);

class XEntityFormField<E extends Entity> extends XSelectFormField<Item<E>> {
  late final XEntityFormFieldProviderBuilder resolveProvider;
  final XEntityFormFieldActionBuilder<E>? actionsBuilder;
  final XEntityFormFieldLabelBuilder<E> labelBuilder;

  XEntityFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.enabled,
    super.initialValue,
    super.autovalidateMode,
    super.readOnly,
    super.autofocus,
    super.textInputAction,
    super.onFieldSubmitted,
    super.multi,
    String? hintText,
    required super.labelText,
    required this.resolveProvider,
    required this.labelBuilder,
    this.actionsBuilder,
  }) : super(hintText: hintText ?? "Select...", options: const []);

  @override
  FormFieldState<List<Item<E>>> createState() => XEntityFormFieldState<E>();
}

class XEntityFormFieldState<E extends Entity>
    extends XSelectFormFieldState<Item<E>> {
  @override
  XEntityFormField<E> get view => widget as XEntityFormField<E>;
  late final AsyncSelectorProvider<E> provider =
      view.resolveProvider() as AsyncSelectorProvider<E>;

  Item<E>? get selected => value?.isNotEmpty == true ? value!.first : null;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      provider.initialValue(widget.initialValue!.first);
    } else {
      provider.query();
    }
  }

  @override
  Widget formChipView(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: provider.notifier,
      builder: (context, snapshot, child) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final chips = <Widget>[];

        if (provider.hasData) {
          for (final option in provider.requireData) {
            chips.add(
              ExcludeFocus(
                child: ChoiceChip(
                  selected: option.isSelected,
                  label: view.labelBuilder(context, option),
                  onSelected: (v) async {
                    if (v) {
                      await provider.select(option);
                      didChange([option]);
                    } else {
                      await provider.deselect(option);
                      didChange(null);
                    }

                    focusNode.requestFocus();
                  },
                ),
              ),
            );
          }
        }

        if (view.actionsBuilder != null) {
          chips.addAll(
            view.actionsBuilder!
                .call(context, this)
                .map((chip) => ExcludeFocus(child: chip)),
          );
        }

        return Wrap(spacing: 8, children: chips);
      },
    );
  }

  @override
  Widget accessoryChipsView(
    BuildContext context, {
    bool withFilter = false,
    bool requestFocusOnSelected = false,
  }) {
    return ValueListenableBuilder(
      valueListenable: provider.notifier,
      builder: (context, snapshot, child) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final chips = <Widget>[];

        if (provider.hasData) {
          for (final option in provider.requireData) {
            chips.add(
              ExcludeFocus(
                child: ChoiceChip(
                  selected: option.isSelected,
                  label: view.labelBuilder(context, option),
                  onSelected: (v) async {
                    if (v) {
                      await provider.select(option);
                      didChange([option]);
                    } else {
                      await provider.deselect(option);
                      didChange(null);
                    }
                  },
                ),
              ),
            );
          }
        }

        if (view.actionsBuilder != null) {
          chips.addAll(view.actionsBuilder!.call(context, this));
        }

        return Row(spacing: 8, children: chips);
      },
    );
  }

  @override
  void dispose() {
    provider.dispose();
    super.dispose();
  }
}
