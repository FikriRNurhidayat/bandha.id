import 'package:bandha/core/presentation/views/async_editor_view.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/number_form_field.dart';
import 'package:bandha/core/presentation/widgets/forms/timestamp_form_field.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:bandha/modules/classifiers/shared/widgets/forms/category_form_field.dart';
import 'package:bandha/modules/classifiers/shared/widgets/forms/label_form_field.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/widgets/forms/entry_status_form_field.dart';
import 'package:bandha/modules/journals/shared/widgets/forms/journal_form_field.dart';
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
          CategoryFormField(
            autofocus: true,
            decoration: XInputStyles.field(
              labelText: 'Category',
              hintText: 'Select category...',
            ),
            initialValue: state.formData["category"],
            onSaved: (v) => state.formData["category"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
          ),
          if (!readOnly ||
              (state.formData["labels"] != null &&
                  state.formData["labels"].isNotEmpty))
            LabelFormField(
              decoration: XInputStyles.field(
                labelText: 'Labels',
                hintText: 'Select labels...',
              ),
              multiple: true,
              initialValue: state.formData["labels"],
              onSaved: (v) => state.formData["labels"] = v,
              readOnly: readOnly,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
            ),
          JournalFormField(
            decoration: XInputStyles.field(
              labelText: 'Journal',
              hintText: 'Select journal...',
            ),
            initialValue: state.formData["journal"],
            onSaved: (v) => state.formData["journal"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
          ),
          EntryStatusFormField(
            decoration: XInputStyles.field(
              labelText: 'Status',
              hintText: 'Enter status...',
            ),
            initialValue: state.formData["status"] ?? [EntryStatus.done],
            onSaved: (v) => state.formData["status"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          TimestampFormField(
            decoration: XInputStyles.field(
              labelText: 'Timestamp',
              hintText: 'Select timestamp...',
            ),
            dateTimeDecoration: XInputStyles.field(
              labelText: 'Date & Time',
              hintText: 'Select date & time...',
            ),
            initialValue: state.formData["timestamp"] ?? Timestamp.now(),
            onSaved: (v) => state.formData["timestamp"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          NumberFormField(
            decoration: XInputStyles.field(
              labelText: 'Amount',
              hintText: 'Enter amount...',
            ),
            initialValue: state.formData["amount"],
            onSaved: (v) => state.formData["amount"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          if (!readOnly || state.formData["note"] != null)
            TextFormField(
              decoration: XInputStyles.field(
                hintText: 'Enter entry note...',
                labelText: 'Note',
              ),
              initialValue: state.formData["note"],
              onSaved: (v) => state.formData["note"] = v,
              readOnly: readOnly,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) async {
                await state.submit();
              },
            ),
        ];
      },
    );
  }
}
