import 'package:bandha/core/presentation/layouts/editor_layout.dart';
import 'package:bandha/core/presentation/widgets/app_text_form_field.dart';
import 'package:bandha/core/presentation/widgets/app_view_model_builder.dart';
import 'package:bandha/modules/assets/presentation/view_models/asset_form_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetEditorView extends StatelessWidget {
  final bool readOnly;
  final String? id;

  const AssetEditorView({super.key, this.id, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return AppViewModelBuilder<AssetFormViewModel>(
      create: (context) {
        final vm = AssetFormViewModel.of(context);

        if (id != null) {
          vm.get(id!);
        }

        return vm;
      },
      builder: (context, vm) {
        return EditorLayout(
          title: readOnly ? "Asset details" : "Enter asset details",
          readOnly: readOnly,
          onSubmit: (context) async {
            await vm.create();

            if (vm.isError) {
              if (kDebugMode) print(vm.error);
              if (!context.mounted) return;
              Navigator.of(context).pop(false);
            }

            if (!context.mounted) return;
            Navigator.of(context).pop(true);
          },
          child: Form(
            key: vm.formKey,
            child: Column(
              spacing: 16,
              children: [
                AppTextFormField(
                  readOnly: readOnly,
                  labelText: "Name",
                  hintText: "Enter asset name...",
                  initialValue: vm.name,
                  onSaved: (value) => vm.name = value ?? '',
                ),
                AppTextFormField(
                  readOnly: readOnly,
                  labelText: "Code",
                  hintText: "Enter asset code...",
                  initialValue: vm.code,
                  onSaved: (value) => vm.code = value ?? '',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return TextEditingValue(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
