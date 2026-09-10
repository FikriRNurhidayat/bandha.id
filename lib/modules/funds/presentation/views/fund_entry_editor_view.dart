import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/forms/number_form_field.dart';
import 'package:bandha/core/presentation/widgets/forms/select_form_field.dart';
import 'package:bandha/core/presentation/widgets/forms/timestamp_form_field.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:bandha/modules/classifiers/shared/widgets/forms/category_form_field.dart';
import 'package:bandha/modules/classifiers/shared/widgets/forms/label_form_field.dart';
import 'package:bandha/modules/entries/shared/presentation/views/controllable_entry_editor_view.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/domain/types/fund_transaction_type.dart';
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
          autofocus: true,
          readOnly: readOnly,
          decoration: XInputStyles.field(labelText: 'Category'),
          initialValue: state.formData["category"],
          textInputAction: TextInputAction.next,
          onSaved: (v) => state.formData["category"] = v,
          validator: (v) => v == null ? "Required" : null,
        ),
        if (readOnly)
          LabelFormField(
            decoration: XInputStyles.field(labelText: 'Labels'),
            initialValue: state.formData["labels"],
            multiple: true,
            readOnly: true,
          ),
        if (!readOnly)
          LabelFormField(
            decoration: XInputStyles.field(labelText: 'Labels'),
            initialValue: state.formData["mutableLabels"],
            multiple: true,
            onSaved: (v) => state.formData["mutableLabels"] = v,
            readOnly: false,
            textInputAction: TextInputAction.next,
            filter: {
              "id_nin": state.formData["readOnlyLabels"]?.map(
                (label) => label.id,
              ),
            },
          ),
        SelectFormField<FundTransactionType>(
          decoration: XInputStyles.field(
            labelText: 'Type',
            hintText: 'Select type...',
          ),
          initialValue: state.formData["type"] ?? [FundTransactionType.deposit],
          options: FundTransactionType.values.map(
            (transactionType) => SelectOption(
              text: transactionType.toString(),
              value: transactionType,
            ),
          ),
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
