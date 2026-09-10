import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/number_form_field.dart';
import 'package:bandha/core/presentation/widgets/forms/select_form_field.dart';
import 'package:bandha/core/presentation/widgets/forms/timestamp_form_field.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:bandha/core/types/transaction_type.dart';
import 'package:bandha/modules/classifiers/shared/widgets/forms/category_form_field.dart';
import 'package:bandha/modules/classifiers/shared/widgets/forms/label_form_field.dart';
import 'package:bandha/modules/entries/shared/presentation/views/controllable_entry_editor_view.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter/material.dart';

class FundEntryEditorView extends StatelessWidget {
  const FundEntryEditorView({
    super.key,
    required this.controllerId,
    this.entryId,
    required this.readOnly,
  });

  final String controllerId;
  final String? entryId;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return ControllableEntryEditorView<Fund>.builder(
      context,
      controllerId: controllerId,
      entryId: entryId,
      readOnly: readOnly,
      formBuilder: (ctx, state) => [
        CategoryFormField(
          readOnly: true,
          decoration: XInputStyles.field(labelText: 'Category'),
          initialValue: state.formData["category"],
        ),
        if (state.formData["labels"] != null &&
            state.formData["labels"].isNotEmpty)
          LabelFormField(
            readOnly: true,
            multiple: true,
            decoration: XInputStyles.field(labelText: 'Labels'),
            initialValue: state.formData["labels"],
          ),
        SelectFormField<TransactionType>(
          autofocus: true,
          decoration: XInputStyles.field(
            labelText: 'Type',
            hintText: 'Select type...',
          ),
          initialValue: state.formData["type"] ?? [TransactionType.deposit],
          options: [
            SelectOption<TransactionType>(
              text: TransactionType.deposit.toString(),
              value: TransactionType.deposit,
            ),
            SelectOption<TransactionType>(
              text: TransactionType.withdraw.toString(),
              value: TransactionType.withdraw,
            ),
          ],
          onSaved: (v) => state.formData["type"] = v,
          validator: (v) => v == null ? "Required" : null,
          readOnly: readOnly,
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
          validator: (v) => v == null ? "Required" : null,
          readOnly: readOnly,
          textInputAction: TextInputAction.next,
        ),
        NumberFormField(
          decoration: XInputStyles.field(
            labelText: 'Amount',
            hintText: 'Enter amount...',
          ),
          initialValue: state.formData["amount"],
          onSaved: (v) => state.formData["amount"] = v,
          validator: (v) => v == null ? "Required" : null,
          readOnly: readOnly,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) async {
            await state.submit();
          },
        ),
      ],
    );
  }
}
