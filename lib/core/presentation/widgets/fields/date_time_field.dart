import 'package:bandha/core/presentation/controllers/date_time_controller.dart';
import 'package:bandha/core/presentation/extensions/text_input_action_label.dart';
import 'package:bandha/core/presentation/services/focus_observer.dart';
import 'package:bandha/core/presentation/widgets/texts/date_time_text.dart';
import 'package:flutter/material.dart';

class DateTimeField extends StatefulWidget {
  const DateTimeField({
    super.key,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.focusNode,
    this.controller,
    this.onChanged,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.readOnly = false,
    this.onSubmitted,
  });

  final bool readOnly;
  final InputDecoration decoration;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<DateTime?>? onChanged;
  final ValueChanged<DateTime?>? onSubmitted;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTimeController? controller;

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> with FocusObserver {
  DateTimeController? controller;
  TextEditingController? textEditingController;

  @override
  FocusNode? focusNode;

  @override
  late final effectiveFocusNode =
      widget.focusNode ??
      (focusNode ??= FocusNode(debugLabel: widget.decoration.labelText));
  late final effectiveController =
      widget.controller ?? (controller ??= DateTimeController(null));
  late final MaterialLocalizations i18n;

  bool _isLocked = false;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      i18n = MaterialLocalizations.of(context);
    });
  }

  @override
  didFocus() {
    debugPrint("DateTimeField/didFocus");
    super.didFocus();
    _pickDate();
  }

  void _pickDate() async {
    debugPrint("DateTimeField/_pickDate: _isLocked: $_isLocked");
    if (_isLocked) return;
    _isLocked = true;

    try {
      final theme = Theme.of(context);

      var dateTime = await showDatePicker(
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        firstDate: widget.firstDate ?? DateTime(2000),
        lastDate: widget.lastDate ?? DateTime(2100),
        initialDate: widget.initialDate ?? DateTime.now(),
        barrierDismissible: false,
        barrierColor: theme.colorScheme.surface,
        helpText: widget.decoration.labelText,
        confirmText: widget.textInputAction?.label,
      );
      if (!mounted) return;

      if (dateTime == null) {
        debugPrint("DateTimeField/_pickDate: dateTime is null");
        effectiveFocusNode.unfocus();
        return;
      }

      final timeOfDay = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.dialOnly,
        context: context,
        initialTime: TimeOfDay.now(),
        barrierDismissible: false,
        barrierColor: theme.colorScheme.surface,
        helpText: widget.decoration.labelText,
        confirmText: widget.textInputAction?.label,
      );

      if (!mounted) return;

      if (timeOfDay == null) {
        debugPrint("DateTimeField/_pickDate: timeOfDay is null");
        effectiveFocusNode.unfocus();
        return;
      }

      dateTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      effectiveController.value = dateTime;

      widget.onChanged?.call(dateTime);

      if (mounted) {
        switch (widget.textInputAction) {
          case TextInputAction.next:
            effectiveFocusNode.nextFocus();
          case TextInputAction.done:
          default:
            widget.onSubmitted?.call(dateTime);
            effectiveFocusNode.unfocus();
        }
      }
    } finally {
      debugPrint("DateTimeField/_pickDate.finally: _isLocked: $_isLocked");
      _isLocked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: effectiveFocusNode,
      child: IgnorePointer(
        ignoring: widget.readOnly,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => effectiveFocusNode.requestFocus(),
          child: ValueListenableBuilder(
            valueListenable: effectiveController,
            builder: (context, value, child) {
              return InputDecorator(
                isFocused: effectiveFocusNode.hasFocus,
                isEmpty: value == null,
                decoration: widget.decoration,
                child: value != null ? DateTimeText(value) : null,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    textEditingController?.dispose();
    super.dispose();
  }
}
