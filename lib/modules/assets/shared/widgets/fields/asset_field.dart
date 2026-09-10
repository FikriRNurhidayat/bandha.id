import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/controllers/select_controller.dart';
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
  }) : super(collection: "assets");

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
      resolveProvider: () =>
          DependencyInjector.of(context).get<AsyncSelectProvider<Asset>>(),
      optionBuilder: (context, item) =>
          SelectOption<Asset>(text: item.entity.name, value: item.entity),
    );
  }
}
