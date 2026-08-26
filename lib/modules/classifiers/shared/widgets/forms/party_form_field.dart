import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:bandha/modules/classifiers/shared/widgets/forms/classifier_form_field.dart';

class PartyFormField extends ClassifierFormField<Party> {
  PartyFormField({
    super.key,
    super.focusNode,
    super.readOnly,
    super.autofocus,
    super.multiple,
    super.decoration,
    super.textInputAction,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.initialValue,
    super.onFieldSubmitted,
  });
}
