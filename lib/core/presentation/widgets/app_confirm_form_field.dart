import 'package:bandha/core/presentation/widgets/app_select_form_field.dart';
import 'package:bandha/core/types/confirm.dart';

class ConfirmFormField extends AppSelectFormField<bool?> {
  ConfirmFormField({
    super.key,
    super.initialValue,
    super.decoration,
    super.autovalidateMode,
    super.enabled,
    super.onSaved,
    super.validator,
    super.readOnly,
  }) : super(
         options: Confirm.values
             .map((i) => AppSelectItem(value: i.value, label: i.label))
             .toList(),
       );
}
