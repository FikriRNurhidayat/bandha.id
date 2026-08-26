import 'package:bandha/core/presentation/views/async_editor_view.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/number_form_field.dart';
import 'package:bandha/core/presentation/widgets/forms/timestamp_form_field.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:bandha/modules/journals/shared/widgets/forms/journal_form_field.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:flutter/material.dart';

class TransferEditorView extends StatelessWidget {
  final String? id;
  final bool readOnly;

  const TransferEditorView({super.key, this.id, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return AsyncEditorView<Transfer>.builder(
      context,
      id: id,
      name: 'Transfer',
      readOnly: readOnly,
      formBuilder: (context, state) {
        return [
          if (!readOnly || state.formData["note"] != null)
            TextFormField(
              decoration: XInputStyles.field(
                hintText: 'Enter transfer note...',
                labelText: 'Note',
              ),
              autofocus: true,
              initialValue: state.formData["note"],
              onSaved: (v) => state.formData["note"] = v,
              readOnly: readOnly,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
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
          JournalFormField(
            decoration: XInputStyles.field(
              labelText: 'Debit journal',
              hintText: 'Select debit journal...',
            ),
            initialValue: state.formData["debit_journal"],
            onSaved: (v) => state.formData["debit_journal"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
          ),
          NumberFormField(
            decoration: XInputStyles.field(
              labelText: 'Debit amount',
              hintText: 'Enter debit amount...',
            ),
            initialValue: state.formData["debit_amount"],
            onSaved: (v) => state.formData["debit_amount"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          if (!readOnly || state.formData["debit_fee_amount"] != null)
            NumberFormField(
              decoration: XInputStyles.field(
                hintText: 'Enter debit amount...',
                labelText: 'Debit fee amount',
              ),
              initialValue: state.formData["debit_fee_amount"],
              onSaved: (v) => state.formData["debit_fee_amount"] = v,
              readOnly: readOnly,
              textInputAction: TextInputAction.next,
            ),
          JournalFormField(
            decoration: XInputStyles.field(
              labelText: 'Credit journal',
              hintText: 'Select credit journal...',
            ),
            initialValue: state.formData["credit_journal"],
            onSaved: (v) => state.formData["credit_journal"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
          ),
          NumberFormField(
            decoration: XInputStyles.field(
              hintText: 'Enter credit amount...',
              labelText: 'Credit amount',
            ),
            initialValue: state.formData["credit_amount"],
            onSaved: (v) => state.formData["credit_amount"] = v,
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null ? "Required" : null,
          ),
          if (!readOnly || state.formData["credit_fee_amount"] != null)
            NumberFormField(
              decoration: XInputStyles.field(
                hintText: 'Enter credit fee amount...',
                labelText: 'Credit fee amount',
              ),
              initialValue: state.formData["credit_fee_amount"],
              onSaved: (v) => state.formData["credit_fee_amount"] = v,
              readOnly: readOnly,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (v) async {
                state.submit();
              },
            ),
        ];
      },
    );
  }
}
