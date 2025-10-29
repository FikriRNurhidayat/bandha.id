import 'package:banda/helpers/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimestampFormField extends FormField<DateTime> {
  TimestampFormField({
    super.key,
    super.validator,
    super.onSaved,
    super.initialValue,
    InputDecoration? decoration,
    InputDecoration? dateInputDecoration,
    InputDecoration? timeInputDecoration,
    String label = "Timestamp",
    String hint = "Select timestamp...",
  }) : super(
         builder: (FormFieldState<DateTime> field) {
           final state = field as _TimestampFormFieldState;

           return ValueListenableBuilder<bool>(
             valueListenable: state._isNow,
             builder: (context, isNow, _) {
               return Column(
                 spacing: 16,
                 children: [
                   InputDecorator(
                     decoration:
                         decoration ??
                         InputDecoration(
                           labelText: label,
                           hintText: hint,
                           border: const OutlineInputBorder(),
                           errorText: field.errorText,
                         ),
                     child: Wrap(
                       spacing: 8,
                       runSpacing: 8,
                       children: [
                         ChoiceChip(
                           label: const Text("Now"),
                           selected: isNow,
                           onSelected: (_) {
                             state._isNow.value = true;
                             field.didChange(DateTime.now());
                           },
                         ),
                         ChoiceChip(
                           label: const Text("Specific"),
                           selected: !isNow,
                           onSelected: (_) {
                             state._isNow.value = false;
                           },
                         ),
                       ],
                     ),
                   ),

                   if (!isNow)
                     Row(
                       children: [
                         Expanded(
                           child: TextField(
                             readOnly: true,
                             controller: state.dateController,
                             onTap: state.chooseDate,
                             decoration: dateInputDecoration,
                           ),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: TextField(
                             readOnly: true,
                             controller: state.timeController,
                             onTap: state.chooseTime,
                             decoration: timeInputDecoration,
                           ),
                         ),
                       ],
                     ),
                 ],
               );
             },
           );
         },
       );

  @override
  FormFieldState<DateTime> createState() => _TimestampFormFieldState();
}

class _TimestampFormFieldState extends FormFieldState<DateTime> {
  final ValueNotifier<bool> _isNow = ValueNotifier(true);
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _isNow.value = false;
      updateTextControllers(widget.initialValue!);
    }
  }

  @override
  bool validate() {
    if (_isNow.value) {
      didChange(DateTime.now());
    }

    return super.validate();
  }

  @override
  void save() {
    if (_isNow.value) {
      didChange(DateTime.now());
    }

    super.save();
  }

  void updateTextControllers(DateTime dateTime) {
    dateController.text = DateHelper.formatDate(dateTime);
    timeController.text = DateFormat("HH:mm").format(dateTime);
  }

  Future<void> chooseDate() async {
    final now = DateTime.now();
    final current = value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final newValue = DateTime(
        picked.year,
        picked.month,
        picked.day,
        current.hour,
        current.minute,
      );

      didChange(newValue);
      updateTextControllers(newValue);
    }
  }

  Future<void> chooseTime() async {
    final now = DateTime.now();
    final current = value ?? now;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (picked != null) {
      final newValue = DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      );

      didChange(newValue);
      updateTextControllers(newValue);
    }
  }

  @override
  void dispose() {
    _isNow.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }
}
