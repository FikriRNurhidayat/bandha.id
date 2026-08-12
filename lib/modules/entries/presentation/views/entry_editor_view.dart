import 'package:bandha/core/presentation/views/async_editor_view.dart';
import 'package:bandha/core/presentation/widgets/forms/x_entry_type_form_field.dart';
import 'package:bandha/core/presentation/widgets/forms/x_text_form_field.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/material.dart';

class EntryEditorView extends StatelessWidget {
  final String? id;
  final bool readOnly;

  const EntryEditorView({super.key, this.id, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return AsyncEditorView<Entry>.builder(
      context,
      id: id,
      name: 'Entry',
      readOnly: readOnly,
      formBuilder: (context, state) {
        return [
          XTextFormField(
            autofocus: true,
            hintText: 'Enter note...',
            initialValue: state.formData["note"],
            labelText: 'Name',
            onSaved: (v) => state.formData["note"] = v,
            readOnly: readOnly,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          XEntryTypeFormField(
            initialValue: state.formData["type"] != null
                ? [state.formData["type"]]
                : null,
            onSaved: (v) => state.formData["type"] = v?.isNotEmpty == true
                ? v!.first
                : null,
            readOnly: readOnly,
            validator: (v) => v == null || v.isEmpty ? "Required" : null,
          ),
        ];
      },
    );
  }
}
