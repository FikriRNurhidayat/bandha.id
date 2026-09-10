import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_select_provider.dart';
import 'package:bandha/core/presentation/widgets/fields/entity_field.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:flutter/material.dart';

class ClassifierField<T extends Classifier<T>> extends EntityField<T> {
  const ClassifierField({
    super.key,
    super.focusNode,
    super.autofocus = false,
    super.multiple = false,
    super.readOnly = false,
    required super.resolveProvider,
    required super.optionBuilder,
    super.actionsBuilder,
    super.decoration = const InputDecoration(),
    super.onChanged,
    super.textInputAction,
    super.onSubmitted,
    super.controller,
    super.filter,
  }) : super(collection: "classifiers");

  factory ClassifierField.builder(
    BuildContext context, {
    bool autofocus = false,
    bool readOnly = false,
    bool multiple = false,
    DataFilter? filter,
    SelectController<T>? controller,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<Iterable<T>>? onChanged,
    ValueChanged<Iterable<T>>? onSubmitted,
    TextInputAction? textInputAction,
  }) {
    return ClassifierField<T>(
      controller: controller,
      autofocus: autofocus,
      multiple: multiple,
      readOnly: readOnly,
      decoration: decoration,
      filter: filter,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      actionsBuilder: (context, state) {
        final theme = Theme.of(context);

        return [
          if (!readOnly)
            ActionChip(
              avatar: Icon(
                Icons.category_outlined,
                color: theme.colorScheme.outline,
              ),
              label: Text(
                "Select ${T.toString().toLowerCase()}...",
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: theme.colorScheme.outline,
                ),
              ),
              onPressed: () async {
                state as EntityFieldState<T>;
                state.mustNotFocus();

                final drafts = await Navigator.of(context)
                    .pushNamed<Iterable<Item<T>>>(
                      "/${T.toString().toLowerCase()}/select",
                      arguments: {
                        "multiple": multiple,
                        "initialValue": state.effectiveController.value,
                      },
                    );

                if (drafts != null && drafts.isNotEmpty) {
                  final items = drafts.map((draft) => Item<T>(draft.entity));

                  await state.provider.query();
                  await state.provider.addAll(items);
                  await state.provider.replaceAll(items);
                  state.effectiveController.updateAll(
                    state.provider.requireData.map(
                      (i) => state.widget.optionBuilder(context, i),
                    ),
                  );
                  state.effectiveController.replaceAll(
                    items.map((item) => item.entity),
                  );
                  onChanged?.call(state.effectiveController.value.toList());
                }

                state.refocusIfNeeded();
              },
            ),
        ];
      },
      resolveProvider: () =>
          DependencyInjector.of(context).get<AsyncSelectProvider<T>>(),
      optionBuilder: (context, item) =>
          SelectOption<T>(text: item.entity.name, value: item.entity),
    );
  }

  @override
  State<EntityField<T>> createState() => ClassifierFieldState<T>();
}

class ClassifierFieldState<T extends Classifier<T>>
    extends EntityFieldState<T> {
  @override
  initState() {
    if (!widget.readOnly) {
      provider.setFilter({...?widget.filter, "readonly_eq": false});
    } else {
      provider.setFilter(widget.filter ?? {});
    }

    super.initState();
  }
}
