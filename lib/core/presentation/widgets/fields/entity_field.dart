import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_select_provider.dart';
import 'package:bandha/core/presentation/widgets/fields/select_field.dart';
import 'package:flutter/material.dart';

typedef EntityProviderResolver<T extends Entity> =
    AsyncSelectProvider<T> Function();

typedef EntitySelectOptionBuilder<T extends Entity> =
    SelectOption<T> Function(BuildContext context, Item<T> item);

typedef EntityActionsBuilder<T extends Entity> =
    Iterable<ActionChip> Function(BuildContext context, EntityFieldState state);

class EntityField<T extends Entity> extends StatefulWidget {
  const EntityField({
    super.key,
    this.focusNode,
    this.autofocus = false,
    this.multiple = false,
    this.readOnly = false,
    required this.resolveProvider,
    required this.optionBuilder,
    this.actionsBuilder,
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.controller,
    required this.collection,
    this.filter,
  });

  final String collection;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final bool multiple;
  final InputDecoration decoration;
  final TextInputAction? textInputAction;
  final ValueChanged<Iterable<T>>? onChanged;
  final ValueChanged<Iterable<T>>? onSubmitted;
  final EntityActionsBuilder? actionsBuilder;
  final EntityProviderResolver<T> resolveProvider;
  final EntitySelectOptionBuilder<T> optionBuilder;
  final SelectController<T>? controller;
  final DataFilter? filter;

  @override
  State<EntityField<T>> createState() => EntityFieldState<T>();
}

class EntityFieldState<T extends Entity> extends State<EntityField<T>> {
  SelectController<T>? controller;
  late final AsyncSelectProvider<T> provider = widget.resolveProvider();
  late final effectiveController =
      widget.controller ?? (controller ??= SelectController<T>());

  FocusNode? focusNode;
  late final effectiveFocusNode =
      widget.focusNode ?? (focusNode ??= FocusNode());

  bool wasFocus = false;

  @override
  initState() {
    debugPrint("EntityField/initState");
    effectiveController.isLoading = true;
    provider.query().then((_) {
      final options = provider.requireData.map(
        (i) => widget.optionBuilder(context, i),
      );
      effectiveController.updateAll(options);
      effectiveController.isLoading = false;
    });
    super.initState();
  }

  @override
  dispose() {
    controller?.dispose();
    provider.dispose();
    focusNode?.dispose();
    super.dispose();
  }

  void mustNotFocus() {
    if (effectiveFocusNode.hasFocus) {
      wasFocus = true;
      effectiveFocusNode.unfocus();
    }
  }

  void refocusIfNeeded() {
    if (wasFocus) {
      effectiveFocusNode.requestFocus();
      wasFocus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SelectField<T>(
      autofocus: widget.autofocus,
      controller: effectiveController,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      multiple: widget.multiple,
      decoration: widget.decoration,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      options: [],
      actions:
          widget.actionsBuilder?.call(context, this) ??
          [
            if (!widget.readOnly)
              ActionChip(
                avatar: Icon(
                  Icons.add_outlined,
                  color: theme.colorScheme.outline,
                ),
                label: Text(
                  "New ${T.toString().toLowerCase()}",
                  style: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: theme.colorScheme.outline,
                  ),
                ),
                onPressed: () async {
                  mustNotFocus();

                  final draft = await Navigator.of(
                    context,
                  ).pushNamed<Draft<T>>("/${widget.collection}/new");

                  if (draft != null) {
                    final item = Item<T>(draft.entity);
                    await provider.add(item);
                    await provider.replace(item);
                    final options = provider.requireData.map(
                      (i) => widget.optionBuilder(context, i),
                    );
                    effectiveController.updateAll(options);
                    effectiveController.replace(item.entity);
                    widget.onChanged?.call([draft.entity]);
                  }

                  refocusIfNeeded();
                },
              ),
          ],
      onSubmitted: widget.onSubmitted,
    );
  }
}
