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
                   final draft = await Navigator.of(
                     context,
                   ).pushNamed<Draft<Asset>>("/assets/new");

                   if (draft != null) {
                     final item = Item<Asset>(draft.entity);
                     state.didChange(item);
                     state.provider.add(item);
                     state.provider.select(item);
                   }
                 },
               ),
           ];
         },
       );

  factory AssetFormField.builder(
    BuildContext context, {
    FormFieldSetter<Item<Asset>>? onSaved,
    FormFieldValidator<Item<Asset>>? validator,
    bool enabled = true,
    Item<Asset>? initialValue,
    bool readOnly = false,
  }) {
    return AssetFormField(
      onSaved: onSaved,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      initialValue: initialValue,
      resolveProvider: () =>
          DependencyInjector.of(context).get<AsyncSelectorProvider<Asset>>(),
    );
  }
}
