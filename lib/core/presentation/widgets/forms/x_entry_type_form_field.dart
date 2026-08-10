import 'package:bandha/core/presentation/widgets/forms/x_select_form_field.dart';
import 'package:bandha/core/types/entry_type.dart';

class XEntryTypeFormField extends XSelectFormField<EntryType> {
  XEntryTypeFormField({
    super.enabled,
    super.initialValue,
    super.key,
    super.onSaved,
    super.validator,
    super.readOnly,
  }) : super(
         labelText: "Type",
         hintText: "Enter type...",
         options: EntryType.values
             .map((v) => XSelectItem(value: v, label: v.toString()))
             .toList(),
       );
}
