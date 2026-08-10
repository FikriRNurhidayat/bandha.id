import 'package:bandha/core/presentation/views/async_editor_view.dart';
import 'package:bandha/core/presentation/widgets/forms/x_text_form_field.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:flutter/material.dart';

class AssetEditorView extends StatelessWidget {
  final String? id;
  final bool readOnly;

  const AssetEditorView({super.key, this.id, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return AsyncEditorView<Asset>.builder(
      context,
      id: id,
      name: 'Asset',
      readOnly: readOnly,
      formBuilder: (context, state) {
        return [
          XTextFormField(
            readOnly: readOnly,
            autofocus: true,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            initialValue: state.formData["name"],
            labelText: 'Name',
            hintText: 'Enter asset name...',
            onSaved: (v) => state.formData["name"] = v,
            validator: (v) => v == null ? "Required" : null,
          ),
          XTextFormField(
            readOnly: readOnly,
            labelText: 'Code',
            hintText: 'Enter asset code...',
            initialValue: state.formData["code"],
            textCapitalization: TextCapitalization.characters,
            onSaved: (v) => state.formData["code"] = v,
            validator: (v) => v == null ? "Required" : null,
            onFieldSubmitted: (v) async {
              state.submit();
            },
          ),
        ];
      },
    );
  }
}
