import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormField extends FormField<DateTime> {
  DateTimeFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    InputDecoration? decoration,
    InputDecoration? dateInputDecoration,
    InputDecoration? timeInputDecoration,
    String label = "Date & Time",
    String hint = "Select date & time...",
    bool autovalidate = false,
    double spacing = 16,
  }) : super(
         autovalidateMode: autovalidate
             ? AutovalidateMode.always
             : AutovalidateMode.disabled,
         builder: (FormFieldState<DateTime> field) {
           final state = field as _DateTimeFormFieldState;

           return Row(
             children: [
               Expanded(
                 child: TextField(
                   readOnly: true,
                   controller: state.dateController,
                   onTap: state.chooseDate,
                   decoration:
                       dateInputDecoration ??
                       const InputDecoration(labelText: "Date"),
                 ),
               ),
               SizedBox(width: spacing),
               Expanded(
                 child: TextField(
                   readOnly: true,
                   controller: state.timeController,
                   onTap: state.chooseTime,
                   decoration:
                       timeInputDecoration ??
                       const InputDecoration(labelText: "Time"),
                 ),
               ),
             ],
           );
         },
       );

  @override
  FormFieldState<DateTime> createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends FormFieldState<DateTime> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      updateTextControllers(widget.initialValue!);
    }
  }

  void updateTextControllers(DateTime dateTime) {
    dateController.text = DateFormat('yyyy-MM-dd').format(dateTime);
    timeController.text = DateFormat('HH:mm').format(dateTime);
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
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }
}
