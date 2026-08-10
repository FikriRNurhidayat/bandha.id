import 'package:bandha/core/presentation/views/async_editor_view.dart';
import 'package:bandha/core/presentation/widgets/forms/x_amount_form_field.dart';
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
            initialValue: state.formData["type"],
            onSaved: (v) => state.formData["type"] = v,
            readOnly: readOnly,
            validator: (v) => v == null ? "Required" : null,
          ),

          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return ["Apple", "Orange", "Juice"].where((String option) {
                return option.contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              debugPrint('You just selected $selection');
            },
          ),
          XAmountFormField(
            hintText: 'Enter amount...',
            initialValue: state.formData["amount"],
            labelText: 'Amount',
            onSaved: (v) => state.formData["amount"] = v?.abs(),
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
        ];
      },
    );
  }
}
