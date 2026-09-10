import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/controllers/select_controller.dart';
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
  }) : super(collection: "journals");

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
      resolveProvider: () =>
          DependencyInjector.of(context).get<AsyncSelectProvider<Journal>>(),
      optionBuilder: (context, item) => SelectOption<Journal>(
        text: item.entity.displayName,
        value: item.entity,
      ),
    );
  }
}
