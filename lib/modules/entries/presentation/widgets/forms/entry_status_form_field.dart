import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/widgets/forms/select_form_field.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';

class EntryStatusFormField extends SelectFormField<EntryStatus> {
  EntryStatusFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.autofocus,
    super.decoration,
    super.focusNode,
    super.multiple,
    super.onChanged,
    super.onFieldSubmitted,
    super.readOnly,
    super.textInputAction,
  }) : super(
         options: EntryStatus.values
             .where(
               (entryStatus) => readOnly || entryStatus != EntryStatus.unknown,
             )
             .map(
               (entryStatus) => SelectOption<EntryStatus>(
                 text: entryStatus.toString(),
                 value: entryStatus,
               ),
             ),
       );
}
