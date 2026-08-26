import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_select_provider.dart';
import 'package:bandha/core/presentation/widgets/fields/entity_field.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:flutter/material.dart';

class AssetField extends EntityField<Asset> {
  const AssetField({
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

  factory AssetField.builder(
    BuildContext context, {
    bool autofocus = false,
    bool readOnly = false,
    bool multiple = false,
    SelectController<Asset>? controller,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<Iterable<Asset>>? onChanged,
    ValueChanged<Iterable<Asset>>? onSubmitted,
    TextInputAction? textInputAction,
  }) {
    return AssetField(
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
                "New asset",
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: theme.colorScheme.outline,
                ),
              ),
              onPressed: () async {
                state as EntityFieldState<Asset>;
                state.mustNotFocus();

                final draft = await Navigator.of(
                  context,
                ).pushNamed<Draft<Asset>>("/assets/new");

                if (draft != null) {
                  final item = Item<Asset>(draft.entity);
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
          DependencyInjector.of(context).get<AsyncSelectProvider<Asset>>(),
      optionBuilder: (context, item) =>
          SelectOption<Asset>(text: item.entity.name, value: item.entity),
    );
  }
}
