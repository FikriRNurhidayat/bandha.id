import 'package:bandha/core/presentation/widgets/forms/x_select_form_field.dart';
import 'package:bandha/core/types/entry_type.dart';

class XEntryTypeFormField extends XSelectFormField<EntryType> {
  XEntryTypeFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.enabled,
    super.initialValue,
    super.autovalidateMode,
    super.readOnly,
    super.textInputAction,
  }) : super(
          labelText: "Type",
          hintText: "Select type...",
          options: EntryType.values
              .map((v) => XSelectItem(value: v, label: v.toString()))
              .toList(),
        );
}
