import 'package:bandha/core/presentation/views/async_editor_view.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/number_form_field.dart';
import 'package:bandha/modules/assets/shared/widgets/forms/asset_form_field.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:flutter/material.dart';

class JournalEditorView extends StatelessWidget {
  final String? id;
  final bool readOnly;

  const JournalEditorView({super.key, this.id, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return AsyncEditorView<Journal>.builder(
      context,
      id: id,
      name: 'Journal',
      readOnly: readOnly,
      formBuilder: (context, state) {
        return [
          TextFormField(
            decoration: XInputStyles.field(
              hintText: 'Enter journal name...',
              labelText: 'Name',
            ),
            autofocus: true,
            initialValue: state.formData["name"],
            onSaved: (v) => state.formData["name"] = v,
            readOnly: readOnly,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          TextFormField(
            decoration: XInputStyles.field(
              hintText: 'Enter journal holder name...',
              labelText: 'Holder name',
            ),
            initialValue: state.formData["holderName"],
            onSaved: (v) => state.formData["holderName"] = v,
            readOnly: readOnly,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          NumberFormField(
            decoration: XInputStyles.field(
              hintText: 'Enter journal initial balance...',
              labelText: 'Balance',
            ),
            initialValue: state.formData["balance"],
            onSaved: (v) => state.formData["balance"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          AssetFormField(
            decoration: XInputStyles.field(
              labelText: 'Asset',
              hintText: 'Select asset...',
            ),
            initialValue: [?state.formData["asset"]],
            onSaved: (v) => state.formData["asset"] = v,
            readOnly: readOnly,
            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
            onFieldSubmitted: (v) async {
              await state.submit();
            },
          ),
        ];
      },
    );
  }
}
