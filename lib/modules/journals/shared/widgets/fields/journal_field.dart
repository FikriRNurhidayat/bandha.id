import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_select_provider.dart';
import 'package:bandha/core/presentation/widgets/fields/entity_field.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:flutter/material.dart';

class JournalField extends EntityField<Journal> {
  const JournalField({
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
  });

  factory JournalField.builder(
    BuildContext context, {
    bool autofocus = false,
    bool readOnly = false,
    bool multiple = false,
    SelectController<Journal>? controller,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<Iterable<Journal>>? onChanged,
    ValueChanged<Iterable<Journal>>? onSubmitted,
    TextInputAction? textInputAction,
  }) {
    return JournalField(
      controller: controller,
      autofocus: autofocus,
      multiple: multiple,
      readOnly: readOnly,
      decoration: decoration,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      actionsBuilder: (context, state) {
        final theme = Theme.of(context);

        return [
          if (!readOnly)
            ActionChip(
              avatar: Icon(Icons.add_outlined, color: theme.colorScheme.outline),
              label: Text(
                "New journal",
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: theme.colorScheme.outline,
                ),
              ),
              onPressed: () async {
                state as EntityFieldState<Journal>;
                state.mustNotFocus();

                final draft = await Navigator.of(
                  context,
                ).pushNamed<Draft<Journal>>("/journals/new");

                if (draft != null) {
                  final item = Item<Journal>(draft.entity);
                  await state.provider.add(item);
                  await state.provider.select(item);
                  final options = state.provider.requireData.map(
                    (i) => state.widget.optionBuilder(context, i),
                  );
                  state.effectiveController.update(options);
                  state.effectiveController.select(item.entity);
                  onChanged?.call([draft.entity]);
                }

                state.refocusIfNeeded();
              },
            ),
        ];
      },
      resolveProvider: () =>
          DependencyInjector.of(context).get<AsyncSelectProvider<Journal>>(),
      optionBuilder: (context, item) => SelectOption<Journal>(
        text: item.entity.displayName,
        value: item.entity,
      ),
    );
  }
}
