import 'package:bandha/core/presentation/views/async_editor_view.dart';
import 'package:bandha/core/presentation/widgets/forms/x_amount_form_field.dart';
import 'package:bandha/core/presentation/widgets/forms/x_text_form_field.dart';
import 'package:bandha/modules/assets/shared/widgets/asset_form_field.dart';
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
          XTextFormField(
            autofocus: true,
            hintText: 'Enter journal name...',
            initialValue: state.formData["name"],
            labelText: 'Name',
            onSaved: (v) => state.formData["name"] = v,
            readOnly: readOnly,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          XTextFormField(
            hintText: 'Enter journal holder name...',
            initialValue: state.formData["holderName"],
            labelText: 'Holder name',
            onSaved: (v) => state.formData["holderName"] = v,
            readOnly: readOnly,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          XAmountFormField(
            hintText: 'Enter journal initial balance...',
            initialValue: state.formData["balance"],
            labelText: 'Balance',
            onSaved: (v) => state.formData["balance"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          AssetFormField.builder(
            context,
            initialValue: state.formData["asset"],
            onSaved: (v) => state.formData["asset"] = v,
            readOnly: readOnly,
            validator: (v) => v == null ? "Required" : null,
          ),
        ];
      },
    );
  }
}
