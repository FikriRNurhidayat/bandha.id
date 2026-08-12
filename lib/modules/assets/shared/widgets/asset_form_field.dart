import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_selector_provider.dart';
import 'package:bandha/core/presentation/widgets/forms/x_entity_form_field.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:flutter/material.dart';

class AssetFormField extends XEntityFormField<Asset> {
  AssetFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.enabled,
    super.initialValue,
    super.readOnly,
    super.textInputAction,
    required super.resolveProvider,
  }) : super(
         labelText: "Asset",
         hintText: "Select asset...",
         labelBuilder: (context, item) => Text(item.entity.code),
         actionsBuilder: (context, state) {
           final theme = Theme.of(context);

           return [
             if (!readOnly)
               ActionChip(
                 avatar: Icon(Icons.add, color: theme.colorScheme.outline),
                 label: Text(
                   "New asset",
                   style: TextStyle(
                     fontWeight: FontWeight.w100,
                     color: theme.colorScheme.outline,
                   ),
                 ),
                 onPressed: () async {
                   state.mustNotFocus();

                   final draft = await Navigator.of(
                     context,
                   ).pushNamed<Draft<Asset>>("/assets/new");

                   if (draft != null) {
                     final item = Item<Asset>(draft.entity);
                     state.didChange([item]);
                     await state.provider.add(item);
                     await state.provider.select(item);
                   }

                   state.refocusIfNeeded();
                 },
               ),
           ];
         },
       );

  factory AssetFormField.builder(
    BuildContext context, {
    FormFieldSetter<List<Item<Asset>>>? onSaved,
    FormFieldValidator<List<Item<Asset>>>? validator,
    bool enabled = true,
    List<Item<Asset>>? initialValue,
    bool readOnly = false,
    TextInputAction? textInputAction,
  }) {
    return AssetFormField(
      onSaved: onSaved,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      initialValue: initialValue,
      textInputAction: textInputAction,
      resolveProvider: () =>
          DependencyInjector.of(context).get<AsyncSelectorProvider<Asset>>(),
    );
  }
}
